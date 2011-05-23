
#if defined(TIMESYNCMSG_H)
#else
#define TIMESYNCMSG_H

typedef uint32_t seqnum_t;

typedef nx_struct TimeSyncMsg
{
	nx_uint16_t	rootID;		// the node id of the synchronization root
	nx_uint16_t	nodeID;		// the node if of the sender
	nx_uint32_t	seqNum;		// sequence number for the root

	/* This field is initially set to the offset between global time and local
	 * time. The TimeStamping component will add the current local time when the
	 * message is actually transmitted. Thus the receiver will receive the
	 * global time of the sender when the message is actually sent. */
	nx_uint32_t	globalTime;
	
	nx_uint16_t id;			//used to identify different applications.

	//just for convenience
	nx_uint32_t 	localTime;
} TimeSyncMsg;

enum {
    AM_TIMESYNCMSG = 0x3E,
    TIMESYNCMSG_LEN = sizeof(TimeSyncMsg) - sizeof(nx_uint32_t),
    TS_TIMER_MODE = 0,      // see TimeSyncMode interface
    TS_USER_MODE = 1,       // see TimeSyncMode interface
};

#endif
