

#include "SimpleSync.h"

configuration SimpleSyncC
{
  uses interface Boot;
  provides interface Init;
  provides interface StdControl;
  provides interface GlobalTime<TMilli>;
  provides interface TimeSyncInfo;
}

implementation
{
  components new SimpleSyncP(TMilli);

  GlobalTime      =   SimpleSyncP;
  StdControl      =   SimpleSyncP;
  Init            =   SimpleSyncP;
  Boot            =   SimpleSyncP;
  TimeSyncInfo    =   SimpleSyncP;

  components TimeSyncMessageC as ActiveMessageC;
  SimpleSyncP.RadioControl    ->  ActiveMessageC;
  SimpleSyncP.Send            ->  ActiveMessageC.TimeSyncAMSendMilli[AM_TIMESYNCMSG];
  SimpleSyncP.Receive         ->  ActiveMessageC.Receive[AM_TIMESYNCMSG];
  SimpleSyncP.TimeSyncPacket  ->  ActiveMessageC;

  components HilTimerMilliC;
  SimpleSyncP.LocalTime       ->  HilTimerMilliC;

  components new TimerMilliC() as TimerC;
  SimpleSyncP.Timer ->  TimerC;

#if defined(TIMESYNC_LEDS)
  components LedsC;
#else
  components NoLedsC as LedsC;
#endif
  SimpleSyncP.Leds  ->  LedsC;

#ifdef ENABLE_LOG
  components CLogGlobalC;
  SimpleSyncP.Log -> CLogGlobalC;
#endif

}

