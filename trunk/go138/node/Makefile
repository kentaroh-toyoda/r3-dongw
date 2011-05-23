#change the TOSH_DATA_LENGTH whenever necessary
COMPONENT=CDataAppC

PFLAGS += -fnesc-separator=__

#set the duty cycle accordingly.
CFLAGS += -DTOSH_DATA_LENGTH=100 
#set to 2 for indoor exp and 31 for outdoor.
CFLAGS += -DCC2420_DEF_RFPOWER=25 
#15 for exp
#CFLAGS += -DCC2420_DEF_CHANNEL=15  
#max trickle timer interval. Default 30.
CFLAGS += -DMAX_TRICKLE_TIMER=20
#uncomment to enable pr
#CFLAGS += -DENABLE_PR

#not using the reader
#CFLAGS += -DNOT_USING_READER

#uncomment to enable log
#CFLAGS += -DENABLE_LOG     
#set to the buffer size in ram
CFLAGS += -DLOGMSG_SIZE=2
#uncomment to enable led
#CFLAGS += -DENABLE_DEBUG_LED

#uncomment to enable diagonsis
CFLAGS += -DENABLE_DIAGNOSIS

 #different apps have different ID, used to distinguish different apps.
CFLAGS += -DSYNC_MSG_ID=31

#root wait to sync with others.
CFLAGS += -DROOT_WAIT_COUNT=5 

CFLAGS += -I../include
CFLAGS += -I../lib
CFLAGS += -I../lib/CC2420
CFLAGS += -I../lib/ctp
CFLAGS += -I../lib/drip
CFLAGS += -I../lib/SimpleSync
# pls place it into lib!!!
CFLAGS += -I../Diagnosis


#xxxxxxx
CFLAGS += -I.

CFLAGS += -I$(TOSDIR)/lib/net
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -I$(TOSDIR)/lib/net/4bitle 
CFLAGS += -I$(TOSDIR)/platforms/telosa/chips 
#CFLAGS += -I$(TOSDIR)/lib/net/drip
#CFLAGS += -I$(TOSDIR)/lib/ftsp
#CFLAGS += -I$(TOSROOT)/apps/tests/TestFtsp

#DEBUG
#CFLAGS += -DTEST_FTSP
include $(MAKERULES)
