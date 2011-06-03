#ifndef __SERIAL_START_H__
#define __SERIAL_START_H__

enum {
  AM_SERIAL_START_ID = 0x39,
};

enum {
  CMD_START = 1,
  CMD_STOP  = 2,
  CMD_DATA  = 3,
};

typedef nx_struct SerialDataPacket {
  nx_uint8_t cmd;
  nx_uint8_t data[0];
} SerialDataPacket;

typedef nx_struct SerialAckPacket {
  nx_uint8_t error;
} SerialAckPacket;

#endif // __SERIAL_START_H__
