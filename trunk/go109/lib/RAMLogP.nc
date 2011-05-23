generic module RAMLogP(typedef type) {
	provides interface RAMLog<type>;
}
implementation {
	type myval;
	
	command void RAMLog.setValue(type val) {
		myval = val;
	}
	command type RAMLog.getValue() {
		return myval;
	}
}
