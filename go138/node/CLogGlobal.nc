interface CLogGlobal {
	command void logmsg3(uint16_t type, log_arg_t arg1, log_arg_t arg2, log_arg_t arg3);
	command void logmsg(uint16_t type);	
	command void erase();
}
