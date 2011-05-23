interface RAMLog<type> {
	command void setValue(type val);
	command type getValue();	
}
