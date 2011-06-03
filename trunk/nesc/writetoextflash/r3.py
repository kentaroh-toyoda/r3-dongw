#!/usr/bin/python

import sys, os.path
import StringIO
import struct

try:
	import tos
except ImportError:
	import posix
	sys.path = [os.path.join(posix.environ['TOSROOT'], 'support', 
	                'sdk', 'python')] + sys.path
	import tos

BAUDRATES = { 'micaz':57600, 'telosb':115200 }

AM_ID = 0x39
AM_DATA_LENGTH = 16

CMD_START = 1
CMD_STOP  = 2
CMD_DATA  = 3
CMD_START_OLD = 4
CMD_START_DLT = 5

ERROR_SUCCESS = 0
ERROR_FAIL = 1

class SerialDataPacket(tos.Packet):
  def __init__(self, packet = None):
    tos.Packet.__init__(self,
                        [('cmd',  'int',  1),
                         ('data', 'blob', None)], packet)

class SerialAckPacket(tos.Packet):
  def __init__(self, packet = None):
    tos.Packet.__init__(self, [('error', 'int', 1)], packet)

def print_usage():
  print "Usage: %s <device port> <baudrate> image" % sys.argv[0]

def inject(image):
  try:
    os.stat(image)
  except:
    print "cannot find image: %s" % image
    return False
  
  fp = open(image, "rb")
  
  firstbyte = struct.unpack("B", fp.read(1))[0]
  
  if firstbyte==0:
    print "send OLD %d" % firstbyte
    outpkt = SerialDataPacket((CMD_START_OLD, []))
  else:
    print "send DELTA %d" % firstbyte
    outpkt = SerialDataPacket((CMD_START_DLT, []))
    
  if not am.write(outpkt, AM_ID):
    print "cannot send start packet"
    return False
  fp.close();
  
  inpkt = am.read()
  ack = SerialAckPacket(outpkt.data)
  if ack.error != ERROR_SUCCESS:
    print "receive ack (start) error"
    return False
  
  # send CMD_DATA
  fp = open(image, "rb")
  content = [struct.unpack("B", c)[0] for c in fp.read()]
  fp.close()
  
  print "image size is %d" % len(content)
  
  i=0
  while i<len(content):
    if i+AM_DATA_LENGTH >= len(content):
      offset = len(content)-i
    else:
      offset = AM_DATA_LENGTH
    
    # send content[i:i+offset] # not include the last character
    outpkt.cmd = CMD_DATA
    outpkt.data = content[i:i+offset]
    
    if not am.write(outpkt, AM_ID):
      print "cannot send data packet"
      return False
    
    inpkt = am.read()
    ack = SerialAckPacket(inpkt.data)
    if ack.error != ERROR_SUCCESS:
      print "receive ack (data at %d) error" % i
      return False
    
    #print "Send data for i=%d" % i
    i += offset
    
  
  outpkt.cmd = CMD_STOP
  if not am.write(outpkt, AM_ID):
    print "cannot send stop packet"
    return False
  inpkt = am.read()
  ack = SerialAckPacket(inpkt.data)
  if ack.error != ERROR_SUCCESS:
    print "receive ack (stop) error"
  else:
    print "sucessfully send the image of len %d" % len(content)
  
  return True

### MAIN ###

if len(sys.argv) < 4:
  print_usage()
  sys.exit()

if sys.argv[2] in BAUDRATES:
  baudrate = BAUDRATES[sys.argv[2]]
else:
  try:
    baudrate = int(sys.argv[2])
  except:
    print "Wrong baudrate"
    sys.exit(-1)

try:
  serial = tos.Serial(sys.argv[1], baudrate, flush=True, debug=False)
  am = tos.AM(serial)
except:
  print "Wrong serial port: ", sys.argv[1]
  sys.exit(-1)

## TODO: check support for r3
print "Start sending %s" % sys.argv[3]
inject(sys.argv[3])
sys.exit()
