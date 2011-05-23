This application shows the usage of the Watchdog component.

It sends a packet to the serial port every two seconds. It makes sure that
this process keeps going on by using two instances of the Watchdog component:
one to check that the sendMsg() task is periodically executed, and another one
to check that the sendDone() signal is periodically received. If one of these
events fails to occur, the watchdogs are not reseted and the mote reboots.
Failures are simulated by changing the values of two counters, mTimerCnt and
mSendMsgCnt.
