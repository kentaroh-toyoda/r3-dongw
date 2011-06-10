COMPONENT=BlinkAppC
CFLAGS += -Imsp430 -Imsp430f1611 -Istm25p -Itelosb
PFLAGS += -fnesc-separator=__

CFLAGS += -DENABLE_PR
CFLAGS += -I$(TOSDIR)/lib/printf
CFLAGS += -DTOSBOOT_START=0x4000

include $(MAKERULES)
