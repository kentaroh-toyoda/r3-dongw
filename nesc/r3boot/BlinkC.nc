// $Id$

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Implementation for Blink application.  Toggle the red LED when a
 * Timer fires.
 **/

#include "Timer.h"
#include "pr.h"

#define PAGE_SIZE 512
#define BM_SIZE (PAGE_SIZE/16)

#define MIN(a,b) ((a)<(b)?(a):(b))


module BlinkC @safe()
{
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Leds;
  uses interface Boot;
  
  uses {
    interface ExtFlash;
    interface ProgFlash;
    interface StdControl as SubControl;
    interface Init as SubInit;
  }
}
implementation
{
 
  uint32_t extFlashReadDWord() {
    uint32_t result = 0;
    int8_t  i;
    for ( i = 3; i >= 0; i-- )
      result |= ((uint32_t)call ExtFlash.readByte() & 0xff) << (i*8);
    return result;
  }
  
  uint16_t extFlashReadWord() {
    uint16_t result = 0;
    int8_t  i;
    for ( i = 1; i >= 0; i-- )
      result |= ((uint16_t)call ExtFlash.readByte() & 0xff) << (i*8);
    return result;
  }
  
  void load() {
  	uint8_t tmp=0;
  	uint8_t codebuf[PAGE_SIZE];
    uint8_t bmbuf[BM_SIZE];
    uint8_t bmtype, symtype, codetype;
    uint16_t bmsize, symsize, codesize;
    
    uint16_t addrc, addrb;
    uint16_t symoffset;

  	// this function loads the files bm.raw, sym.raw, and old.raw/new.raw onto program flash
  	call ExtFlash.startRead(0);
  	bmtype = call ExtFlash.readByte();
  	bmsize = extFlashReadWord();
  	call ExtFlash.stopRead();

    pr("type=%d\n",bmtype);
    
    return;
  	
  	call ExtFlash.startRead(3+bmsize);
  	symtype = call ExtFlash.readByte();
  	symsize = extFlashReadWord();
  	call ExtFlash.stopRead();
  	
  	call ExtFlash.startRead(6+bmsize+symsize);
  	codetype = call ExtFlash.readByte();
  	codesize = extFlashReadWord();
  	call ExtFlash.stopRead();
  	
  	symoffset = 3+bmsize;
  	addrc = 6+bmsize+symsize; // addr for code
  	addrb = 0; // addr for bitmap
  	

  	while (1) {
  		uint32_t section_addr, section_len;
  		uint16_t memaddr;
  		
  		call ExtFlash.startRead(addrc);
  		section_addr = extFlashReadDWord();
  		section_len  = extFlashReadDWord();
  		call ExtFlash.stopRead();
  		
  		pr("addr=%lu,size=%lu\n", section_addr, section_len);
  		
  		while (1) ;
  		
  		if (section_addr == 0 && section_len == 0) 
  			break;
  		
  		addrc += 8;
  		addrb += 8;
  		
  		memaddr = section_addr;
  		
  		while (section_len>0) {
  			uint16_t i, mylen, bmlen;
  			mylen = MIN(section_len,PAGE_SIZE);
  			
  			call Leds.set(7);
  			
  			call ExtFlash.startRead(addrc);
  			for (i=0; i<mylen; i++) {
  			  codebuf[i] = call ExtFlash.readByte();
  		  }
  		  addrc += mylen;
  		  call ExtFlash.stopRead();
  		  
  		  bmlen = MIN((mylen+15)/16, BM_SIZE); 
  		  
  		  call ExtFlash.startRead(addrb);
  		  for (i=0; i<bmlen; i++) {
  		  	bmbuf[i] = call ExtFlash.readByte();
  		  }
  		  addrb += bmlen;
  		  call ExtFlash.stopRead();
  		  
  		  // memaddr is the starting memory address for codebuf
  		  //relocate();
  		  for (i=0; i<mylen; i+=2) {
  		    uint16_t addr = memaddr + i;
  		    uint16_t byteaddr = i/16;
  		    uint16_t bitaddr  = (i/2)%8;
  		
  		    if ( bmbuf[byteaddr] & (0x1<<(bitaddr)) ) {
  			    // do relocation
            //1. read index
            uint16_t index, target;
            index = (codebuf[i+1]<<8) + codebuf[i];
            call ExtFlash.startRead(symoffset+index*2);
            target = extFlashReadWord();
            call ExtFlash.stopRead();   
        
            codebuf[i+1] = target>>8;
            codebuf[i] = target & 0xff;     
  		    }
  	    } // end relocate
  		  
  		  //call ProgFlash.write(memaddr, codebuf, mylen);
  			
  			section_len -= mylen;
  			memaddr += mylen;
  		}
  	}
  	//runApp();
        call Leds.set(3);
        while (1) ;
  }
  

  event void Boot.booted()
  {
    call SubInit.init();
    call SubControl.start();
    
    //call Timer0.startPeriodic( 250 );
    //call Timer1.startPeriodic( 500 );
    //call Timer2.startPeriodic( 1000 );
    load();
  }

  event void Timer0.fired()
  {
    dbg("BlinkC", "Timer 0 fired @ %s.\n", sim_time_string());
    call Leds.led0Toggle();
  }
  
  event void Timer1.fired()
  {
    dbg("BlinkC", "Timer 1 fired @ %s \n", sim_time_string());
    call Leds.led1Toggle();
  }
  
  event void Timer2.fired()
  {
    dbg("BlinkC", "Timer 2 fired @ %s.\n", sim_time_string());
    call Leds.led2Toggle();
  }
}

