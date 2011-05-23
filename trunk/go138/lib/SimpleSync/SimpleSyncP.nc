
#include "SimpleSync.h"
#include "../pr.h"
#include "../../include/logmsg.h"
#include "../../include/constants.h"


generic module SimpleSyncP(typedef precision_tag)
{
    provides
    {
        interface Init;
        interface StdControl;
        interface GlobalTime<precision_tag>;
        interface TimeSyncInfo;
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


#ifndef FTSP_ROOT
#define FTSP_ROOT   1
#endif

#ifndef SYNC_MSG_ID
#define SYNC_MSG_ID	20
#endif

#ifndef NO_NEWS_THR
#define NO_NEWS_THR 115200
#endif

#define ERROR_SEQ_DIFF_THR	(360*2)
#define ERROR_NUM_THR	3


#define notSending ((state & STATE_SENDING) == 0)


	enum {
	    MAX_ENTRIES           = 8,              // number of entries in the table
	    BEACON_RATE           = TIMESYNC_RATE,  // how often send the beacon msg (in seconds)
	    ROOT_TIMEOUT          = 50,              //time to declare itself the root if no msg was received (in sync periods)
	    IGNORE_ROOT_MSG       = 4,              // after becoming the root ignore other roots messages (in send period)
	    ENTRY_VALID_LIMIT     = 4,              // number of entries to become synchronized
	    ENTRY_SEND_LIMIT      = 3,              // number of entries to send sync messages
	    ENTRY_THROWOUT_LIMIT  = 100,            // if time sync error is bigger than this clear the table

	};

#ifndef ROOT_WAIT_COUNT
	#define ROOT_WAIT_COUNT	720
#endif

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

    uint8_t state;

    float       skew;
    uint32_t    localAverage;
    int32_t     offsetAverage;
    uint8_t     numEntries; // the number of full entries in the table

	uint32_t 	timeFiredCount = 0;
	uint32_t 	noNewsFromRoot = 0;
	uint32_t    lastRevdSeq = 0;
	uint32_t 	lastErrorSeq = 0;

    message_t processedMsgBuffer;
    message_t* processedMsg;

    message_t outgoingMsgBuffer;

	
	TimeSyncMsg debugMsgBuffer;
	bool 		setDebugMsg = FALSE;
	
    TimeSyncMsg* outgoingMsg;

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
		LOGMSG3(TIME_SYNC_ENTRY_TIME + 6, lastRevdSeq, lastErrorSeq, numEntries);
		for(i = 0; i < MAX_ENTRIES; ++i)
            table[i].state = ENTRY_EMPTY;
        atomic {
			numEntries = 0;
			//offsetAverage = 0;
			//skew = 0;
			//add this to filter incorrect data, may receive data with wrong seq
			//outgoingMsg->seqNum = 0; 
			}
    }

    uint8_t numErrors=0;
    void addNewEntry(TimeSyncMsg *msg)
    {
        int8_t i, freeItem = -1, oldestItem = 0;
        uint32_t age, oldestTime = 0;
        int32_t timeError, tempLocalTime, localtimeDiff, offsetDiff;
		bool thisMsgError = FALSE;
		bool needIncreaseError = FALSE;
        tableEntries = 0;
		
        // clear table if the received entry's been inconsistent for some time
        timeError = msg->localTime;
        call GlobalTime.local2Global(&timeError);
        timeError -= msg->globalTime;
		tempLocalTime = call GlobalTime.getLocalTime();
		localtimeDiff = tempLocalTime - msg->localTime;
		offsetDiff = offsetAverage - (msg->globalTime - msg->localTime);
		pr("seq1:%ld, seq2:%ld, entry:%d,timeError=%ld, tempLocalTime=%ld, localtimeDiff=%ld, offsetDiff=%ld\n", \
			msg->seqNum, lastRevdSeq, numEntries, timeError, tempLocalTime, localtimeDiff, offsetDiff);
		pr("offsetAverage:%ld\n", offsetAverage);
		
		if (numEntries == 0) 
		{
			
		}
		//offset error
		else if ((offsetDiff > TIMESYNC_OFFSET_DIFF_THR 
			|| offsetDiff < -TIMESYNC_OFFSET_DIFF_THR))//only check offset average when entries > 2  
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 2, msg->localTime, msg->globalTime, tempLocalTime);
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 9, msg->seqNum, offsetAverage, numEntries);
			thisMsgError = TRUE;
			needIncreaseError = TRUE;
			//return;
		}
		else if ((localtimeDiff > ENTRY_IMMEDIATELY_THROWOUT_LIMIT 
			|| localtimeDiff < 0) )
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 1, msg->localTime, msg->globalTime, tempLocalTime);
			
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 10, msg->seqNum, offsetAverage, numEntries);
			thisMsgError = TRUE;
			//return;
		}
		//global time error
		else if (timeError > ENTRY_THROWOUT_LIMIT 
			|| timeError < -ENTRY_THROWOUT_LIMIT)
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 5, msg->localTime, msg->globalTime, tempLocalTime);
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 11, msg->seqNum, offsetAverage, numEntries);
			thisMsgError = TRUE;
			//return;
		}
		//update for consecutive incorrect msg
		if (thisMsgError) 
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 3, msg->localTime, msg->globalTime, msg->seqNum);
			if (lastErrorSeq != 0 && lastRevdSeq > lastErrorSeq 
				&& lastRevdSeq - lastErrorSeq > ERROR_SEQ_DIFF_THR) 
			{
				LOGMSG3(TIME_SYNC_ENTRY_TIME + 7, msg->localTime, msg->globalTime, msg->seqNum);
				LOGMSG3(TIME_SYNC_ENTRY_TIME + 12, msg->seqNum, offsetAverage, numEntries);
				numErrors = 0;
			}
			if (needIncreaseError) {
				++numErrors;
			}
			lastErrorSeq = msg->seqNum;
			pr("numErrors:%d\n", numErrors);
			if (numErrors >= ERROR_NUM_THR) 
			{
				LOGMSG3(TIME_SYNC_ENTRY_TIME + 4, msg->localTime, msg->globalTime, msg->seqNum);
				LOGMSG3(TIME_SYNC_ENTRY_TIME + 13, msg->seqNum, offsetAverage, numEntries);

				numErrors = 0;
				clearTable();
			}
			return;
		}
		//numErrors = 0;
		
		pr("numErrors2:%d\n", numErrors);
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
    }

    void task processMsg()
    {
        TimeSyncMsg* msg = (TimeSyncMsg*)(call Send.getPayload(processedMsg, sizeof(TimeSyncMsg)));
		pr("recv msg:root:%d,id=%d,seq=%ld, seq2=%ld, lastseq=%ld outgoingID%d\n", \
			msg->rootID, msg->id, msg->seqNum, outgoingMsg->seqNum, lastRevdSeq, outgoingMsg->rootID);

		if (outgoingMsg->rootID != FTSP_ROOT) 
		{
			outgoingMsg->seqNum = 0;
		}
		

		if (msg->rootID != FTSP_ROOT) 
		{
			pr("not rootID\n");
	        state &= ~STATE_PROCESSING;    	
    		return;
		}
		if (msg->id != SYNC_MSG_ID) 
		{
			pr("not sync msg id\n");
	        state &= ~STATE_PROCESSING;    	
			return;
		}


		//old msg, not update
		if (msg->seqNum < outgoingMsg->seqNum)
		{
			pr("msg seq:%ld, outgoing seq:%ld, rootID:%d\n", msg->seqNum, outgoingMsg->seqNum, outgoingMsg->rootID);
			state &= ~STATE_PROCESSING;
			return;
		}

		//add to fix bugs, why why why bugs??? why received abnormal seqNum?
		if (noNewsFromRoot > TIMESYNC_NO_NEWS_FROM_ROOT_THR)
		{
			outgoingMsg->seqNum = 0;
			
			lastRevdSeq = 0;
		}

		
		/*if (outgoingMsg->seqNum != 0 && msg->seqNum - outgoingMsg->seqNum > 1000) 
		{
			LOGMSG3(TIME_SYNC_ENTRY_TIME + 8, msg->seqNum, outgoingMsg->seqNum, msg->globalTime);
			{
				memcpy(&debugMsgBuffer, msg, sizeof(TimeSyncMsg));
				setDebugMsg = TRUE;
			}
		}*/
		if (outgoingMsg->seqNum != 0 && msg->seqNum - outgoingMsg->seqNum > TIMESYNC_SEQ_DIFF_THR) 
		{
			pr("SEQ diff,msg seq:%ld, outgoing seq:%ld, rootID:%d\n", msg->seqNum, outgoingMsg->seqNum, outgoingMsg->rootID);
			state &= ~STATE_PROCESSING;
			return;
		}
		if (msg->seqNum > lastRevdSeq)
		{
			atomic noNewsFromRoot = 0;
			pr(" set no News to 0\n");
		}

		//why there is a bug??
		
		//pr("no news from root[%d]:%ld\n", __LINE__, noNewsFromRoot);
		lastRevdSeq = msg->seqNum;
		outgoingMsg->rootID = msg->rootID;
		outgoingMsg->seqNum = msg->seqNum;
        addNewEntry(msg);
        calculateConversion();
        state &= ~STATE_PROCESSING;    	
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
    {
    	pr("recvd\t");
        if( (state & STATE_PROCESSING) == 0 ) {
            message_t* old = processedMsg;
            processedMsg = msg;
			if (call TimeSyncPacket.isValid(msg) == FALSE) 
			{
				return msg;
			} else {
				pr("processing %d\n", STATE_PROCESSING);
	            ((TimeSyncMsg*)(payload))->localTime = call TimeSyncPacket.eventTime(msg);
	            state |= STATE_PROCESSING;
	            post processMsg();
				state &= (~STATE_PROCESSING);
	            return old;
			}
        }
        return msg;
    }

    task void sendMsg()
    {
        uint32_t localTime, globalTime;
		error_t sendState;
		bool canSendMsg = FALSE;
        globalTime = localTime = call GlobalTime.getLocalTime();
		
        call GlobalTime.local2Global(&globalTime);
		

		if (TOS_NODE_ID == FTSP_ROOT) 
		{
			//how to handle root node.
			if (timeFiredCount > ROOT_WAIT_COUNT) 
			{
				canSendMsg = TRUE;
			}
		}else //not root node.
		{
			if (outgoingMsg->rootID == FTSP_ROOT)
			{
			
				if (outgoingMsg->seqNum <= lastRevdSeq)
				{
					atomic noNewsFromRoot = noNewsFromRoot + 1;
				}
				if (numEntries < 3) 
				{
					return;
				}
				canSendMsg = TRUE;
			}
		}

		//send msg in this step.
		if (canSendMsg && notSending) 
		{
			outgoingMsg->globalTime = globalTime;
			outgoingMsg->id = SYNC_MSG_ID;
			outgoingMsg->nodeID = TOS_NODE_ID;
			sendState = call Send.send(AM_BROADCAST_ADDR, &outgoingMsgBuffer, TIMESYNCMSG_LEN, localTime );
			if (sendState == SUCCESS) {
				state |= STATE_SENDING;
			}else 
			{
				if (sendState == EOFF) {
				}
			}
		}
		return;
	}

    event void Send.sendDone(message_t* ptr, error_t error)
    {
        if (ptr != &outgoingMsgBuffer)
          return;
        if(error == SUCCESS)
        {
            if( TOS_NODE_ID == FTSP_ROOT )
                ++(outgoingMsg->seqNum);
        }
        state &= ~STATE_SENDING;
    }

    void timeSyncMsgSend()
    {
		if (TOS_NODE_ID == FTSP_ROOT) 
		{
			
			if (timeFiredCount > ROOT_WAIT_COUNT && notSending) 
			{
			
				pr("msg sent\n");
				outgoingMsg->rootID = TOS_NODE_ID;
				post sendMsg();
			}
		}else if (outgoingMsg->rootID == FTSP_ROOT && notSending) 
		{
			post sendMsg();
		}
		
	}

    event void Timer.fired()
    {
    	++timeFiredCount;
		pr("timecount:%ld %d %d %ld entry:%d\n", \
			timeFiredCount, ROOT_WAIT_COUNT, state, noNewsFromRoot, numEntries);
		pr("TimeSyncMsg:rootID:%d, nodeID:%d, seqNum:%ld, globalTime:%ld, id:%d, localTime:%ld\n",\
			debugMsgBuffer.rootID, debugMsgBuffer.nodeID, debugMsgBuffer.seqNum, debugMsgBuffer.globalTime, debugMsgBuffer.id, debugMsgBuffer.localTime);
        timeSyncMsgSend();
    }

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
        processedMsg = &processedMsgBuffer;
        state = STATE_INIT;
        return SUCCESS;
    }

    event void Boot.booted()
    {
      call RadioControl.start();
      call StdControl.start();
    }

    command error_t StdControl.start()
    {
        outgoingMsg->nodeID = TOS_NODE_ID;
        call Timer.startPeriodic((uint32_t)1000 * BEACON_RATE);
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
    async command uint8_t   TimeSyncInfo.getHeartBeats() { return 0; }
	
	async command uint32_t TimeSyncInfo.getNoNewsFromRoot() {return noNewsFromRoot;}
    event void RadioControl.startDone(error_t error){}
    event void RadioControl.stopDone(error_t error){}
}
