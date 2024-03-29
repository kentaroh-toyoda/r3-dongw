/*
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
 * Copyright (c) 2007 Johns Hopkins University.
 * All rights reserved.
 *
 */

/**
 * @author Jonathan Hui <jwhui@cs.berkeley.edu>
 * @author Chieh-Jan Mike Liang <cliang4@cs.jhu.edu>
 * @author Razvan Musaloiu-E. <razvanm@cs.jhu.edu>
 */

#include "crc.h"
#include <hardware.h>

#define PAGE_SIZE 512
#define BM_SIZE (PAGE_SIZE/16)

#define MIN(a,b) ((a)<(b)?(a):(b))

module TosBootP {
  uses {
    interface Exec;
    interface ExtFlash;
    interface Hardware;
    interface InternalFlash as IntFlash;
    interface Leds;
    interface ProgFlash;
    interface StdControl as SubControl;
    interface Init as SubInit;
    interface Voltage;
    
    

  }
}
implementation {

  enum {
    LEDS_LOWBATT = 1,
    LEDS_GESTURE = 7,
  };

  enum {
    R_SUCCESS,
    R_INVALID_IMAGE_ERROR,
    R_PROGRAMMING_ERROR,
  };

  void startupLeds() {

    uint8_t  output = 0x7;
    uint8_t  i;

    for (i = 3; i; i--, output >>= 1 )
      call Leds.glow(output, output >> 1);

  }
  
  in_flash_addr_t extFlashReadAddr() {
    in_flash_addr_t result = 0;
    int8_t  i;
    for ( i = 3; i >= 0; i-- )
      result |= ((in_flash_addr_t)call ExtFlash.readByte() & 0xff) << (i*8);
    return result;
  }
  
  // 00 | BF 00 | 00 4A 00 00 | 5A 0A 00 00
  // ->            00 00 4A 00 | 00 00 0A 5A
  uint32_t extFlashReadDWord() {
    uint32_t result = 0;
    int8_t  i;
    for ( i = 0; i <= 3; i++ )
      result |= ((uint32_t)call ExtFlash.readByte() & 0xff) << (i*8);
    return result;
  }
  
  uint16_t extFlashReadWord() {
    uint16_t result = 0;
    int8_t  i;
    for ( i = 0; i <= 1; i++ )
      result |= ((uint16_t)call ExtFlash.readByte() & 0xff) << (i*8);
    return result;
  }

  bool verifyBlock(ex_flash_addr_t crcAddr, ex_flash_addr_t startAddr, uint16_t len)
  {
    uint16_t crcTarget, crcTmp;

    // read crc
    call ExtFlash.startRead(crcAddr);
    crcTarget = (uint16_t)(call ExtFlash.readByte() & 0xff) << 8;
    crcTarget |= (uint16_t)(call ExtFlash.readByte() & 0xff);
    call ExtFlash.stopRead();

    // compute crc
    call ExtFlash.startRead(startAddr);
    for ( crcTmp = 0; len; len-- )
      crcTmp = crcByte(crcTmp, call ExtFlash.readByte());
    call ExtFlash.stopRead();

    return crcTarget == crcTmp;
  }

  bool verifyImage(ex_flash_addr_t startAddr) {
    uint32_t addr;
    uint8_t  numPgs;
    uint8_t  i;


    if (!verifyBlock(startAddr + offsetof(DelugeIdent,crc),
		     startAddr, offsetof(DelugeIdent,crc)))
      return FALSE;

    // read size of image
    call ExtFlash.startRead(startAddr + offsetof(DelugeIdent,numPgs));
    numPgs = call ExtFlash.readByte();
    call ExtFlash.stopRead();

    if (numPgs == 0 || numPgs == 0xff)
      return FALSE;

    startAddr += DELUGE_IDENT_SIZE;
    addr = DELUGE_CRC_BLOCK_SIZE;

    for ( i = 0; i < numPgs; i++ ) {
      if (!verifyBlock(startAddr + i*sizeof(uint16_t),
		       startAddr + addr, DELUGE_BYTES_PER_PAGE)) {
	return FALSE;
      }
      addr += DELUGE_BYTES_PER_PAGE;
    }

    return TRUE;
  }

  error_t programImage(ex_flash_addr_t startAddr) {
    uint8_t  buf[TOSBOOT_INT_PAGE_SIZE];
    uint32_t pageAddr, newPageAddr;
    in_flash_addr_t intAddr;
    in_flash_addr_t secLength;
    ex_flash_addr_t curAddr;

    if (!verifyImage(startAddr))
      return R_INVALID_IMAGE_ERROR;

    curAddr = startAddr + DELUGE_IDENT_SIZE + DELUGE_CRC_BLOCK_SIZE;

    call ExtFlash.startRead(curAddr);

    intAddr = extFlashReadAddr();
    secLength = extFlashReadAddr();
    curAddr = curAddr + 8;

#if defined(PLATFORM_TELOSB) || defined (PLATFORM_EPIC) || defined (PLATFORM_TINYNODE)
    if (intAddr != TOSBOOT_END) {
#elif defined(PLATFORM_MICAZ) || defined(PLATFORM_IRIS)
    if (intAddr != 0) {
#elif defined(PLATFORM_MULLE)
    if (intAddr != 0xA0000) {
#else
  #error "Target platform is not currently supported by Deluge T2"
#endif
      call ExtFlash.stopRead();
      return R_INVALID_IMAGE_ERROR;
    }

    call ExtFlash.stopRead();

    while ( secLength ) {

      pageAddr = newPageAddr = intAddr / TOSBOOT_INT_PAGE_SIZE;

      call ExtFlash.startRead(curAddr);
      // fill in ram buffer for internal program flash sector
      do {

	// check if secLength is all ones
	if ( secLength == 0xffffffff ) {
	  call ExtFlash.stopRead();
	  return FAIL;
	}

	buf[(uint16_t)intAddr % TOSBOOT_INT_PAGE_SIZE] = call ExtFlash.readByte();
	intAddr++; curAddr++;

	if ( --secLength == 0 ) {
	  intAddr = extFlashReadAddr();
	  secLength = extFlashReadAddr();
	  curAddr = curAddr + 8;
	}

	newPageAddr = intAddr / TOSBOOT_INT_PAGE_SIZE;

      } while ( pageAddr == newPageAddr && secLength );
      call ExtFlash.stopRead();

      call Leds.set(pageAddr);

      // write out page
      if (call ProgFlash.write(pageAddr*TOSBOOT_INT_PAGE_SIZE, buf,
			       TOSBOOT_INT_PAGE_SIZE) == FAIL) {
	return R_PROGRAMMING_ERROR;
      }
    }

    return R_SUCCESS;

  }

  void runApp() {
    call SubControl.stop();
    call Exec.exec();
  }

  void startupSequence() {

    BootArgs args;

    // check voltage and make sure flash can be programmed
    //   if not, just run the app, can't check for gestures
    //   if we can't write to the internal flash anyway
    if ( !call Voltage.okToProgram() ) {
      // give user some time and count down LEDs
      call Leds.flash(LEDS_LOWBATT);
      startupLeds();
      runApp();
    }

    // get current value of counter
    call IntFlash.read((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));

    // increment gesture counter, see if it exceeds threshold
    if ( ++args.gestureCount >= TOSBOOT_GESTURE_MAX_COUNT - 1 ) {
      // gesture has been detected, display receipt of gesture on LEDs
      call Leds.flash(LEDS_GESTURE);

      // load golden image from flash
      // if the golden image is invalid, forget about reprogramming
      // if an error happened during reprogramming, reboot and try again
      //   not much else we can do :-/
      if (programImage(TOSBOOT_GOLDEN_IMG_ADDR) == R_PROGRAMMING_ERROR) {
	call Hardware.reboot();
      }
    }
    else {
      // update gesture counter
      call IntFlash.write((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));
      if ( !args.noReprogram ) {
	// if an error happened during reprogramming, reboot and try again
	//   after two tries, try programming the golden image
	if (programImage(args.imageAddr) == R_PROGRAMMING_ERROR) {
	  call Hardware.reboot();
	}
      }
    }

    // give user some time and count down LEDs
    startupLeds();

    // reset counter and reprogramming flag
    args.gestureCount = 0xff;
    args.noReprogram = TRUE;
    call IntFlash.write((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));

    runApp();

  }
  
  void load() {
  	uint8_t tmp=0;
  	uint8_t codebuf[PAGE_SIZE];
    uint8_t bmbuf[BM_SIZE];
    uint8_t bmtype, symtype, codetype;
    uint16_t bmsize, symsize, codesize;
    
    uint16_t addrc, addrb;
    uint16_t symoffset;
    
    uint8_t b1, b2, b3;
    uint8_t section_count=0;

    call Leds.set(1);

  	// this function loads the files bm.raw, sym.raw, and old.raw/new.raw onto program flash
  	call ExtFlash.startRead(0);
  	bmtype = call ExtFlash.readByte();
  	bmsize = extFlashReadWord();
    //   b1 = call ExtFlash.readByte();
    //   b2 = call ExtFlash.readByte();
    //   b3 = call ExtFlash.readByte();
  	call ExtFlash.stopRead();
    
    
    
    call ExtFlash.startRead(3+bmsize);
  	symtype = call ExtFlash.readByte();
  	symsize = extFlashReadWord();
  	call ExtFlash.stopRead();
  	
  	
  	
  	call ExtFlash.startRead(6+bmsize+symsize);
  	codetype = call ExtFlash.readByte();
  	codesize = extFlashReadWord();
  	call ExtFlash.stopRead();

  	
  	symoffset = 6+bmsize;
  	addrc = 9+bmsize+symsize; // addr for code, 191,150
  	addrb = 3; // addr for bitmap
  	

  	while (1) {
  		uint32_t section_addr, section_len;
  		uint16_t memaddr;
  		
  		section_count++;
  		call ExtFlash.startRead(addrc);
  		section_addr = extFlashReadDWord();
  		section_len  = extFlashReadDWord();
  		call ExtFlash.stopRead();
  		
  		if (section_addr == 0 && section_len == 0) 
  			break;
  		
  		addrc += 8;
  		addrb += 8;
  		
  		memaddr = section_addr;
  		
  		while (section_len>0) {
  			uint16_t i, mylen, bmlen;
  			mylen = MIN(section_len,PAGE_SIZE);
  			
  			
  			
  			call ExtFlash.startRead(addrc);
  			for (i=0; i<mylen; i++) {
  			  codebuf[i] = call ExtFlash.readByte();
  		  }
  		  addrc += mylen;
  		  call ExtFlash.stopRead();
  		  
  		  //bmlen = MIN((mylen+15)/16, BM_SIZE); 
                  bmlen = (mylen/2+7) / 8;
  		  
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
            //1. read index :::result |= ((uint32_t)call ExtFlash.readByte() & 0xff) << (i*8);
            uint16_t index, target;
            index = ((uint16_t)codebuf[i+1]<<8) + codebuf[i];
            call ExtFlash.startRead(symoffset+index*2);
            target = extFlashReadWord();
            call ExtFlash.stopRead();   
        
            codebuf[i+1] = (uint8_t)(target>>8);
            codebuf[i] = (uint8_t)(target & 0xff);     
  		    }
  	    } // end relocate
  		  
  		  call ProgFlash.write(memaddr, codebuf, mylen);
  			
  			
  			section_len -= mylen;
  			memaddr += mylen;
  		} // end while (section_len>0) 
  	} // end while (1) for all sections 
  	runApp();
        //call Leds.set(7);
        //while (1) ;
  }

  int main() @C() @spontaneous() {

    __nesc_disable_interrupt();

    TOSH_SET_PIN_DIRECTIONS();
    call Hardware.init();

    call SubInit.init();
    call SubControl.start();
    //startupSequence();
    load();

    return 0;

  }

}

