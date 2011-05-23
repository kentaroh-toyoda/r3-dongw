/**
 *
 * @author Jiliang Wang
 * @author Yuan He
 * @version 
 */
#include "mymsg.h"
configuration CDataAppC{
}
implementation {
	components MainC, LedsC, CDataC;
	CDataC.Boot->MainC;
	CDataC.Leds->LedsC;
	
	components new TimerMilliC() as Timer3;
	CDataC.LedTimer ->Timer3;
	
	components ActiveMessageC;
	
	components SerialActiveMessageC;
	CDataC.RadioControl->ActiveMessageC;
	CDataC.SerialControl->SerialActiveMessageC;
	CDataC.SerialRecv->SerialActiveMessageC.Receive[AM_REPORT];
	//	the following 4 lines allocate buffer
	components new PoolC(message_t, 10) as UARTMessagePoolP,
    new QueueC(message_t*, 10) as UARTQueueP;
	CDataC.UARTMessagePool -> UARTMessagePoolP;
	CDataC.UARTQueue -> UARTQueueP;
	
	components new SerialAMSenderC(AM_REPORT);   // Sends to the serial port
	CDataC.SerialSender->SerialAMSenderC;
	
	components CollectionC as Collector;
	components new CollectionSenderC(AM_REPORT);
	CDataC.ReportReceiver->Collector.Receive[AM_REPORT];
	CDataC.RootControl->Collector;
	CDataC.RoutingControl->Collector;
	
	components DisseminationC;
	components new DisseminatorC(config_struct_t, DIS_SOME_COMPONENT_KEY);
	components new DisseminatorC(request_struct_t, DIS_REQUEST_COMPONENT_KEY) as RequestDisseminator;


	CDataC.DisseminationControl->DisseminationC;
	CDataC.Value->DisseminatorC;
	CDataC.Update->DisseminatorC;
	CDataC.RequestValue->RequestDisseminator;
	CDataC.RequstUpdate->RequestDisseminator;
	//components RandomC;
	//CDataC.Random -> RandomC;	
	
	components TimeSyncC;
	MainC.SoftwareInit -> TimeSyncC;
	TimeSyncC.Boot -> MainC;

	//CDataC.PacketTimeStamp -> ActiveMessageC;
	CDataC.GlobalTime -> TimeSyncC;
	CDataC.TimeSyncInfo -> TimeSyncC;

	//watchdog
	components new WatchdogC() as WatchdogSinkC;
	components new TimerMilliC() as Timer4;
	CDataC.WatchdogSink -> WatchdogSinkC;
	CDataC.WatchdogTimer -> Timer4;

}
