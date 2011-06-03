#include "SerialStart.h"

module SerialStartP {
  provides {
    interface SerialStart;
  }
  uses {
    interface Boot;
    interface AMSend as SerialAMSend;
    interface Receive as SerialAMReceive;
    interface SplitControl as SerialControl;
  }
}
implementation {

  enum {
    S_IDLE,
    S_BUSY,
  };

  message_t serialMsg;
  uint8_t state = S_IDLE;
  
  event void Boot.booted()
  {
    call SerialControl.start();
  }

  void sendAck(error_t error)
  {
    SerialAckPacket *ack = (SerialAckPacket*)call SerialAMSend.getPayload(&serialMsg, sizeof(SerialAckPacket));
    if (ack == NULL)
      return;
    ack->error = error;
    call SerialAMSend.send(AM_BROADCAST_ADDR, &serialMsg, sizeof(SerialAckPacket));
  }

  event void SerialControl.startDone(error_t error)
  {
    if (error != SUCCESS)
      call SerialControl.start();
  }

  event message_t* SerialAMReceive.receive(message_t* msg, void* payload, uint8_t len)
  {
    SerialDataPacket *pkt = (SerialDataPacket*)payload;
    
    switch (pkt->cmd) {
      case CMD_START:
        if (state == S_IDLE) {
          state = S_BUSY;
          signal SerialStart.start();
          sendAck(SUCCESS);
        } else {
          state = S_IDLE;
          sendAck(FAIL);
        }
        break;
      case CMD_STOP:
        if (state == S_BUSY) {
          state = S_IDLE;
          signal SerialStart.stop();
          sendAck(SUCCESS);
        } else {
        	sendAck(FAIL);
        }
        break;
      case CMD_DATA:
        if (state == S_BUSY) {
          //memcpy((void *)recvPkt->offset, recvPkt->data, recvPkt->len);
          // where do we store
          sendAck(SUCCESS);
        } else {
          sendAck(FAIL);
          state = S_IDLE;
        }
        break;
    }
    return msg;
  }

  event void SerialControl.stopDone(error_t error) {}
  event void SerialAMSend.sendDone(message_t* msg, error_t error) {}
  
  default event void SerialStart.start() {}
  default event void SerialStart.stop() {}
}
