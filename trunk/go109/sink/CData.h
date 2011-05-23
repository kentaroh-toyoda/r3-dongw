
/**
 *
 * @author Jiliang Wang
 * @version 
 *
 */
#ifndef MESSAGE_H
#define MESSAGE_H
#define NEIGHBOR_SIZE	10
#define PATH_LENGTH 10
typedef nx_struct BeaconMessage
{
	nx_uint8_t moteid;
	
}beacon_message_t;
enum
{
	AM_REPORT = 0x90,
	AM_BEACON = 0x91
};
typedef nx_struct CDataStruct
{
	nx_uint8_t moteid;
	nx_uint16_t temperature;
	nx_uint16_t humidity;
	nx_uint16_t light;
	nx_uint16_t ADC_Voltage;	// Battery Voltage=ADC_Voltage/4095*3
	nx_uint8_t neighborId[NEIGHBOR_SIZE];
	nx_uint8_t lqi[NEIGHBOR_SIZE];
	nx_uint8_t rssi[NEIGHBOR_SIZE];
	nx_uint8_t neighborSize;
	nx_uint8_t nodesOnPath[PATH_LENGTH];
	nx_uint8_t pathlength;
}cdata_t;
#endif
