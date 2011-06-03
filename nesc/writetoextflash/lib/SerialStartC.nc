#include "SerialStart.h"
#include "StorageVolumes.h"

configuration SerialStartC {
  provides interface SerialStart;
} 
implementation {
  components MainC;
  components SerialActiveMessageC as AM;
  components SerialStartP;

  SerialStartP -> MainC.Boot; // it will start automatically
  SerialStartP.SerialAMSend -> AM.AMSend[AM_SERIAL_START_ID];
  SerialStartP.SerialAMReceive -> AM.Receive[AM_SERIAL_START_ID];
  SerialStartP.SerialControl -> AM;
  SerialStart = SerialStartP;
  
  components LedsC;
  SerialStartP.Leds -> LedsC;
  
  components new BlockStorageC(VOLUME_DELUGE1) as BlockStorageC_1;
  components new BlockStorageC(VOLUME_DELUGE2) as BlockStorageC_2;
  components new BlockStorageC(VOLUME_DELUGE3) as BlockStorageC_3;
  
  SerialStartP.SubBlockRead_1 -> BlockStorageC_1;
  SerialStartP.SubBlockRead_2 -> BlockStorageC_2;
  SerialStartP.SubBlockRead_3 -> BlockStorageC_3;
  
  SerialStartP.SubBlockWrite_1 -> BlockStorageC_1;
  SerialStartP.SubBlockWrite_2 -> BlockStorageC_2;
  SerialStartP.SubBlockWrite_3 -> BlockStorageC_3;
}
