#include "logmsg.h"
#include "StorageVolumes.h"

configuration LogReaderC {}
implementation {
  components MainC;
  components LogReaderP as App;
  components LedsC;
  components new TimerMilliC() as TimerC;
  components new LogStorageC(VOLUME_LOGTEST, FALSE);
  
  
  App.Boot -> MainC.Boot;
  App.Leds -> LedsC;
  App.Timer -> TimerC;
  App.LogRead -> LogStorageC;
  App.LogWrite -> LogStorageC;
}
