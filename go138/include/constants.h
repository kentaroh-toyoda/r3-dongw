#define ROOT_ID 1
//#define TRANS_POWER 2


#define FTSP_ROOT  1


#define CHECK_INTERVAL 5000

#define ENTIRE_CYCLE_TIME     (60*60UL) //in minutes
#define SLEEP_DURATION    (55*60UL)     //in minutes

//#define CLEAR_ROOT_SYNC (1440*60*1024UL)
#define JUST_REBOOT_TIME (10*60*1024UL)

#ifndef ENTRY_IMMEDIATELY_THROWOUT_LIMIT
	#define ENTRY_IMMEDIATELY_THROWOUT_LIMIT  (1*1024) //clear the table immediately if the time error is larger than 30 seconds.
#endif

#ifndef TIMESYNC_OFFSET_DIFF_THR
	#define TIMESYNC_OFFSET_DIFF_THR (1*1024)
#endif

#ifndef TIMESYNC_NO_NEWS_FROM_ROOT_THR
	#define TIMESYNC_NO_NEWS_FROM_ROOT_THR 1800
#endif

#ifndef TIMESYNC_RATE
	#define TIMESYNC_RATE 10
#endif

#ifndef TIMESYNC_SEQ_DIFF_THR
	#define TIMESYNC_SEQ_DIFF_THR (24UL*3600UL*2UL/10UL)
#endif






#define INVALID_TIME	0xffffffff

