#change the TOSH_DATA_LENGTH whenever necessary
COMPONENT=CDataAppC

CFLAGS += -DTOSH_DATA_LENGTH=100 
CFLAGS += -DCC2420_DEF_RFPOWER=31 
#CFLAGS += -DCC2420_DEF_CHANNEL=15 

#max trickle timer interval. Default 30.
CFLAGS += -DMAX_TRICKLE_TIMER=20
#sink will enabled to wait to sync with neighbors.
#CFLAGS += -DENABLE_SINK_WAITING_MODE

CFLAGS += -I../include
CFLAGS += -I../lib
CFLAGS += -I../lib/ctp
CFLAGS += -I../lib/CC2420
CFLAGS += -I../lib/drip
CFLAGS += -I../lib/watchdog
CFLAGS += -I../lib/ftsp

CFLAGS += -I$(TOSDIR)/lib/net/
CFLAGS += -I$(TOSDIR)/lib/net/4bitle 
CFLAGS += -I$(TOSDIR)/platforms/telosa/chips
#CFLAGS += -I$(TOSDIR)/lib/ftsp

include $(MAKERULES)
