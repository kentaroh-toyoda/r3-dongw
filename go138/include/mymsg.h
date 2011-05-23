
/**
 *
 * @author Jiliang Wang
 * @version 
 *
 */
#ifndef MESSAGE_H
#define MESSAGE_H
//Wei
#define NEIGHBOR_SIZE	16 //20
#define PATH_LENGTH 30

#include <AM.h>

typedef nx_struct BeaconMessage
{
	nx_am_addr_t moteid;
} beacon_message_t;

enum
{
	AM_REPORT = 0xa1,
	AM_BEACON = 0xa2,
	AM_EVENT  = 0xa3
};

typedef nx_struct CDataStruct
{
	nx_uint8_t type;
	nx_uint32_t timestamp;
	nx_uint16_t temperature;
	nx_uint16_t humidity;
	nx_uint16_t light;
	nx_uint16_t ADC_Voltage;	// Battery Voltage=ADC_Voltage/4095*3
	
	// aggregate data
	nx_uint16_t noAcks;
	
	nx_am_addr_t parent;
	nx_uint8_t neighborSize;
	nx_uint8_t pathlength;
	nx_am_addr_t nodesOnPath[0];
	
} cdata_t;
//size 79

inline uint8_t getCDataLength(cdata_t *msg) {
	return sizeof(cdata_t)+msg->pathlength * sizeof(am_addr_t);
}

#define DATA_MSG_TYPE 0x41
#define STATUS_MSG_TYPE 0x42
#define CONFIG_MSG_TYPE 0x43
#define REQUEST_STATUS_MSG_TYPE 0x44
#define EVENT_MSG_TYPE	0x45

inline uint8_t getReportMsgType(void *msg) 
{
	//return the message type, used for decide the message size while forwarding.
	return ((uint8_t *)msg)[0];
}


typedef nx_struct neighborInfo
{
	nx_am_addr_t id;
	nx_uint8_t rssi;
	//Wei
	nx_uint8_t lqi; 
	nx_uint8_t etx; 
}neighbor_info_t;

typedef nx_struct CStatusStruct
{
	nx_uint8_t type;
	nx_uint32_t timestamp;
	nx_uint8_t neighborSize;
	neighbor_info_t neighbor2Info[NEIGHBOR_SIZE];
} cstatus_t;
//86

inline uint8_t getStatusMsgSize(cstatus_t *msg) 
{
	if (msg->neighborSize >= NEIGHBOR_SIZE)
		return sizeof(cstatus_t);
	return sizeof(cstatus_t) - (NEIGHBOR_SIZE - msg->neighborSize) * sizeof(neighbor_info_t);
}

typedef nx_struct ConfigStruct
{
	nx_uint8_t message_type;
	nx_am_addr_t targetId;
	nx_uint16_t sleeptime;
	nx_uint16_t entiretime;
	nx_uint16_t dutyratio;
	nx_uint8_t radioalwayson;
}config_struct_t;
//43 0001 7600 f000 ffff ff
typedef nx_struct RequestStruct
{
	nx_uint8_t message_type;
	nx_am_addr_t targetId;
	nx_uint16_t para1;
	nx_uint16_t para2;
}request_struct_t;
//44 0001 ffff ffff

typedef nx_struct RequestStatusStruct
{
	nx_uint8_t type;
	nx_am_addr_t id;
	nx_uint32_t timestamp;
	nx_uint16_t dutyratio;
	nx_uint8_t radioalwayson;
}request_status_struct_t;

enum 
{
	POWER_SET_MESSAGE = 0x01,
	SAMPLE_INTERVAL_MESSAGE = 0x02,
	DUTYCYCLE_MESSAGE = 0x03,
	START_RADIO = 0x04,
	STOP_RADIO = 0x05,
	REQUEST_CONFIG_VALUES = 0x06
};
 
#define DIS_SOME_COMPONENT_KEY 32
#define DIS_REQUEST_COMPONENT_KEY 42
#ifndef DIS_SOME_COMPONENT_KEY
  /*enum {
    DIS_SOME_COMPONENT_KEY = unique(DISSEMINATE_KEY) + 1 << 15;
  };*/

#endif



#endif // MESSAGE_H

