#include "../include/logmsg.h"

module CLogGlobalP {
	provides interface CLogGlobal;
	uses interface LogRead;
	uses interface LogWrite;
	uses interface GlobalTime<TMilli>;
	uses interface TimeSyncInfo;
}
implementation {
  logmsg_t logmsgbuf[LOGMSG_SIZE];
  uint8_t logmsgidx = 0;	
  

	command void CLogGlobal.logmsg3(uint16_t type, 
	        log_arg_t arg1, log_arg_t arg2, log_arg_t arg3) 
	{
		error_t r;
		uint32_t mytime;
		if (logmsgidx >= LOGMSG_SIZE) return;
		
		r = call GlobalTime.getGlobalTime(&mytime);
		
		logmsgbuf[logmsgidx].timestamp = mytime;
		logmsgbuf[logmsgidx].type = type;
		logmsgbuf[logmsgidx].arg1 = arg1;
		logmsgbuf[logmsgidx].arg2 = arg2;
		logmsgbuf[logmsgidx].arg3 = arg3;
		logmsgidx++;
		if (logmsgidx >= LOGMSG_SIZE) {
                  r = call LogWrite.append(logmsgbuf, sizeof(logmsg_t)*LOGMSG_SIZE);
                  //pr("w %d %d\n", r, sizeof(logmsg_t)*LOGMSG_SIZE);
 	 	}	
	}
	
	command void CLogGlobal.logmsg(uint16_t type) {
		call CLogGlobal.logmsg3(type, 0, 0, 0);
	}
	
	command void CLogGlobal.erase() {
		call LogWrite.erase();
	}
	
	event void LogRead.readDone(void* msg, storage_len_t len, error_t err) {
  	//??
  }
	
	event void LogWrite.appendDone(void* msg, storage_len_t len, bool lost, error_t err) {
    //?? 
    //pr("done\n");
    logmsgidx = 0;
  }
	
	event void LogWrite.eraseDone(error_t result) {}
  event void LogWrite.syncDone(error_t result) {}
  event void LogRead.seekDone(error_t error) {}
}
