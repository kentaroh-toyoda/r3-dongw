#include "pr.h"



module DiagnosisP
{
	provides 
	{
		interface Diagnosis;
	}

	uses 
	{
		interface Send;
		interface LocalTime<TMilli>;
		interface Intercept;
	}
}

implementation
{

	//event data structure
	cevent_t EventData;
	//packet buffer
	message_t EventPacket;

	
	
       //time of the latest radio-on event
	nx_uint32_t TimeOfLatestRadioOn;
	

	command error_t Diagnosis.insertEvent(nx_uint8_t eventType)
	{

		event_info_t eventRecord;
		uint32_t currentTime =  call LocalTime.get();
		
		
		
		//update statistics
		
              if(eventType == EVENT_RADIO_ON)
              {
			EventData.radioOnCounter++;
			TimeOfLatestRadioOn = currentTime;
              }
		
		if(eventType== EVENT_RADIO_OFF && TimeOfLatestRadioOn != 0)
		{
			EventData.radioOnTimeCounter += (currentTime - TimeOfLatestRadioOn)/1000;
		}

		if(eventType == EVENT_PACKET_RECEIVE)
		{
			EventData.receiveCounter++;
		}

		if(eventType == EVENT_PACKET_TRANSMIT)
		{
			EventData.transmitCounter++;
		}

		if(eventType == EVENT_PACKET_RECEIVE_OVERFLOW_DROP)
		{
			EventData.receiveOverflowDropCounter++;
		}

		if(eventType == EVENT_PACKET_TRANSMIT_OVERFLOW_DROP)
		{
			EventData.transmitOverflowDropCounter++;
		}

		if(eventType == EVENT_PACKET_TRANSMIT_NOACK_RETRANSMIT)
		{
			EventData.transmitNoACKRetransmitCounter++;
		}


		if(eventType == EVENT_PACKET_TRANSMIT_NOACK_DROP)
		{
			EventData.transmitNoACKDropCounter++;
		}


		if(eventType == EVENT_PACKET_RETRANSMIT)
		{
			EventData.retransmitCounter++;
		}


		if(eventType == EVENT_LOOP)
		{
			EventData.loopCounter++;
		}


		if(eventType == EVENT_DUPLICATE_PACKET)
		{
			EventData.duplicateCounter++;
		}
		

		if(eventType == EVENT_BOOT)
		{
			EventData.bootCounter++;
		}


		if(eventType == EVENT_PARENT_CHANGE)
		{
			EventData.parentChangeCounter++;
		}
			




		if(eventType == EVENT_RADIO_ON ||
			eventType == EVENT_RADIO_OFF ||
			//eventType == EVENT_PACKET_RECEIVE ||
			//eventType == EVENT_PACKET_TRANSMIT ||
			eventType == EVENT_PACKET_RECEIVE_OVERFLOW_DROP ||
			eventType == EVENT_PACKET_TRANSMIT_OVERFLOW_DROP ||
			eventType == EVENT_PACKET_TRANSMIT_NOACK_RETRANSMIT ||
			eventType == EVENT_PACKET_TRANSMIT_NOACK_DROP ||
			//eventType == EVENT_PACKET_RETRANSMIT ||
			eventType == EVENT_LOOP ||
			eventType == EVENT_DUPLICATE_PACKET ||
			eventType == EVENT_BOOT ||
			eventType == EVENT_PARENT_CHANGE)
		{
			
			eventRecord.type = eventType;
			eventRecord.timestamp = currentTime;

			//number of events
	              EventData.eventSize++;

			//insert event
			EventData.event2Info[EventData.eventIndex] = eventRecord;
			EventData.eventIndex++;
			EventData.eventIndex = EventData.eventIndex%MAX_EVENT_SIZE;

		}
		
		return SUCCESS;
	}

	
	command error_t Diagnosis.sendEventReport()
	{
		//uint8_t i;
		cevent_t* temp = NULL;
		//error_t r;
		uint8_t size = getEventMsgSize(&EventData);	
		temp = (cevent_t *)call Send.getPayload(&EventPacket, 0);
		pr("PAYLOAD:%d-%d-%d-%d====\n", size, call Send.maxPayloadLength(), sizeof(cevent_t), TOSH_DATA_LENGTH);
		memcpy(temp, &EventData, size);
		EventData.type = EVENT_MSG_TYPE;
		EventData.nodeID = TOS_NODE_ID;
		return call Send.send(&EventPacket, size);

		/*if (call Send.send(&EventPacket, size) == SUCCESS)
		{
			//clear the EventData
			return SUCCESS;
		}
		else
		return FAIL;*/
	}


	event bool Intercept.forward(message_t* msg, void* payload, uint8_t len) 
	{
		return TRUE;
	}

	event void Send.sendDone(message_t* msg, error_t error) 
	{
	
			EventData.eventSize = 0;
			EventData.eventIndex = 0;
			
			//for(i = 0; i < MAX_EVENT_SIZE; i++)
			//{
				memset(&EventData.event2Info[0], 0, sizeof(event_info_t)*MAX_EVENT_SIZE);
			//}
  	}
}
