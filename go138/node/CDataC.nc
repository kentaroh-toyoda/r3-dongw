/**
 *
 * @author Jiliang Wang
 * @author Yuan He
 * @author Wei Dong
 * @version 
 */

//#define DEBUG_
#include "constants.h"

#ifdef TEST_FTSP
	#include "TestFtsp.h"
#endif

#include "pr.h"
#include "logmsg.h"
#include "Diagnosis.h"


module CDataC 
{
	uses 
	{
		//split control
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		//timers
		interface Timer<TMilli> as SampleTimer;
		interface Timer<TMilli> as DutyTimer;
		interface Timer<TMilli> as SleepTimer;
		interface Timer<TMilli> as LedTimer;
		interface Timer<TMilli> as ClearSyncTimer;
		//ftsp
		interface Timer<TMilli> as CheckTimer;
		
		interface Timer<TMilli> as JustRebootTimer;
		
		interface Timer<TMilli> as IntervalTimer;
		interface Timer<TMilli> as FlashLedTimer;
		//interface Timer<TMilli> as TestTimer;

#ifndef TOSSIM		
#ifndef NOT_USING_READER

		//readers
		interface Read<uint16_t> as TempReader;
		interface Read<uint16_t> as HumidityReader;
		interface Read<uint16_t> as LightReader;
		interface Read<uint16_t> as VoltageReader;
#endif
#endif
		//communication
		interface AMSend as BroadcastSender;
		interface Receive as BroadcastReceiver;
		interface Packet as BeaconPacket;
		interface RootControl;
		interface StdControl as RoutingControl;
		interface Send as ReportSender;
		interface Intercept as ReportIntercepter;
		interface CtpInfo;
		interface DisseminationValue<config_struct_t> as Value;
		interface DisseminationUpdate<config_struct_t> as Update;
		
		//interface DisseminationValue<request_struct_t> as RequestValue;
		//interface DisseminationUpdate<request_struct_t> as RequstUpdate;
		
		interface StdControl as DisseminationControl;
		

#ifndef TOSSIM		
		interface CC2420Packet;
		interface CC2420SetPower;
#endif
		interface Random;
		// ftsp
		interface GlobalTime<TMilli>;
		interface TimeSyncInfo;
		//interface PacketTimeStamp<TMilli,uint32_t>;	
#ifdef ENABLE_LOG		
    interface CLogGlobal as Log;
#endif  

		interface RAMLog<uint16_t> as RAMLogNoAcks;		
		
		//Wei
		interface Diagnosis;
	}
	provides interface Init;
}
implementation 
{
	uint8_t uartlen;
	message_t sendbuf;
	bool sendbusy=FALSE;
	// COnfigurations for various timers
	uint32_t EntirePeriod = ENTIRE_CYCLE_TIME*1024UL;						//The EntirePeriod length of sleeping + on-duty
	uint32_t DutyRatio =5UL;					// DutyRatio/100 is the ratio of time on-duty to the EntirePeriod
	uint32_t DutyPeriod = 0UL;                  //what is this ??
	uint32_t SleepPeriod= SLEEP_DURATION*1024UL;	// All the time out of DutyPeriod is SleepPeriod
	uint32_t SampleInterval = 0UL;
	
	am_addr_t MoteId = 0;
	cdata_t   ReportData;
	cstatus_t StatusData;
	//am_addr_t PathNodes[PATH_LENGTH];
	
	message_t BeaconMsg; 	//buf for beacon message;
	message_t ReportMsg;	//buf for data msg;
	message_t StatusMsg;    //buf for status msg;
	message_t RequestStatusMsg; //buf for requeststatus msg;
	
	bool TempDone = FALSE;
	bool HumidityDone = FALSE;
	bool LightDone = FALSE;
	bool VoltageDone = FALSE;
	bool IsSyncWithRoot = FALSE;  //check if sync with root node.
	uint8_t radioAlwaysOn = 0;

	bool isBusy = FALSE;
	bool JustReboot = TRUE;

	bool time2SendEvent = FALSE;
	
	config_struct_t config;
	request_status_struct_t requestStatus;
//DEBUG 	
#ifdef TEST_FTSP
	message_t ftspmsg;
#endif 
	
	#include "myleds.h"
	
	//report problem function
	static void report_problem() 
	{ 
	#ifdef ENABLE_DEBUG_LED
		call Leds.led0Toggle(); 
	#endif
	}	

	void flashLed(uint8_t led, uint16_t time) 
	{
		//call Leds.led0On();
		setLeds(led);
		call FlashLedTimer.startOneShot(time);
	}

	event void FlashLedTimer.fired() 
	{
//		call Leds.led0Off();
		setLeds(0);
	}
	
	command error_t Init.init()
	{
		return SUCCESS;
	}
	
	event void Boot.booted() 
	{
		MoteId = TOS_NODE_ID;
		setLeds(1);
		memset(&ReportData, 0, sizeof(ReportData));// sizeof(uint8_t), 0);
		call LedTimer.startOneShot(5000);	// turn off the timer after 5 seconds.
		pr("boot\n"); 
		//LOGMSG(LOGMSG_BOOT);
		call RAMLogNoAcks.setValue(0);
		INSERT_EVENT(EVENT_BOOT);
		
		if ( call RadioControl.start() != SUCCESS) 
		{
			fatalProblem();
		}
		JustReboot = TRUE;

	}
	
	event void RadioControl.startDone(error_t error) 
	{
		if (error != SUCCESS) {
			fatalProblem();
			call RadioControl.start();
		}
		else
		{
			//start routing control for CTP
			INSERT_EVENT(EVENT_RADIO_ON);
			
			call RoutingControl.start();
			call DisseminationControl.start();
		}
	}
	
	
	event void LedTimer.fired()
	{
		//setLeds(0);
		//pr("initial start check\n");
#ifdef ENABLE_DEBUG_LED		
		DEBUG_LED(2);
#else
		setLeds(0);
#endif
		//LOGMSG(111);

        call CheckTimer.startOneShot(CHECK_INTERVAL);
	
	}
	
	event void JustRebootTimer.fired() 
	{
		//pr("Just reboot timer fired\n");
		JustReboot = FALSE;
		ERASE_LOG();
	}
	
	uint32_t timetosleep() {
		uint32_t mytime = call GlobalTime.getLocalTime();
		uint32_t nexttime;
		call GlobalTime.local2Global(&mytime); // is synced
		if (mytime == INVALID_TIME) 
		{
			return INVALID_TIME;
		}
		// time is now global
		nexttime = EntirePeriod * ( 1+mytime/EntirePeriod );
		pr("next=%lu, time=%lu\n", nexttime,mytime);
		return EntirePeriod - mytime % EntirePeriod; // next time may overflow		
	}
	uint32_t randtime(uint32_t mytime) {
		return mytime/10 + call Random.rand32() % (mytime*19/20);
	}

	event void CheckTimer.fired()
	{
		uint32_t noNewsFromRoot = call TimeSyncInfo.getNoNewsFromRoot();
		uint32_t localtime = call GlobalTime.getLocalTime();
		error_t is_synced = call GlobalTime.local2Global(&localtime);
		uint8_t rootID = call TimeSyncInfo.getRootID();
		pr("\n****\nCheckTimer: root=%d %d justreboot=%d JUST_REBOOT_TIME:%ld\n",rootID, is_synced, JustReboot, JUST_REBOOT_TIME);
//		LOGMSG(112);
		if (rootID == FTSP_ROOT && is_synced == SUCCESS && JustReboot) 
		{
			if ( !call JustRebootTimer.isRunning())
			{
				call JustRebootTimer.startOneShot(JUST_REBOOT_TIME);
			}
		}
		
		if (rootID == FTSP_ROOT && is_synced == SUCCESS) 
		{
			// start duty cycling
			uint32_t iv = timetosleep();
			uint32_t riv = randtime(iv);
			pr("timetosleep: %lu. randtime:%lu, nowNews:%ld\n", iv, riv, noNewsFromRoot);
			if (iv == INVALID_TIME || noNewsFromRoot > TIMESYNC_NO_NEWS_FROM_ROOT_THR || iv > ENTIRE_CYCLE_TIME*1024) 
			{
				call CheckTimer.startOneShot(CHECK_INTERVAL);				
			}else {
				call DutyTimer.startOneShot(iv);				// Time to go to sleep
				call SampleTimer.startOneShot(riv);				// Time to report data	
			}
			return;
		}
		// check again
		pr("not sync[rootid=%d]\n", rootID);
		flashLed(1, 500);
		call CheckTimer.startOneShot(CHECK_INTERVAL);
	}


	event void ClearSyncTimer.fired()		// sleep now
	{
	 	IsSyncWithRoot = FALSE;
	 	call RAMLogNoAcks.setValue(0); 
	}
	
	
	event void DutyTimer.fired()		// sleep now
	{
#ifdef TEST_FTSP
		uint32_t gtime;
		
		test_ftsp_msg_t *report = (test_ftsp_msg_t*)
		                           call BeaconPacket.getPayload(&ftspmsg, sizeof(test_ftsp_msg_t));
		
		call GlobalTime.getGlobalTime(&gtime);
		
		report->src_addr = TOS_NODE_ID;
		report->counter = 0;
		report->local_rx_timestamp = 0;
		report->global_rx_timestamp = gtime;
		call BroadcastSender.send(AM_BROADCAST_ADDR, &ftspmsg, sizeof(test_ftsp_msg_t));
#endif
		

		pr("DutyTimer: go to sleep (%lu)\n", SleepPeriod);
		//stop all components except the processor
		
		if (radioAlwaysOn != 1 && !JustReboot) {
//			LOGMSG(LOGMSG_SLEEP);
			call RadioControl.stop();
			setLeds(0);
		}
		//start the timer to wakeup from sleep
		call SleepTimer.startOneShot(SleepPeriod);	
	}
	
	event void SleepTimer.fired()		//wakeup now
	{
		//call DutyTimer.startOneShot(DutyPeriod);				// Time to go to sleep		
#ifdef TEST_FTSP		
		uint32_t gtime;
		
		test_ftsp_msg_t *report = (test_ftsp_msg_t*)
		                           call BeaconPacket.getPayload(&ftspmsg, sizeof(test_ftsp_msg_t));
		
		call GlobalTime.getGlobalTime(&gtime);
		
		//setLeds(4);
		report->src_addr = TOS_NODE_ID;
		report->counter = 1;
		report->local_rx_timestamp = 0;
		report->global_rx_timestamp = gtime;
		call BroadcastSender.send(AM_BROADCAST_ADDR, &ftspmsg, sizeof(test_ftsp_msg_t));
#endif
		pr("SleepTimer: wakeup\n");
		// go to sleep after synced
		
		call CheckTimer.startOneShot(CHECK_INTERVAL);
		//LOGMSG(LOGMSG_WAKEUP);
		
		call RadioControl.start();
		DEBUG_LED(4);
	}
	
	void BroadcastMsg(message_t* msg, uint8_t size) 
	{
		call BroadcastSender.send(AM_BROADCAST_ADDR, msg, sizeof(beacon_message_t));
	}	
	void Beacon() 
	{
		beacon_message_t* temp = (beacon_message_t*) (call BeaconPacket.getPayload(&BeaconMsg, 0));
		temp->moteid = MoteId;
		BroadcastMsg(&BeaconMsg, sizeof(beacon_message_t));
	}
	

	
	void UpdateRssi(message_t* msg, void* payload, uint8_t len)
	{

		uint8_t rssi; 
		uint8_t lqi;
		beacon_message_t* temp = (beacon_message_t*)payload;
		am_addr_t tempId = temp->moteid;
		uint8_t tNum = 0;
		
#ifndef TOSSIM
		rssi = call CC2420Packet.getRssi(msg);
		lqi  = call CC2420Packet.getLqi(msg);
#else
		rssi = 180; lqi = 100;
#endif
		
		for (; tNum < NEIGHBOR_SIZE && tNum < StatusData.neighborSize; ++tNum) 
		{
			if (StatusData.neighbor2Info[tNum].id == tempId) 
			{
				StatusData.neighbor2Info[tNum].lqi=lqi;
				StatusData.neighbor2Info[tNum].rssi = rssi;
				return;
			}
		}
		if (StatusData.neighborSize < NEIGHBOR_SIZE) 
		{
			StatusData.neighbor2Info[StatusData.neighborSize].id = tempId;
			StatusData.neighbor2Info[StatusData.neighborSize].rssi = rssi;
			StatusData.neighbor2Info[StatusData.neighborSize].lqi=lqi;
			StatusData.neighborSize++;
		}
		return;
	}
	
	event message_t* BroadcastReceiver.receive(message_t* msg, void* payload, uint8_t len)
	{
		//Update the rssi value based on the received msg;
		UpdateRssi(msg, payload, len);
		return msg;
	}
	
	void ReportDataMsg()
	{
		cdata_t* temp = NULL;
		am_addr_t parent;
		error_t r;
		uint32_t timestamp;
		
		if (MoteId == ROOT_ID) 
		{
			return;
		}
		temp = (cdata_t*)(call ReportSender.getPayload(&ReportMsg, 0));
		ReportData.type = DATA_MSG_TYPE;
		memcpy(temp, &ReportData, sizeof(cdata_t));
		//Wei: add parent field
		r = call CtpInfo.getParent(&parent);
		if (r == SUCCESS) {
			temp->parent = parent;
		} else {
			temp->parent = 0xffff;
		}
		// add global time
		r = call GlobalTime.getGlobalTime(&timestamp);
		if (r == SUCCESS) {
			temp->timestamp = timestamp;
		} else {
			temp->timestamp = -1;
		}
		// add aggregate data
		temp->noAcks = call RAMLogNoAcks.getValue();
		
		
		pr("par = %d [error=%d]\n", parent, r);
		
				
		if (call ReportSender.send(&ReportMsg, sizeof(cdata_t)) != SUCCESS) 
		{
			//pr("fatalProblem in ReportSender  data send\n");
		//	fatalProblem();
		}
		else
		{
			uint32_t mytime;
			//toggle(2);

			//debug
			isBusy = TRUE;
			
			call GlobalTime.getGlobalTime(&mytime);
			//LOGMSG3(REPORT_PATH_MSG, mytime, parent, 0);
			pr("send msg %lu\n", mytime);
		}
	}
	
	void ReportStatusMsg() 
	{
		cstatus_t* temp = NULL;
		error_t r;
		uint32_t timestamp;
		uint8_t size;
		uint8_t i,j,nn;
		

		if (MoteId == ROOT_ID) 
		{
			return;
		}
		
		nn = call CtpInfo.numNeighbors();
		
		// donot change the neighborSize
		size = getStatusMsgSize(&StatusData);
		
		for (i=0; i<StatusData.neighborSize && i < NEIGHBOR_SIZE; i++) {
			am_addr_t id = StatusData.neighbor2Info[i].id;
			// TRY to find a matching address
			bool matching = FALSE;
			
			for (j=0; j<nn && j < NEIGHBOR_SIZE; j++) {
				am_addr_t addr = call CtpInfo.getNeighborAddr(j);
				if (addr == id) {
				  matching = TRUE;
				  break;		
				}	
			}
			
			if (matching) {
				StatusData.neighbor2Info[i].etx = (call CtpInfo.getNeighborLinkQuality(j) >> 2);
			}
			else {
				StatusData.neighbor2Info[i].etx = 0;
			}
			
		}
		
		temp = (cstatus_t*)(call ReportSender.getPayload(&StatusMsg, 0));	
		StatusData.type = STATUS_MSG_TYPE;
		if (size > call ReportSender.maxPayloadLength()) 
		{
			return;
		}
		memcpy(temp, &StatusData, size);
		r = call GlobalTime.getGlobalTime(&timestamp);
		if (r == SUCCESS) {
			temp->timestamp = timestamp;
		} else {
			temp->timestamp = -1;
		}

		//pr("In ReportStatusMsg..., isBusy=%d\n", isBusy);
		if (call ReportSender.send(&StatusMsg, size) != SUCCESS) 
		{
			//pr("fatalProblem in ReportSender status send. size:%d, error:%d\n", size, r);
			fatalProblem();
		}
		else
		{
			//debug
			isBusy = TRUE;
			//LOGMSG3(REPORT_NEIGHBOR_MSG, timestamp, 0, 0);
		}
	}
	
	
	void ReportRequestStatusMsg() 
	{
		request_status_struct_t* temp = NULL;
		error_t r;
		uint32_t timestamp = -1;
		uint8_t size = sizeof(request_status_struct_t);
		if (MoteId == ROOT_ID) 
		{
			return;
		}
		temp = (request_status_struct_t*)(call ReportSender.getPayload(&RequestStatusMsg, 0));	
		requestStatus.type = REQUEST_STATUS_MSG_TYPE;
		memcpy(temp, &requestStatus, size);
		r = call GlobalTime.getGlobalTime(&timestamp);
		temp->timestamp = timestamp;
		/*
		if (r == SUCCESS) {
			temp->timestamp = timestamp;
		} else {
			temp->timestamp = -1;
		}
		*/
		pr("In Report Requst StatusMsg, isBusy=%d\n", isBusy);
		if (call ReportSender.send(&RequestStatusMsg, size) != SUCCESS) 
		{
//			fatalProblem();
		}
		else
		{
			isBusy = TRUE;
		}
	
	}
	task void ReportMsgToRoot() 
	{
		ReportDataMsg();
	}


	event void SampleTimer.fired() 
	{
		//setLeds(0);
		pr("Sample fired\n");
		Beacon();	// When sample timer fires, first broadcast a beacon so that all neighbors that hear it can update RSSI.
#ifdef TOSSIM	

#else

#ifndef NOT_USING_READER
		call TempReader.read();
		call HumidityReader.read();
		call LightReader.read();
		call VoltageReader.read();	
#else 
	//report data to sink while not using sensors.
		post ReportMsgToRoot();
#endif

#endif
	}
	
	void ClearDataMsg() 
	{
		memset(&ReportData, 0, sizeof(ReportData));
	}
	
	void ClearStatusMsg() 
	{
		HumidityDone = FALSE;
		TempDone = FALSE;
		LightDone = FALSE;
		VoltageDone=FALSE;
		memset(&StatusData, 0, sizeof(StatusData));
	}
	
	event void ReportSender.sendDone(message_t* msg, error_t error) 
	{
		void* payload = call ReportSender.getPayload(msg, 0);
		uint8_t type = getReportMsgType(payload);

		//debug
		isBusy = FALSE;

		switch(type)
		{
			case DATA_MSG_TYPE:
			{
				ClearDataMsg();
				time2SendEvent = FALSE;
				call IntervalTimer.startOneShot(2000);
				break;
			}
			case STATUS_MSG_TYPE:
				ClearStatusMsg();
				time2SendEvent = TRUE;
				call IntervalTimer.startOneShot(2000);
				break;
			default:
				break;
		}
	}
	
	event void IntervalTimer.fired() 
	{
		error_t e ;
		if (time2SendEvent) 
		{
			e = REPORT_EVENT();
			//flashLed((uint8_t)e, 500);
			pr("REPORT EVENT:%d\n", e);
		}else {
			ReportStatusMsg();
		}
	}
	
	event bool ReportIntercepter.forward(message_t* msg, void* payload, uint8_t len) 
	{
		//Add the path info, and always relay this packet.
		uint8_t type = getReportMsgType(payload);
		cdata_t* temp = (cdata_t*)payload;
		uint8_t sendId = ((uint8_t*)payload)[-3];
		pr("forward [message type:%d, len:%d(%d), sendId:%d]\n", type, len, sizeof(cdata_t), sendId);
		switch(type)
		{
			case DATA_MSG_TYPE:
				if (temp->pathlength < PATH_LENGTH) 
				{
					temp->nodesOnPath[temp->pathlength] = MoteId;
					temp->pathlength++;
					call BeaconPacket.setPayloadLength(msg,
					call BeaconPacket.payloadLength(msg)+sizeof(am_addr_t));
				}
				break;
			case STATUS_MSG_TYPE:
				//return TRUE;
				break;
			default:
				break;
		}
		return TRUE;
	}
	
	
	/*
	typedef nx_struct ConfigStruct
	{
		nx_uint8_t message_type;
		nx_am_addr_t targetId;
		nx_uint16_t dutyratio;
		nx_uint8_t radioalwayson;
	}config_struct_t;
*/
	
	void configValue(const config_struct_t* newVal) 
	{	
		if (newVal->message_type != CONFIG_MSG_TYPE) 
		{
			return;
		}
		if (newVal->sleeptime != 0xffff) 
		{
			SleepPeriod = newVal->sleeptime;
			SleepPeriod *= 1024UL;
		}
		
		if (newVal->entiretime != 0xffff) 
		{
			EntirePeriod = newVal->entiretime;
			EntirePeriod *= 1024UL;
		}
		/*if (newVal->dutyratio != 0xffff) 
		{
			DutyRatio = newVal->dutyratio;
			if (DutyRatio==0)	// DutyRatio==0 means to stop dutycycling mechanisms, so stop the timers(wrong?)
			{
				radioAlwaysOn = TRUE;
				return;
			}
			DutyPeriod 	= EntirePeriod * DutyRatio / 100UL;
			SleepPeriod = EntirePeriod - DutyPeriod;
			SampleInterval = call Random.rand32() % (DutyPeriod*8UL/10UL) + DutyPeriod/10UL;
			return;
		}*/
		
		if (newVal->radioalwayson != 0xff) 
		{
			radioAlwaysOn = newVal->radioalwayson;
		}
		/*if (newVal->message_type == SAMPLE_INTERVAL_MESSAGE) 
		{
			//update the length of EntirePeriod and then start new timers
			setLeds(newVal->message_type);
			EntirePeriod= 1024UL * (newVal->data1);
			DutyPeriod 	= EntirePeriod * DutyRatio / 100UL;
			SampleInterval = call Random.rand32() % (DutyPeriod*8UL/10UL) + DutyPeriod/10UL;
			return;
		}	
		else if (newVal->message_type == POWER_SET_MESSAGE) 
		{
		#ifndef TOSSIM
			call CC2420SetPower.setPower((uint8_t)newVal->data);
		#endif
			return;
		}
		else if (newVal->message_type == DUTYCYCLE_MESSAGE) // update the duty cycle and then start new timers
		{
			DutyRatio = newVal->data1;//just update the value of DutyRatio, but do not restart timers.
			if (DutyRatio==0)	// DutyRatio==0 means to stop dutycycling mechanisms, so stop the timers(wrong?)
			{
				radioAlwaysOn = TRUE;
				return;	
			}
			DutyPeriod 	= EntirePeriod * DutyRatio / 100UL;
			SleepPeriod = EntirePeriod - DutyPeriod;
			SampleInterval = call Random.rand32() % (DutyPeriod*8UL/10UL) + DutyPeriod/10UL;
			return;
		}
		else if (newVal->message_type == START_RADIO) {
			radioAlwaysOn = TRUE;
			pr("radioAlwaysOn true\n");
		}
		else if (newVal->message_type == STOP_RADIO) {
			radioAlwaysOn = FALSE;
			pr("radioAlwaysOn false\n");
		}
		*/
	}
	
	event void Value.changed() 
	{
		const config_struct_t* newVal = call Value.get();
		DEBUG_LED(newVal->message_type);
		pr("New Value:%d:%d:%d", newVal->sleeptime, newVal->entiretime, newVal->radioalwayson);
		configValue(newVal);
	}
	
	/*event void RequestValue.changed() 
	{
		
		const request_struct_t* newVal = call RequestValue.get();
		if (newVal->targetId != 0xffff && newVal->targetId != TOS_NODE_ID) 
		{
			return;
		}
		requestStatus.type = REQUEST_STATUS_MSG_TYPE;
		requestStatus.id = TOS_NODE_ID;
		requestStatus.radioalwayson = radioAlwaysOn;
		requestStatus.dutyratio = DutyRatio;
		ReportRequestStatusMsg();
		
	}
	*/
	
	bool DataReady() 
	{
		return (HumidityDone && TempDone && LightDone && VoltageDone);
	}

#ifndef TOSSIM
#ifndef NOT_USING_READER
	
	event void TempReader.readDone(error_t result, uint16_t data)
	{
		if (result != SUCCESS) 
		{
			ReportData.temperature = 0xffff;
		}
		else
		{
			ReportData.temperature = data;
		}
		TempDone = TRUE;
		if (DataReady()) 
		{
			post ReportMsgToRoot();
		}
	}
	
	event void HumidityReader.readDone(error_t result, uint16_t data) 
	{
		if (result != SUCCESS) 
		{
			ReportData.humidity = 0xffff;
		}
		else
		{
			ReportData.humidity = data;
		}
		HumidityDone = TRUE;
		if (DataReady()) 
		{
			post ReportMsgToRoot();
		}
	}
	
	event void LightReader.readDone(error_t result, uint16_t data) 
	{
		if (result != SUCCESS) 
		{
			ReportData.light = 0xffff;
		}
		else
		{
			ReportData.light = data;
		}
		LightDone = TRUE;		
		if (DataReady()) 
		{
			post ReportMsgToRoot();
		}
	}
	event void VoltageReader.readDone(error_t result, uint16_t data) 
	{
		if (result != SUCCESS) 
		{
			ReportData.ADC_Voltage = 0xffff;
		}
		else
		{
			ReportData.ADC_Voltage = data;
		}
		VoltageDone = TRUE;		
		if (DataReady()) 
		{
			post ReportMsgToRoot();
		}
	}

#endif
#endif
	
	event void BroadcastSender.sendDone(message_t* msg, error_t error) { //Add code to deal with error.
	}
	
	event void RadioControl.stopDone(error_t error) {
		INSERT_EVENT(EVENT_RADIO_OFF);
		}
}
