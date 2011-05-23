configuration CLogGlobalC {
	provides interface CLogGlobal;
}
implementation {
	components MainC;
	components SimpleSyncC;
	components CLogGlobalP;
	
	MainC.SoftwareInit -> SimpleSyncC;
	SimpleSyncC.Boot -> MainC;
	
	CLogGlobalP.GlobalTime -> SimpleSyncC;
	CLogGlobalP.TimeSyncInfo -> SimpleSyncC;
	components new LogStorageC(VOLUME_LOGTEST, TRUE); // circular
	CLogGlobalP.LogRead -> LogStorageC;
	CLogGlobalP.LogWrite -> LogStorageC;
	
	CLogGlobal = CLogGlobalP.CLogGlobal;
}
