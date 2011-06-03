#include "SerialStart.h"

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
}
