#ifndef DIAGNOSIS_H
#define DIAGNOSIS_H

#ifdef ENABLE_DIAGNOSIS
#define INSERT_EVENT(e)  call Diagnosis.insertEvent(e)
#define REPORT_EVENT()  call Diagnosis.sendEventReport()
#else
#define INSERT_EVENT(e)  
#define REPORT_EVENT() 
#endif
//#define INSERT_EVENT  call Diagnosis.insertEvent

//max number of events recorded in one packet
#define MAX_EVENT_SIZE 6

//event type
#define EVENT_RADIO_ON 1

#define EVENT_RADIO_OFF 2

#define EVENT_PACKET_RECEIVE 3

#define EVENT_PACKET_TRANSMIT 4

//receiption failure
#define EVENT_PACKET_RECEIVE_OVERFLOW_DROP 5

//transmission failure, packet drop due to queue overflow
#define EVENT_PACKET_TRANSMIT_OVERFLOW_DROP 6

//transmission failure, no ack, number of retransmissions is less than 30
#define EVENT_PACKET_TRANSMIT_NOACK_RETRANSMIT 7

//transmission failure, no ack, number of retransmissions is more than 30
#define EVENT_PACKET_TRANSMIT_NOACK_DROP 8

#define EVENT_PACKET_RETRANSMIT 9

#define EVENT_LOOP 10

#define EVENT_DUPLICATE_PACKET 11

#define EVENT_BOOT 12

#define EVENT_PARENT_CHANGE 13


//record of an event
typedef nx_struct eventInfo
{
	nx_uint8_t type;
	nx_uint32_t timestamp;
} event_info_t;



typedef nx_struct CEventStruct
{
	//event structure type
	nx_uint8_t type;

    nx_am_addr_t nodeID;

	//number of radio on event
	nx_uint32_t radioOnCounter;
	
	//time fo radio on
	nx_uint32_t radioOnTimeCounter;

	//number of received packets
	nx_uint32_t receiveCounter;

	//number of successful transmissions
	nx_uint32_t transmitCounter;

	//number of packets droped due to the message pool overflow
	nx_uint32_t receiveOverflowDropCounter;
	
	//number of packets droped due to the send queue overflow
	nx_uint32_t transmitOverflowDropCounter;

	//transmission failure, no ack, number of retransmissions is less than 30
	nx_uint32_t transmitNoACKRetransmitCounter;

	//transmission failure, no ack, number of retransmissions is more than 30
	nx_uint32_t transmitNoACKDropCounter;
	
	//number of retransmissions
	nx_uint32_t retransmitCounter;

	nx_uint32_t loopCounter;

	nx_uint32_t duplicateCounter;

	//number of system reboot events
	nx_uint32_t bootCounter;

	nx_uint32_t parentChangeCounter;



	//number of events inserted
	nx_uint8_t eventSize;
	//index of the last event
	nx_uint8_t eventIndex;



	//event array
	event_info_t event2Info[MAX_EVENT_SIZE];
	
	
} cevent_t;


inline uint8_t getEventMsgSize(cevent_t *msg) 
{
	if(msg->eventSize >= MAX_EVENT_SIZE)
	return sizeof(cevent_t);
	else
	return sizeof(cevent_t) + msg->eventSize * sizeof(event_info_t) \
			- MAX_EVENT_SIZE * sizeof(event_info_t);
}

#endif
