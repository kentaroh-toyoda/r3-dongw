#change the TOSH_DATA_LENGTH whenever necessary
COMPONENT=CDataAppC

PFLAGS += -fnesc-separator=__

#set the duty cycle accordingly.
CFLAGS += -DTOSH_DATA_LENGTH=100 
CFLAGS += -DCC2420_DEF_RFPOWER=31 
#CFLAGS += -DCC2420_DEF_CHANNEL=15 
#max trickle timer interval. Default 30.
CFLAGS += -DMAX_TRICKLE_TIMER=20

#CFLAGS += -DENABLE_PR
#CFLAGS += -DENABLE_LOG
#CFLAGS += -DENABLE_DEBUG_LED

CFLAGS += -I../include
CFLAGS += -I../lib
CFLAGS += -I../lib/CC2420
CFLAGS += -I../lib/ctp
CFLAGS += -I../lib/drip
CFLAGS += -I../lib/ftsp

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
