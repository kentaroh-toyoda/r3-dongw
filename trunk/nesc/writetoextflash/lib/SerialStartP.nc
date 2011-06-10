#include "SerialStart.h"
#include "StorageVolumes.h"

#include "pr.h"

#define MAX_SIZE 100

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
  
  enum {
  	READ_FILEINFO,
  	READ_CMD_1,
    READ_CMD_2,
    EXE_ADD_READ,
    EXE_COPY_READ,
    EXE_ADD_WRITE,
    EXE_COPY_WRITE,
  };

  message_t serialMsg;
  uint8_t state = S_IDLE;
  uint16_t curaddr = 0;
  uint8_t type = 0; // the receive file type, 0: old, 1: new, 2: delta...
  
  uint8_t pst; // patch status 
  uint8_t buffer[MAX_SIZE];
  
  uint8_t dtype; // should be 2
  uint16_t dsize;
  
  uint8_t cmdtype;
  uint16_t cmdlen;
  uint16_t cmdinew;
  uint16_t cmdiold;
  
  uint16_t daddr; // for delta
  uint16_t naddr; // for new code
  
  
  
  void patch();
  
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
    else
    	patch();
  }

  event message_t* SerialAMReceive.receive(message_t* msg, void* payload, uint8_t len)
  {
    SerialDataPacket *pkt = (SerialDataPacket*)payload;
    
    switch (pkt->cmd) {
      case CMD_START:
        if (state == S_IDLE) {
          state = S_BUSY;
          type = pkt->len; // for cmd pkt, len indicates the type
          if (type == 0) {
            call SubBlockWrite_1.erase();
          }
          else if (type == 2) {
          	call SubBlockWrite_3.erase();
          }
        } else {
          state = S_IDLE;
          sendAck(FAIL);
        }
        break;
      case CMD_STOP:
        if (state != S_IDLE) {
          state = S_IDLE;
          
          
          //if (curaddr==2709)
          //	call Leds.led1On();
          if (type == 0) {
          	call SubBlockWrite_1.sync();
          }
          else if (type == 2) {
          	call SubBlockWrite_3.sync();
          }
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
          //sendAck(SUCCESS);
          //curaddr += pkt->len;
          //call Leds.led0Toggle();
        } 
        else if (type == 1) { // NEW
        	
        }
        else if (type == 2) { // DELTA ...
        	call SubBlockWrite_3.write(curaddr, pkt->data, pkt->len);
        	//sendAck(SUCCESS);
        	//curaddr += pkt->len;
        	//call Leds.led2Toggle();
        }
        else {
          sendAck(FAIL);
          state = S_IDLE;
        }
        break;
    }
    return msg;
  }
  
  void patch() {
  	// Now the old code resides in VOLUME_DELUGE1
  	// and the delta, ... reside in VOLUME_DELUGE3
  	// we need to reconstruct the new code to VOLUME_DELUGE_2
  	pst = READ_FILEINFO; 
  	daddr = 0; naddr = 0;
  	call SubBlockRead_3.read(0, buffer, 3); // should be 2: delta
  	pr("patch start\n");
  }
  
  
  
  event void SerialControl.stopDone(error_t error) {}
  event void SerialAMSend.sendDone(message_t* msg, error_t error) {}
  
  uint8_t deof(uint16_t addr, uint16_t size) {
  	if (addr >= size+3) {
  		call Leds.led1On();
  		pr("patch end, new code size=%d\n", naddr);
  		return 1;
  	}
  	return 0;
  }
  
  default event void SerialStart.start() {}
  default event void SerialStart.stop() {}
  
  event void SubBlockRead_1.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
    cmdiold += len;
    switch (pst) {
    	case EXE_COPY_READ:
    		// anyway, we read something done here
    		pst = EXE_COPY_WRITE;
    		call SubBlockWrite_2.write(naddr, buffer, len);
    		break;
    }
  }
  event void SubBlockRead_1.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_1.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
  	sendAck(SUCCESS);
    curaddr += len;
    call Leds.led0Toggle();
  }
  event void SubBlockWrite_1.eraseDone(error_t error) {
    signal SerialStart.start();
    sendAck(SUCCESS);
    daddr = 0; 	
  }
  event void SubBlockWrite_1.syncDone(error_t error) {
    signal SerialStart.stop();
    sendAck(SUCCESS);	
  }
  
  event void SubBlockRead_2.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockRead_2.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_2.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
    naddr += len;
    switch (pst) {
    	case EXE_ADD_WRITE:
    		// see if the cmd completes
    		cmdlen -= len;
    		if (cmdlen <= 0) { // start new command
    			if (deof(daddr, dsize)) return;
    			
    			pst = READ_CMD_1;
    			call SubBlockRead_3.read(daddr, buffer, 3); 
    		} else {
    			pst = EXE_ADD_READ;
    			if (cmdlen>MAX_SIZE)
    			  call SubBlockRead_3.read(daddr, buffer, MAX_SIZE);
    			else 
    				call SubBlockRead_3.read(daddr, buffer, cmdlen);
    		}
    		break;
    	case EXE_COPY_WRITE:
    		cmdlen -= len;
    		if (cmdlen <= 0) {
    			if (deof(daddr, dsize)) return;
    				
    			pst = READ_CMD_1;
    			call SubBlockRead_3.read(daddr, buffer, 3);
    		} else {
    		  pst = EXE_COPY_READ;
    		  if (cmdlen>MAX_SIZE)
    		    call SubBlockRead_1.read(cmdiold, buffer, MAX_SIZE);	
    		  else	
    		  	call SubBlockRead_1.read(cmdiold, buffer, cmdlen);
    		}
    		break;
    }	
  }
  event void SubBlockWrite_2.eraseDone(error_t error) {}
  event void SubBlockWrite_2.syncDone(error_t error) {}
  
  event void SubBlockRead_3.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {
  	daddr += len;
  	
  	switch (pst) {
  		case READ_FILEINFO:
  		  // the fileinfo (type+size) is readdone now
  		  //memcpy(&dtype, &buffer[1], 1);
  		  //memcpy(&dsize, (void*)&buffer[1], 2);
  		  dtype = buffer[0];
  		  dsize = (buffer[2]<<8) + buffer[1];
  		  
  		  if (deof(daddr, dsize)) return;
  		  	
  		  pst = READ_CMD_1; // read first part of a command
  		  call SubBlockRead_3.read(daddr, buffer, 3);
  		  break; 
  		case READ_CMD_1:
  			// the (cmd type+len) is readdone now
  			// for add, the cmd is complete; for copy, we need to read 4 additional bytes
  			//memcpy(&cmdtype, buffer, 1);
  			//memcpy(&cmdlen, &buffer[1], 2);
  			
  			cmdtype = buffer[0];
  			cmdlen = (buffer[2]<<8) + buffer[1];
  			
  			if (cmdtype == CMD_ADD) {
  				pst = EXE_ADD_READ;
  				if (cmdlen>MAX_SIZE) {
  				  call SubBlockRead_3.read(daddr, buffer, MAX_SIZE); // continue read until all read done
  				}
  				else {
  					call SubBlockRead_3.read(daddr, buffer, cmdlen);
  				}
  			} 
  			else if (cmdtype == CMD_COPY) {
  			  pst = READ_CMD_2; // read second part of a command	
  			  call SubBlockRead_3.read(daddr, buffer, 4); // for inew and iold
  			}
  			break;
  		case READ_CMD_2:
  			// inew and iold is readdone
  			//memcpy(&cmdinew, buffer, 2);
  			//memcpy(&cmdiold, &buffer[2], 2);
  			cmdinew = (buffer[1]<<8) + buffer[0];
  			cmdiold = (buffer[3]<<8) + buffer[2];
  			
  			cmdiold += 3; // fileinfo header
  			
  			pst = EXE_COPY_READ;
  			if (cmdlen>MAX_SIZE) {
  			  call SubBlockRead_1.read(cmdiold, buffer, MAX_SIZE);
  		  } else {
  		  	call SubBlockRead_1.read(cmdiold, buffer, cmdlen);
  		  } 
  			break;
  		case EXE_ADD_READ:
  			// anyway, we read something done
  			// write so that the buf can be reused
  			pst = EXE_ADD_WRITE;
  			call SubBlockWrite_2.write(naddr, buffer, len);
  			break; 
  	} 
  }
  event void SubBlockWrite_3.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t error) {}
  event void SubBlockRead_3.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t crc, error_t error) {}
  event void SubBlockWrite_3.eraseDone(error_t error) {
    signal SerialStart.start();
    sendAck(SUCCESS);
    daddr = 0; 		
  }
  event void SubBlockWrite_3.syncDone(error_t error) {
    signal SerialStart.stop();
    sendAck(SUCCESS);	
  }
}
