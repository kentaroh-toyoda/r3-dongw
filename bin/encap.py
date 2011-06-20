#!/usr/bin/python

# this script encapsulate multiple binary files
# format:
# type (1 byte) length (2 bytes, content length) file1
# type          length                           file2
# ...
import os
import sys
import struct

def print_usage():
  print "%s <output> <input1> <input2>, ..." % sys.argv[0]

### MAIN ###

if len(sys.argv) < 2:
  print_usage()
  sys.exit()

out = open(sys.argv[1], "wb")

for i in range(2,len(sys.argv)):
  print "processing input %s" % sys.argv[i]
  try:
    st = os.stat(sys.argv[i])
  except:
    print "cannot find file: %s" % sys.argv[i]
    sys.exit()
  print "%s file size = %d" % (sys.argv[i], st.st_size)
  
  out.write(chr(i-2+len(sys.argv)-3)); # 0 for old code, 2 for delta, ...
  out.write(struct.pack('H', st.st_size)); # unsigned short
  
  fp = open(sys.argv[i], "rb")
  out.write(fp.read())
  fp.close()
  
out.close()
