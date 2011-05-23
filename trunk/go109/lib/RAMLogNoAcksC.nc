configuration RAMLogNoAcksC {
  provides interface RAMLog<uint16_t>;
}

implementation {
  components new RAMLogC(uint16_t);
  RAMLog = RAMLogC;
}

