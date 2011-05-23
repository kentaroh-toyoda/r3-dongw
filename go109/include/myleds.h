
/**
 *
 * @author Jiliang Wang
 * @version 
 *
 */
#ifndef LED_H
#define LED_H
 static void fatalProblem()
	{
//#ifdef DEBUG_
		call Leds.led0On();
		call Leds.led1On();
		call Leds.led2On();
//#endif
	}
	static void toggle(uint8_t val) 
	{
		/*switch(l) 
		{
			case 0:
				call Leds.led0Toggle();
				break;
			case 1:
				call Leds.led1Toggle();
				break;
			case 2:
				call Leds.led2Toggle();
				break;
			default:
				break;
		}*/
		if (val & 0x01)
			call Leds.led0Toggle();
		//else			
		if (val & 0x02)
			call Leds.led1Toggle();
		//else
			if (val & 0x04)
			call Leds.led2Toggle();
	
	}
	static void setLeds(uint16_t val)
	{
	 	if (val & 0x01)
	      		call Leds.led0On();
	    	else
	      		call Leds.led0Off();
	    	if (val & 0x02)
	      		call Leds.led1On();
	    	else
	      		call Leds.led1Off();
	    	if (val & 0x04)
	      		call Leds.led2On();
	    	else
	      		call Leds.led2Off();
	}
	
	static void debugLeds(uint16_t val)
	{
#ifdef ENABLE_DEBUG_LED
	 	setLeds(val);
#endif
	}
	
#ifdef ENABLE_DEBUG_LED
	#define DEBUG_LED(val) setLeds(val)
#else
	#define DEBUG_LED(val)
#endif
	
#endif
