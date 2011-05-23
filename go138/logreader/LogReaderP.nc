#include "logmsg.h"
#include "../lib/pr.h"

module LogReaderP {
  uses {
    interface Leds;
    interface Boot;
    interface Timer<TMilli>;
    interface LogRead;
    interface LogWrite;
  }
}
implementation {
  logmsg_t logmsg;

  /******** Declare Tasks *******************/
  task void readLog();

  /************ Boot Events *****************/
  event void Boot.booted() {
  	if (TOS_NODE_ID == 0) {
  		call LogWrite.erase();
  	}
  	else {
      call Timer.startPeriodic(200);
    }
  }
  
  event void Timer.fired() {
  	post readLog();
  }

  task void readLog() {
    if (call LogRead.read(&logmsg, sizeof(logmsg_t)) != SUCCESS) {
      post readLog();
    } else {
    } 
  } 


  event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {
    // send it to pc
    if ( (len == sizeof(logmsg_t)) && (buf == &logmsg)) {
    	if (sizeof(log_arg_t)==4) pr("%lu %u %lu %lu %lu\n", logmsg.timestamp, logmsg.type, logmsg.arg1, logmsg.arg2, logmsg.arg3);
        else pr("%lu %u %u %u %u\n", logmsg.timestamp, logmsg.type, logmsg.arg1, logmsg.arg2, logmsg.arg3);
    	post readLog();
    }
    else {
      // handle error?
      call Leds.led2On();
      //pr("finish reading\n");
    }
  }

  event void LogWrite.appendDone(void* buf, storage_len_t len, bool lost, error_t err) {}
  event void LogWrite.eraseDone(error_t result) { call Leds.led0On(); }
  event void LogWrite.syncDone(error_t result) {}
  event void LogRead.seekDone(error_t error) {}
}

