#include "SerialStart.h"
#include "StorageVolumes.h"

module SerialStartP {
  provides {
    interface SerialStart;
  }
  uses {
    interface Boot;
    interface AMSend as SerialAMSend;
    interface Receive as SerialAMReceive;
    interface SplitControl as SerialControl;
    interface Leds;
    
    interface BlockRead as SubBlockRead_1; // 1:old code
    interface BlockRead as SubBlockRead_2;
    interface BlockRead as SubBlockRead_3;
    
    interface BlockWrite as SubBlockWrite_1; // 2:new code, 3:delta
    interface BlockWrite as SubBlockWrite_2;
    interface BlockWrite as SubBlockWrite_3;
  }
}
implementation {

  enum {
    S_IDLE,
    S_BUSY,
  };

  message_t serialMsg;
  uint8_t state = S_IDLE;
  uint16_t curaddr = 0;
  uint8_t type = 0; // the receive file type, 0: old, 1: new, 2: delta...
  
  event void Boot.booted()
  {
    call SerialControl.start();
  }

  void sendAck(error_t error)
  {
    SerialAckPacket *ack = (SerialAckPacket*)call SerialAMSend.getPayload(&serialMsg, sizeof(SerialAckPacket));
    if (ack == NULL)
      return;
    ack->error = error; // currently we do not use the data
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
          curaddr = 0; 
          type = pkt->len; // for cmd pkt, len indicates the type
        } else {
          state = S_IDLE;
          sendAck(FAIL);
        }
        break;
      case CMD_STOP:
        if (state != S_IDLE) {
          state = S_IDLE;
          signal SerialStart.stop();
          sendAck(SUCCESS);
          
          //if (curaddr==2709)
          //	call Leds.led1On();
          	
          curaddr = 0;
        } else {
        	sendAck(FAIL);
        }
        break;
      case CMD_DATA:
        if (type == 0) { // OLD
          //memcpy((void *)recvPkt->offset, recvPkt->data, recvPkt->len);
          // where do we store para: addr,buf,len
          call SubBlockWrite_1.write(curaddr, pkt->data, pkt->len);
          sendAck(SUCCESS);
          curaddr += pkt->len;
          call Leds.led0Toggle();
        } 
        else if (type == 1) { // NEW
        	
        }
        else if (type == 2) { // DELTA ...
        	call SubBlockWrite_3.write(curaddr, pkt->data, pkt->len);
        	sendAck(SUCCESS);
        	curaddr += pkt->len;
        	call Leds.led2Toggle();
        }
        else {
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
  
  event void SubBlockRead_1.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockRead_1.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_1.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockWrite_1.eraseDone(error_t error) {}
  event void SubBlockWrite_1.syncDone(error_t error) {}
  
  event void SubBlockRead_2.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockRead_2.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_2.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockWrite_2.eraseDone(error_t error) {}
  event void SubBlockWrite_2.syncDone(error_t error) {}
  
  event void SubBlockRead_3.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockRead_3.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_3.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockWrite_3.eraseDone(error_t error) {}
  event void SubBlockWrite_3.syncDone(error_t error) {}
}
