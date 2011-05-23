#ifndef LOG_MSG_H
#define LOG_MSG_H

#define LOWORD(a)  ((uint16_t)a)
#define HIWORD(a)  ((uint16_t)(a>>16))


#define LOGMSG_SIZE   100 // in RAM

#define LOGMSG_BOOT 1
#define LOGMSG_SLEEP 2
#define LOGMSG_WAKEUP 3
#define LOGMSG_SBACK_WAIT_ACK 4
#define LOGMSG_SBACK_INITIAL 5
#define LOGMSG_SBACK_CONGESTION 6
#define LOGMSG_BFIRED 7

#define TIME_SYNC_ENTRY_TIME	20
#define REPORT_PATH_MSG			21
#define REPORT_NEIGHBOR_MSG		22	

typedef uint32_t log_arg_t;
typedef struct logmsg_t {
	uint16_t type;
	uint32_t timestamp;
	log_arg_t arg1;
	log_arg_t arg2;
	log_arg_t arg3;
} logmsg_t;

#define NOACKS  1


#ifdef ENABLE_LOG
#define LOGMSG(type)  do { call Log.logmsg(type); } while (0)
#define LOGMSG3(type, a1, a2, a3) do { call Log.logmsg3(type, a1, a2, a3); } while (0)
#else
#define LOGMSG(type)
#define LOGMSG3(type, a1, a2, a3)
#endif

#endif

