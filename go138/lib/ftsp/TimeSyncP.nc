/*
 * Copyright (c) 2002, Vanderbilt University
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE VANDERBILT UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE VANDERBILT
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE VANDERBILT UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE VANDERBILT UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * @author: Miklos Maroti, Brano Kusy (kusy@isis.vanderbilt.edu), Janos Sallai
 * Ported to T2: 3/17/08 by Brano Kusy (branislav.kusy@gmail.com)
 */
#include "TimeSyncMsg.h"
#include "../pr.h"
#include "../../include/logmsg.h"
#include "../../include/constants.h"

generic module TimeSyncP(typedef precision_tag)
{
    provides
    {
        interface Init;
        interface StdControl;
        interface GlobalTime<precision_tag>;

        //interfaces for extra functionality: need not to be wired
        interface TimeSyncInfo;
        //interface TimeSyncMode;
        //interface TimeSyncNotify;
    }
    uses
    {
        interface Boot;
        interface SplitControl as RadioControl;
        interface TimeSyncAMSend<precision_tag,uint32_t> as Send;
        interface Receive;
        interface Timer<TMilli>;
        interface Leds;
        interface TimeSyncPacket<precision_tag,uint32_t>;
        interface LocalTime<precision_tag> as LocalTime;
#ifdef ENABLE_LOG		
		interface CLogGlobal as Log;
#endif 
    }
}
implementation
{

#ifndef TIMESYNC_RATE
#define TIMESYNC_RATE   10
#endif

#ifndef FTSP_ROOT
#define FTSP_ROOT   1
#endif


    enum {
        MAX_ENTRIES           = 8,              // number of entries in the table
        BEACON_RATE           = TIMESYNC_RATE,  // how often send the beacon msg (in seconds)
        ROOT_TIMEOUT          = 50,              //time to declare itself the root if no msg was received (in sync periods)
        IGNORE_ROOT_MSG       = 4,              // after becoming the root ignore other roots messages (in send period)
        ENTRY_VALID_LIMIT     = 4,              // number of entries to become synchronized
        ENTRY_SEND_LIMIT      = 3,              // number of entries to send sync messages
        ENTRY_THROWOUT_LIMIT  = 100,            // if time sync error is bigger than this clear the table
		FTSPROOT_WAIT_LIMIT   = 2 * ENTIRE_CYCLE_TIME/TIMESYNC_RATE,
		NO_NEWS_THR			  = 4000,//missing messages from the root, need to resynchronize.
    };

    typedef struct TableItem
    {
        uint8_t     state;
        uint32_t    localTime;
        int32_t     timeOffset; // globalTime - localTime
    } TableItem;

    enum {
        ENTRY_EMPTY = 0,
        ENTRY_FULL = 1,
    };

    TableItem   table[MAX_ENTRIES];
    uint8_t tableEntries;

    enum {
        STATE_IDLE = 0x00,
        STATE_PROCESSING = 0x01,
        STATE_SENDING = 0x02,
        STATE_INIT = 0x04,
    };

    uint8_t state, mode;

/*
    We do linear regression from localTime to timeOffset (globalTime - localTime).
    This way we can keep the slope close to zero (ideally) and represent it
    as a float with high precision.

        timeOffset - offsetAverage = skew * (localTime - localAverage)
        timeOffset = offsetAverage + skew * (localTime - localAverage)
        globalTime = localTime + offsetAverage + skew * (localTime - localAverage)
*/

    float       skew;
    uint32_t    localAverage;
    int32_t     offsetAverage;
    uint8_t     numEntries; // the number of full entries in the table
	uint8_t  	noNewsFromRoot;
	seqnum_t 	lastRevdSeq;
	uint32_t 	rootWaitCount;
	bool radioOn = TRUE;
    message_t processedMsgBuffer;
    message_t* processedMsg;

    message_t outgoingMsgBuffer;
    TimeSyncMsg* outgoingMsg;

    uint8_t heartBeats; // the number of sucessfully sent messages
                        // since adding a new entry with lower beacon id than ours

    async command uint32_t GlobalTime.getLocalTime()
    {
        return call LocalTime.get();
    }

    async command error_t GlobalTime.getGlobalTime(uint32_t *time)
    {
        *time = call GlobalTime.getLocalTime();
        return call GlobalTime.local2Global(time);
    }

    error_t is_synced()
    {
      if (numEntries>=ENTRY_VALID_LIMIT)// || outgoingMsg->rootID==TOS_NODE_ID)
        return SUCCESS;
      else
        return FAIL;
    }


    async command error_t GlobalTime.local2Global(uint32_t *time)
    {
        *time += offsetAverage;// + (int32_t)(skew * (int32_t)(*time - localAverage));
        return is_synced();
    }

    async command error_t GlobalTime.global2Local(uint32_t *time)
    {
        uint32_t approxLocalTime = *time - offsetAverage;
        *time = approxLocalTime - (int32_t)(skew * (int32_t)(approxLocalTime - localAverage));
        return is_synced();
    }

    void calculateConversion()
    {
        float newSkew = skew;
        uint32_t newLocalAverage;
        int32_t newOffsetAverage;

        int64_t localSum;
        int64_t offsetSum;

        int8_t i;

        for(i = 0; i < MAX_ENTRIES && table[i].state != ENTRY_FULL; ++i)
            ;

        if( i >= MAX_ENTRIES )  // table is empty
            return;
/*
        We use a rough approximation first to avoid time overflow errors. The idea
        is that all times in the table should be relatively close to each other.
*/
        newLocalAverage = table[i].localTime;
        newOffsetAverage = table[i].timeOffset;

        localSum = 0;
        offsetSum = 0;

        while( ++i < MAX_ENTRIES )
            if( table[i].state == ENTRY_FULL ) {
                localSum += (int32_t)(table[i].localTime - newLocalAverage) / tableEntries;
                offsetSum += (int32_t)(table[i].timeOffset - newOffsetAverage) / tableEntries;
            }

        newLocalAverage += localSum;
        newOffsetAverage += offsetSum;

        localSum = offsetSum = 0;
        for(i = 0; i < MAX_ENTRIES; ++i)
            if( table[i].state == ENTRY_FULL ) {
                int32_t a = table[i].localTime - newLocalAverage;
                int32_t b = table[i].timeOffset - newOffsetAverage;

                localSum += (int64_t)a * a;
                offsetSum += (int64_t)a * b;
            }

        if( localSum != 0 )
            newSkew = (float)offsetSum / (float)localSum;

        atomic
        {
            skew = newSkew;
            offsetAverage = newOffsetAverage;
            localAverage = newLocalAverage;
            numEntries = tableEntries;
        }
    }

    void clearTable()
    {
        int8_t i;
        for(i = 0; i < MAX_ENTRIES; ++i)
            table[i].state = ENTRY_EMPTY;

        atomic numEntries = 0;
    }

    uint8_t numErrors=0;
    void addNewEntry(TimeSyncMsg *msg)
    {
        int8_t i, freeItem = -1, oldestItem = 0;
        uint32_t age, oldestTime = 0;
        int32_t timeError, tempLocalTime, localtimeDiff;

        tableEntries = 0;
		
        // clear table if the received entry's been inconsistent for some time
        timeError = msg->localTime;
        call GlobalTime.local2Global((uint32_t*)(&timeError));
        timeError -= msg->globalTime;
		tempLocalTime = call GlobalTime.getLocalTime();
		localtimeDiff = tempLocalTime - msg->localTime;
		if ((localtimeDiff > ENTRY_IMMEDIATELY_THROWOUT_LIMIT 
			|| localtimeDiff < 0) )
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 1, msg->localTime, msg->globalTime, tempLocalTime);
			return;
		}
		//pr("recvd time:%lu %lu %lu", msg->localTime, msg->globalTime, timeError);
		//LOGMSG3(TIME_SYNC_ENTRY_TIME + 1, msg->localTime, msg->globalTime, tempLocalTime);
        if( (is_synced() == SUCCESS) &&
            (timeError > ENTRY_THROWOUT_LIMIT || timeError < -ENTRY_THROWOUT_LIMIT))
        {
			pr("bc,te:%ld, ne:%d", timeError, numErrors);
			if (timeError > ENTRY_IMMEDIATELY_THROWOUT_LIMIT) //clear the entries for very large error(reboot event?).
			{
				//clearTable();
				++numErrors;
				LOGMSG3(TIME_SYNC_ENTRY_TIME + 1, msg->localTime, msg->globalTime, tempLocalTime);
				return; //return if the time is very different from before.
			}
            if (++numErrors>3)
			{
                clearTable();
				pr("clr");
			}
        }
        else
            numErrors = 0;


        for(i = 0; i < MAX_ENTRIES; ++i) {
            age = msg->localTime - table[i].localTime;

            //logical time error compensation
            if( age >= 0x7FFFFFFFL )
                table[i].state = ENTRY_EMPTY;

            if( table[i].state == ENTRY_EMPTY )
                freeItem = i;
            else
                ++tableEntries;

            if( age >= oldestTime ) {
                oldestTime = age;
                oldestItem = i;
            }
        }

        if( freeItem < 0 )
            freeItem = oldestItem;
        else
            ++tableEntries;

        table[freeItem].state = ENTRY_FULL;

        table[freeItem].localTime = msg->localTime;
        table[freeItem].timeOffset = msg->globalTime - msg->localTime;
		tempLocalTime = call GlobalTime.getLocalTime();
		//LOGMSG3(TIME_SYNC_ENTRY_TIME, msg->localTime, msg->globalTime, tempLocalTime);
    }

    void task processMsg()
    {
        TimeSyncMsg* msg = (TimeSyncMsg*)(call Send.getPayload(processedMsg, sizeof(TimeSyncMsg)));
//		pr("recvdId:%d, seq:%ld outid:%d\n", msg->rootID, msg->seqNum,outgoingMsg->rootID);
		if (msg->rootID != FTSP_ROOT) 
		{
            goto exit;
		}
		
		if (outgoingMsg->rootID == 0xffff && lastRevdSeq == msg->seqNum && TOS_NODE_ID != FTSP_ROOT) 
		{
		//do not update root id until receive new messages.
			goto exit;
		}

		if (msg->rootID < outgoingMsg->rootID) 
		{
			outgoingMsg->rootID = msg->rootID;
			outgoingMsg->seqNum = msg->seqNum;
		}else 
		if( outgoingMsg->rootID == msg->rootID 
			&& (int32_t)(msg->seqNum - outgoingMsg->seqNum) > 0 ) {
            outgoingMsg->seqNum = msg->seqNum;
			lastRevdSeq = msg->seqNum;
			noNewsFromRoot = 0;
        }
        else{ 
			
			if (outgoingMsg->rootID == FTSP_ROOT && msg->seqNum == outgoingMsg->seqNum)
			{//now news from the roots; The seq num is supposed to increase each time;
				//pr("no News:%d\n", noNewsFromRoot);
				++noNewsFromRoot;
			}
		    goto exit;
		}

        //call Leds.led0Toggle();
        if( outgoingMsg->rootID == FTSP_ROOT )
            heartBeats = 0;

        addNewEntry(msg);
        calculateConversion();
        //signal TimeSyncNotify.msg_received();

    exit:
        state &= ~STATE_PROCESSING;
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
    {
#ifdef TIMESYNC_DEBUG   // this code can be used to simulate multiple hopsf
        uint8_t incomingID = (uint8_t)((TimeSyncMsg*)payload)->nodeID;
        int8_t diff = (incomingID & 0x0F) - (TOS_NODE_ID & 0x0F);
        if( diff < -1 || diff > 1 )
            return msg;
        diff = (incomingID & 0xF0) - (TOS_NODE_ID & 0xF0);
        if( diff < -16 || diff > 16 )
            return msg;
#endif
        if( (state & STATE_PROCESSING) == 0 ) {
            message_t* old = processedMsg;

            processedMsg = msg;
			
			if (call TimeSyncPacket.isValid(msg) == FALSE) 
			{
				return msg;
			} else {
	            ((TimeSyncMsg*)(payload))->localTime = call TimeSyncPacket.eventTime(msg);

	            state |= STATE_PROCESSING;
	            post processMsg();

	            return old;
			}
        }

        return msg;
    }

    task void sendMsg()
    {
        uint32_t localTime, globalTime;
		uint32_t temp;
		error_t sendState;
        globalTime = localTime = call GlobalTime.getLocalTime();
		
        call GlobalTime.local2Global(&globalTime);
		//LOGMSG3(11, offsetAverage, localTime, numEntries);
#ifdef ENABLE_SINK_WAITING_MODE
		//sink needs to wait to synchronize with other nodes.
		if (is_synced() != SUCCESS 
			&& (TOS_NODE_ID != FTSP_ROOT ))
		{
			
			state &= ~STATE_SENDING;
			return;
		}
		if (numEntries < 1 && TOS_NODE_ID == FTSP_ROOT) 
		{
			state &= ~STATE_SENDING;
			return;
		}

#else
		//nodes need to have enough info before synchronize others.
		if (numEntries < 2 && TOS_NODE_ID != FTSP_ROOT) 
		{
			state &= ~STATE_SENDING;
			return;
		}
#endif
		
        // we need to periodically update the reference point for the root
        // to avoid wrapping the 32-bit (localTime - localAverage) value
        if( outgoingMsg->rootID == TOS_NODE_ID ) {
            if( (int32_t)(localTime - localAverage) >= 0x20000000 )
            {
                atomic
                {
                    localAverage = localTime;
                    offsetAverage = globalTime - localTime;
                }
            }
        }
		
		if (outgoingMsg->rootID == FTSP_ROOT 
			&& outgoingMsg->seqNum == lastRevdSeq) 
		{//do not receive msg from root since last time.
			++noNewsFromRoot;
		}
		if (noNewsFromRoot >= NO_NEWS_THR) 
		{
			outgoingMsg->rootID = 0xffff;
			noNewsFromRoot = 0;
			
		}
		
        
		/*else if( heartBeats >= ROOT_TIMEOUT ) {
		            heartBeats = 0; //to allow ROOT_SWITCH_IGNORE to work
		            outgoingMsg->rootID = TOS_NODE_ID;
		            ++(outgoingMsg->seqNum); // maybe set it to zero?
		        }*/

        outgoingMsg->globalTime = globalTime;

        // we don't send time sync msg, if we don't have enough data
		memcpy(&temp, &skew, sizeof(float));
		pr("bs:r=%d,entries=%d\n", outgoingMsg->rootID, numEntries);
		//pr(" ra=%d, numEn:%d\n", radioOn, numEntries);
        if( outgoingMsg->rootID != FTSP_ROOT //ignore all msgs while not the root node. Assume the root node is always available.
		   ||(radioOn == TRUE && numEntries < ENTRY_SEND_LIMIT 
		      && outgoingMsg->rootID != TOS_NODE_ID) ){
			
            ++heartBeats;
			//pr("++hb entry:%d hb:%d\n", numEntries, heartBeats);
            state &= ~STATE_SENDING;
        }
        else 
		{
			//LOGMSG3(9, outgoingMsg->rootID, numEntries, outgoingMsg->seqNum);
		    sendState = call Send.send(AM_BROADCAST_ADDR, &outgoingMsgBuffer, TIMESYNCMSG_LEN, localTime );
			//pr("sendState:%d\n", sendState);
			if (sendState == SUCCESS) {
				radioOn = TRUE;
				
			}else 
			{
				
				state &= ~STATE_SENDING;
				//signal TimeSyncNotify.msg_sent();
				if (sendState == EOFF) {
					radioOn = FALSE;
				}
				//pr("sendstate = off[heartBeats=%d]\n", heartBeats);
				
			}
        }
    }

    event void Send.sendDone(message_t* ptr, error_t error)
    {
		//pr("sendDone[heartBeats=%d,error=%d]\n", heartBeats, error);
        if (ptr != &outgoingMsgBuffer)
          return;

        if(error == SUCCESS)
        {
            ++heartBeats;
            //call Leds.led1Toggle();
			
            if( TOS_NODE_ID == FTSP_ROOT )
                ++(outgoingMsg->seqNum);
        }

        state &= ~STATE_SENDING;
//        signal TimeSyncNotify.msg_sent();
    }

    void timeSyncMsgSend()
    {
		if (outgoingMsg->rootID == 0xFFFF) 
		{
			++rootWaitCount;
		}
		
#ifdef ENABLE_SINK_WAITING_MODE

#else
		
        if( outgoingMsg->rootID == 0xFFFF && ++heartBeats >= ROOT_TIMEOUT / 10 ) {
            outgoingMsg->seqNum = 0;
            if (TOS_NODE_ID == FTSP_ROOT) //only take self as root if i am a ftsp root node.
			{
				outgoingMsg->rootID = TOS_NODE_ID;
			}
        }
		
#endif

		pr("[in send]root=%d, seq=%ld, hb=%d, state=%d\n", outgoingMsg->rootID, outgoingMsg->seqNum, heartBeats, state);
        if( outgoingMsg->rootID != 0xFFFF && (state & STATE_SENDING) == 0 ) {
		//pr("post sendMsg\n");
           state |= STATE_SENDING;
           post sendMsg();
        }
	}

    event void Timer.fired()
    {
		//pr("mode:%d\n", mode);
      if (mode == TS_TIMER_MODE) {
        timeSyncMsgSend();
      }
      else
        call Timer.stop();
    }

    /*
    command error_t TimeSyncMode.setMode(uint8_t mode_){
        if (mode == mode_)
            return SUCCESS;

        if (mode_ == TS_USER_MODE){
            call Timer.startPeriodic((uint32_t)1000 * BEACON_RATE);
        }
        else
            call Timer.stop();

        mode = mode_;
        return SUCCESS;
    }

    command uint8_t TimeSyncMode.getMode(){
        return mode;
    }

    command error_t TimeSyncMode.send(){
		
        if (mode == TS_USER_MODE){
            timeSyncMsgSend();
            return SUCCESS;
        }
        return FAIL;
    }
    */

    command error_t Init.init()
    {
        atomic{
            skew = 0.0;
            localAverage = 0;
            offsetAverage = 0;
        };

        clearTable();

        atomic outgoingMsg = (TimeSyncMsg*)call Send.getPayload(&outgoingMsgBuffer, sizeof(TimeSyncMsg));
        outgoingMsg->rootID = 0xFFFF;
		noNewsFromRoot = 0;
		lastRevdSeq	= 0;
        processedMsg = &processedMsgBuffer;
        state = STATE_INIT;
		rootWaitCount = 0;
		//pr("init:rootId=%d\n", outgoingMsg->rootID);
        return SUCCESS;
    }

    event void Boot.booted()
    {
      call RadioControl.start();
      call StdControl.start();
    }

    command error_t StdControl.start()
    {
        mode = TS_TIMER_MODE;
        heartBeats = 0;
        outgoingMsg->nodeID = TOS_NODE_ID;
        call Timer.startPeriodic((uint32_t)1000 * BEACON_RATE);
		//pr("stdcontrol:rootId=%d\n", outgoingMsg->rootID);
        return SUCCESS;
    }

    command error_t StdControl.stop()
    {
        call Timer.stop();
        return SUCCESS;
    }

    async command float     TimeSyncInfo.getSkew() { return skew; }
    async command uint32_t  TimeSyncInfo.getOffset() { return offsetAverage; }
    async command uint32_t  TimeSyncInfo.getSyncPoint() { return localAverage; }
    async command uint16_t  TimeSyncInfo.getRootID() { return outgoingMsg->rootID; }
    async command seqnum_t   TimeSyncInfo.getSeqNum() { return outgoingMsg->seqNum; }
    async command uint8_t   TimeSyncInfo.getNumEntries() { return numEntries; }
    async command uint8_t   TimeSyncInfo.getHeartBeats() { return heartBeats; }

    //default event void TimeSyncNotify.msg_received(){}
    //default event void TimeSyncNotify.msg_sent(){}

    event void RadioControl.startDone(error_t error){}
    event void RadioControl.stopDone(error_t error){}
}
