/**
 *
 * @author Jiliang Wang
 * @author Yuan He
 * @version 
 */
 
#include "mymsg.h"
#include "StorageVolumes.h"

configuration CDataAppC{
}
implementation {
	components MainC, LedsC, CDataC;
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	components new TimerMilliC() as Timer2;
	components new TimerMilliC() as Timer3;
	components new TimerMilliC() as Timer4;
	components new TimerMilliC() as Timer5;
	components new TimerMilliC() as Timer6;
	components new TimerMilliC() as Timer7;
	components new TimerMilliC() as Timer8;
	
	CDataC.Boot->MainC;
	CDataC.Leds->LedsC;
	
	CDataC.SampleTimer->Timer0;
	CDataC.DutyTimer ->Timer1;
	CDataC.SleepTimer->Timer2;
	CDataC.LedTimer ->Timer3;
	CDataC.CheckTimer -> Timer4;
	CDataC.ClearSyncTimer->Timer5;
	CDataC.JustRebootTimer->Timer6;
	CDataC.IntervalTimer->Timer7;
	CDataC.FlashLedTimer->Timer8;
	//CDataC.TestTimer -> Timer6;

#ifndef TOSSIM
#ifndef NOT_USING_READER
	components new SensirionSht11C() as TemperatureSensor;
	components new SensirionSht11C() as HumiditySensor;
	components new VoltageC() as VoltageSensor;
	
	//components HumidityC as HumidityReader;
	components new HamamatsuS1087ParC() as LightSensor;
	CDataC.TempReader->TemperatureSensor.Temperature;
	CDataC.HumidityReader->HumiditySensor.Humidity;
	CDataC.LightReader->LightSensor.Read;
	CDataC.VoltageReader->VoltageSensor.Read;	
#endif
#endif
	
	components new AMSenderC(AM_BEACON) as BeaconSender;
	components new AMReceiverC(AM_BEACON) as BeaconReceiver;
	components ActiveMessageC;
	
	CDataC.RadioControl->ActiveMessageC;
	CDataC.BeaconPacket->BeaconSender;
	CDataC.BroadcastSender->BeaconSender;
	CDataC.BroadcastReceiver->BeaconReceiver;
	
	components CollectionC as Collector;
	components new CollectionSenderC(AM_REPORT);
	CDataC.ReportSender->CollectionSenderC;
	CDataC.ReportIntercepter->Collector.Intercept[AM_REPORT];
	CDataC.RoutingControl->Collector;
	CDataC.CtpInfo -> Collector;
	
#ifndef TOSSIM	
	components CC2420PacketC;
	CDataC.CC2420Packet->CC2420PacketC;
#endif
	
	components DisseminationC;
	components new DisseminatorC(config_struct_t, DIS_SOME_COMPONENT_KEY);
	components new DisseminatorC(request_struct_t, DIS_REQUEST_COMPONENT_KEY) as RequestDisseminator;
	
	CDataC.DisseminationControl->DisseminationC;
	CDataC.Value->DisseminatorC;
	CDataC.Update->DisseminatorC;
	
	//CDataC.RequestValue->RequestDisseminator;
	//CDataC.RequstUpdate->RequestDisseminator;

#ifndef TOSSIM	
	components CC2420TransmitC;
	CDataC.CC2420SetPower->CC2420TransmitC.CC2420SetPower;
#endif

	components RandomC;
	CDataC.Random -> RandomC;
	
	components SimpleSyncC;
	MainC.SoftwareInit -> SimpleSyncC;
	SimpleSyncC.Boot -> MainC;

	CDataC.GlobalTime -> SimpleSyncC;
	CDataC.TimeSyncInfo -> SimpleSyncC;
  
#ifdef ENABLE_LOG	
	components CLogGlobalC;
	CDataC.Log -> CLogGlobalC;
#endif	

  components RAMLogNoAcksC;
  CDataC.RAMLogNoAcks -> RAMLogNoAcksC;
  
  
  components DiagnosisC;
  CDataC.Diagnosis -> DiagnosisC;
}

