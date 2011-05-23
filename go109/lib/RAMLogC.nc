generic configuration RAMLogC(typedef type) {
	provides interface RAMLog<type>;
}
implementation {
	components new RAMLogP(type);
	
	RAMLog = RAMLogP.RAMLog;
}
