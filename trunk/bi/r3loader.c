#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

typedef unsigned char uint8_t;
typedef char int8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;

#define PAGE_SIZE 512
#define BM_SIZE (PAGE_SIZE/16)

#define MIN(a,b) ((a)<(b)?(a):(b))

FILE *extfile, *progfile;

void ExtFlash_startRead(int offset) {
	fseek(extfile, offset, SEEK_SET);
}

void ExtFlash_stopRead() {}

uint8_t extFlashReadByte() {
	uint8_t byte;
	fread(&byte, 1, 1, extfile);
	return byte;
}
uint16_t extFlashReadWord() {
	uint16_t result = 0;
    int8_t  i;
    for ( i = 0; i <= 1; i++ )
      result |= ((uint16_t)extFlashReadByte() & 0xff) << (i*8);
    return result;
}

uint32_t extFlashReadDWord() {
	uint32_t result = 0;
    int8_t  i;
    for ( i = 0; i <= 3; i++ )
      result |= ((uint32_t)extFlashReadByte() & 0xff) << (i*8);
    return result;
}

void ProgFlash_write(int memaddr, void *codebuf, int mylen) {
	fseek(progfile, memaddr, SEEK_SET);
	fwrite(codebuf, mylen, 1, progfile);
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

  	// this function loads the files bm.raw, sym.raw, and old.raw/new.raw onto program flash
    ExtFlash_startRead(0);
  	bmtype = extFlashReadByte();
  	bmsize = extFlashReadWord();
    //   b1 = call ExtFlash.readByte();
    //   b2 = call ExtFlash.readByte();
    //   b3 = call ExtFlash.readByte();
  	ExtFlash_stopRead();
    
    
    
    ExtFlash_startRead(3+bmsize);
  	symtype = extFlashReadByte();
  	symsize = extFlashReadWord();
  	ExtFlash_stopRead();
  	
  	
  	
  	ExtFlash_startRead(6+bmsize+symsize);
  	codetype = extFlashReadByte();
  	codesize = extFlashReadWord();
  	ExtFlash_stopRead();

  	
  	symoffset = 6+bmsize;
  	addrc = 9+bmsize+symsize; // addr for code, 191,150
  	addrb = 0; // addr for bitmap
  	

  	while (1) {
  		uint32_t section_addr, section_len;
  		uint16_t memaddr;
  		
  		section_count++;
  		ExtFlash_startRead(addrc);
  		section_addr = extFlashReadDWord();
  		section_len  = extFlashReadDWord();
  		ExtFlash_stopRead();
  		
  		if (section_addr == 0 && section_len == 0) 
  			break;
  		
  		addrc += 8;
  		addrb += 8;
  		
  		memaddr = section_addr;
  		
  		while (section_len>0) {
  			uint16_t i, mylen, bmlen;
  			mylen = MIN(section_len,PAGE_SIZE);
  			
  			
  			
  			ExtFlash_startRead(addrc);
  			for (i=0; i<mylen; i++) {
  			  codebuf[i] = extFlashReadByte();
  		    }
  		  addrc += mylen;
  		  ExtFlash_stopRead();
  		  
  		  bmlen = MIN((mylen+15)/16, BM_SIZE); 
  		  
  		  ExtFlash_startRead(addrb);
  		  for (i=0; i<bmlen; i++) {
  		  	bmbuf[i] = extFlashReadByte();
  		  }
  		  addrb += bmlen;
  		  ExtFlash_stopRead();
  		  
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
            ExtFlash_startRead(symoffset+index*2);
            target = extFlashReadWord();
            ExtFlash_stopRead();   
        
            codebuf[i+1] = (uint8_t)(target>>8);
            codebuf[i] = (uint8_t)(target & 0xff);     
  		    }
  	    } // end relocate
  		  
  		  ProgFlash_write(memaddr, codebuf, mylen);
  			
  			
  			section_len -= mylen;
  			memaddr += mylen;
  		} // end while (section_len>0) 
  	} // end while (1) for all sections 
  	//runApp();
        //call Leds.set(7);
        //while (1) ;
}

int main(int argc, char** argv)
{
	extfile = fopen(argv[1], "rb");
	progfile = fopen("prog.raw", "wb");
	
	load();
	
	fclose(extfile);
	fclose(progfile);
	return 0;
}


