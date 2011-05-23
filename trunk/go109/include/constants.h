#define ROOT_ID 1
#define TRANS_POWER 2


#define FTSP_ROOT  1


#define CHECK_INTERVAL 5000

#define ENTIRE_CYCLE_TIME     (60*60UL) //in minutes
#define SLEEP_DURATION    (57*60UL)     //in minutes

#define CLEAR_ROOT_SYNC (1440*60*1024UL)
#define JUST_REBOOT_TIME (10*60*1024UL)

#ifndef ENTRY_IMMEDIATELY_THROWOUT_LIMIT
	#define ENTRY_IMMEDIATELY_THROWOUT_LIMIT  10*1024 //clear the table immediately if the time error is larger than 30 seconds.
#endif