configuration CLogGlobalC {
	provides interface CLogGlobal;
}
implementation {
	components MainC;
	components TimeSyncC;
	components CLogGlobalP;
	
	MainC.SoftwareInit -> TimeSyncC;
	TimeSyncC.Boot -> MainC;
	
	CLogGlobalP.GlobalTime -> TimeSyncC;
	CLogGlobalP.TimeSyncInfo -> TimeSyncC;
	components new LogStorageC(VOLUME_LOGTEST, TRUE); // circular
	CLogGlobalP.LogRead -> LogStorageC;
	CLogGlobalP.LogWrite -> LogStorageC;
	
	CLogGlobal = CLogGlobalP.CLogGlobal;
}
