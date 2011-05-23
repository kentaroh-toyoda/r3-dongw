/**
 *
 * @author Jiliang Wang
 * @author Yuan He
 * @version 
 */
#define DEBUG_
#define ROOT_ID 1
#define TRANS_POWER 2
#define WATCHDOG_INTERVAL 1024*10
#include "Ctp.h"
module CDataC 
{
	uses 
	{
		//split control
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		interface SplitControl as SerialControl;
		interface Timer<TMilli> as LedTimer;	
		
		//communication
		interface AMSend as SerialSender;
		interface Receive as SerialRecv;
		
		interface RootControl;
		interface StdControl as RoutingControl;
		interface Receive as ReportReceiver;
		
		//buffer for UART
		interface Queue<message_t *> as UARTQueue;
		interface Pool<message_t> as UARTMessagePool;
	
		interface DisseminationValue<config_struct_t> as Value;
		interface DisseminationUpdate<config_struct_t> as Update;
		interface StdControl as DisseminationControl;
		
		
		interface DisseminationValue<request_struct_t> as RequestValue;
		interface DisseminationUpdate<request_struct_t> as RequstUpdate;
		
		//interface Random;
		
		// ftsp
		interface GlobalTime<TMilli>;
		interface TimeSyncInfo;
		//interface PacketTimeStamp<TMilli,uint32_t>;	
		
		//watchdog timer
		interface Watchdog as WatchdogSink;
		interface Timer<TMilli> as WatchdogTimer;	
	}
	provides interface Init;
}
implementation 
{
	uint8_t uartlen;
	message_t sendbuf;
	message_t uartbuf;
	bool uartbusy=FALSE;
	uint8_t MoteId = 0;
	cdata_t ReportData;
	message_t BeaconMsg; 	//buf for beacon message;
	message_t ReportMsg;	//buf for collected msg;
	
	config_struct_t config;
	request_struct_t requestMsg;
	#include "myleds.h"
	
	//report problem function
	static void report_problem() { call Leds.led0Toggle(); }	
	
	command error_t Init.init()
	{
		return SUCCESS;
	}
	
	event void Boot.booted() 
	{
		MoteId = TOS_NODE_ID;
		setLeds(1);
		memset(&ReportData, 0, sizeof(ReportData));
		if ( call RadioControl.start() != SUCCESS) 
		{
			fatalProblem();
		}
		
		//start WatchdogTimer
		call WatchdogTimer.startPeriodic(WATCHDOG_INTERVAL);
		call WatchdogSink.enable(WATCHDOG_INTERVAL*2); 
	}
	
	event void RadioControl.startDone(error_t error) 
	{
		if (error != SUCCESS) {
			fatalProblem();
			call RadioControl.start();
		}else {
			call SerialControl.start();			
		}
	}
	event void LedTimer.fired()
	{
		setLeds(0);
	}
	
	event void SerialControl.startDone(error_t error) 
	{
		if (error != SUCCESS)
		{
			fatalProblem();
			call SerialControl.start();
		}
		else 
		{
			//start routing control for CTP
			call RoutingControl.start();
			call DisseminationControl.start();
			
			call LedTimer.startOneShot(5000);	// turn off the timer after 5 seconds.
			
			call RootControl.setRoot();
		}
	}
	task void SendToComputer() 
	{
		if (call SerialSender.send(0xffff, &uartbuf, uartlen) != SUCCESS)
		{
			report_problem();
		} 
		else 
		{
			uartbusy = TRUE;
		}
	}
	
	event void SerialSender.sendDone(message_t* msg, error_t error) 
	{
		uartbusy = FALSE;
		if (call UARTQueue.empty() == FALSE) 
		{
			// We just finished a UART send, and the uart queue is
			// non-empty.  Let's start a new one.
			message_t *queuemsg = call UARTQueue.dequeue();
			if (queuemsg == NULL) 
			{
				fatalProblem();
				return;
			}
			memcpy(&uartbuf, queuemsg, sizeof(message_t));
			if (call UARTMessagePool.put(queuemsg) != SUCCESS) 
			{
				fatalProblem();
				return;
			}
			post SendToComputer();
		}
	}
	
	event message_t* ReportReceiver.receive(message_t* msg, void* payload, uint8_t len) 
	{
		uartlen = len + sizeof(ctp_data_header_t);
		if (uartbusy == FALSE) 
		{
			memcpy(&uartbuf, msg, sizeof(message_t));
			post SendToComputer();
		} 
		else 
		{
			// The UART is busy; queue up messages and service them when the
			// UART becomes free.
			message_t *newmsg = call UARTMessagePool.get();
			if (newmsg == NULL) 
			{
				// drop the message on the floor if we run out of queue space.
				report_problem();
				return msg;
			}
			memcpy(newmsg, msg, sizeof(message_t));
			if (call UARTQueue.enqueue(newmsg) != SUCCESS) 
			{
				// drop the message on the floor and hang if we run out of
				// queue space without running out of queue space first (this
				// should not occur).
				call UARTMessagePool.put(newmsg);
				fatalProblem();
				return msg;
			}
		}
		return msg;
	}
	
	event void RadioControl.stopDone(error_t error) 
	{
		
	}
	
	event void SerialControl.stopDone(error_t error) 
	{
		
	}
	
	 event message_t* SerialRecv.receive(message_t* msg, void* payload, uint8_t len) 
	{
		uint8_t type = ((uint8_t*)payload)[0];
		if (type == CONFIG_MSG_TYPE && len == sizeof(config_struct_t)) //configuration msg
		{		
			setLeds(((uint8_t*)payload)[0]);

			memcpy(&config, payload, sizeof(config_struct_t));
			call Update.change(&config);
		}
		else if (type == REQUEST_STATUS_MSG_TYPE && len == sizeof(request_struct_t)) //request msg
		{
			memcpy(&requestMsg, payload, sizeof(request_struct_t));
			call RequstUpdate.change(&requestMsg);
		}
		return msg;
	}
			
	event void Value.changed() 
	{
		//const config_struct_t* newVal = call Value.get();
	}
	
	event void RequestValue.changed() {}

	//added by chentao 20090806
	event void WatchdogSink.fired(bool guilty)
	{
		// guilty is TRUE if WatchdogSendMsg did not met its deadline
	}

	event void WatchdogTimer.fired()
	{
		call WatchdogSink.touch();
	}

}
