#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "elf32.h"

#ifndef S_IRWXG
#define S_IRWXG 00070
#endif

#ifndef S_IRWXO
#define S_IRWXO (S_IRWXG >> 3)
#endif

#define setbit(byte, offset)    byte |= 0x1<<(offset&0x7)
#define clearbit(byte, offset)  byte &= ~(0x1<<(offset&0x7))

// we should form a chained reference to reduce the # if relocation entries
int chained=0;

typedef struct reloc_t {
	unsigned short r_offset;
	unsigned short r_addr;
} reloc_t;

typedef struct rela_info_t {
  unsigned short elf_offset;
  reloc_t entry;
  struct rela_info_t * hnext; // the chained reference, i.e. refer to the same symbol address
  struct rela_info_t * vnext; // 
  unsigned short cr; // chained reference
} rela_info_t;

rela_info_t rela_header;
rela_info_t* last_rela = &rela_header;

int ucount = 0;

////////////////////////////////////
// ��main.exe��rela.text��rela.data����һ��������section��
// extract out rela.ihex and then modify main.exe correspondingly
int in, out, rel, crel; FILE* reltxt, *creltxt;
struct elf32_ehdr ehdr;
struct elf32_shdr shdr;

int raw, bm;
FILE *oldsymtxt, *newsymtxt;
int symraw;

char *dir;
	
char *shstrtab, *strtab;
	
struct elf32_rela rela;
struct elf32_sym symbol;
	
int text_off = 0, text_size = 0;
int data_off = 0, data_size = 0;
int bss_off = 0, bss_size = 0;
int symtab_off = 0, symtab_size = 0;
int strtab_off = 0, strtab_size = 0;
	
int vec_off = 0, vec_size = 0;
int vec_addr = 0;
int vecndx = 0;
	
int rela_off = 0, rela_size = 0; int rela_sec = -1;
int rela_data_off = 0, rela_data_size = 0;	int rela_data_sec = -1;
int rela_voff = 0, rela_vsize = 0; int rela_vsec = -1;
	
int textndx = -1, datandx = -1, bssndx = -1;
	
int text_addr = 0;
int data_addr = 0;
int bss_addr = 0;

char str[300]; // for storing symbol name

inline char* getstring(int name, char* strtab) 
{
	return (char*)(strtab+name);
}

// struct elf32_sym symbol;
struct elf32_sym findsymbol(int addr) // addr is the memory address
{
	int i;
	struct elf32_sym symbol;
	
	for (i=0; i<symtab_size; i+=sizeof(struct elf32_sym))
	{
		lseek(in, symtab_off+i, SEEK_SET);
		read(in, &symbol, sizeof(symbol));
		
		if (symbol.st_value == addr) {
		  if (ELF32_ST_TYPE(symbol.st_info) == STT_SECTION) continue;
		  else return symbol;
		}
	}
	memset(&symbol, 0, sizeof(symbol));
	return symbol;
}

void store_rela(unsigned short elf_offset, reloc_t entry)
{
   rela_info_t * newitem = (rela_info_t*)malloc(sizeof(rela_info_t));
   // we assume the original relocation entries are sorted by the to-be-fixed addresses.
   // Does this entry refers to a already appeared symbol?
   rela_info_t *ptr = NULL;

   newitem->elf_offset = elf_offset;
   newitem->entry = entry;
   newitem->hnext = newitem->vnext = NULL;
   newitem->cr = 0;
  
   int find = 0;

   for (ptr=rela_header.vnext; ptr != NULL; ptr = ptr->vnext) {
     // the symbol address is
     unsigned short sym_addr = ptr->entry.r_addr;
     if (newitem->entry.r_addr == sym_addr) {
       // put in h line through the hnext pointer
       rela_info_t * pp = NULL;
       find = 1;
       for (pp=ptr; pp->hnext != NULL; pp=pp->hnext) {
         
       }
       // pp->hnext == NULL now
       pp->hnext = newitem;
       // 4000 syma -> 4800 syma => 4000 syma -> 800 syma
       pp->cr = newitem->entry.r_offset - pp->entry.r_offset; // h line is for the same symbol
     }
   }
   if (!find) {
     // put in  v line through the vnext pointer
     last_rela->vnext = newitem;
     last_rela = newitem;
   }
}

void print_rela()
{
  rela_info_t *ptr;
  printf("print relas\n");
  for (ptr=rela_header.vnext; ptr != NULL; ptr = ptr->vnext) {
    rela_info_t *pp;
    
	// ע��r_offset��memory address�ĵط���Ҫ�޸ģ�r_addr��Ҫ�ĳ�ʲôֵ(Ŀ��)
	printf("Following addrs should be fixed to %s at %04X: \n", 
	        getstring(findsymbol(ptr->entry.r_addr).st_name, strtab), ptr->entry.r_addr);
	
    for (pp=ptr; pp != NULL; pp=pp->hnext) {
      printf(" (%04X %04X)", pp->entry.r_offset, pp->cr);
    }
    ucount++;
    printf("\n");
  }
  printf("ucount = %d\n", ucount);
}

// determine if waddr needs relocation?
int needreloc(int waddr)
{
	rela_info_t *ptr;
	for (ptr=rela_header.vnext; ptr != NULL; ptr = ptr->vnext) {
      rela_info_t *pp;
    
	  // ע��r_offset��memory address�ĵط���Ҫ�޸ģ�r_addr��Ҫ�ĳ�ʲôֵ(Ŀ��)
	  //printf("Following addrs should be fixed to %s at %04X: \n", 
	  //      getstring(findsymbol(ptr->entry.r_addr).st_name, strtab), ptr->entry.r_addr);
	
      for (pp=ptr; pp != NULL; pp=pp->hnext) {
        //printf(" (%04X %04X)", pp->entry.r_offset, pp->cr);
		if (pp->entry.r_offset == waddr) {
		  return 1; // need relocation
		}
      }
      ucount++;
    }
	return 0;
}

// generate the bitmap given main.raw
void genbitmap()
{
	int address;
	int size;
	int i;
	int offset_in_byte=0;
	unsigned char byte=0;
	
	// address(4bytes in raw), size (4bytes in raw), content
	// end of file: 8 zero bytes
	while (1) {
		read(raw, &address, 4); // address
		read(raw, &size, 4); // size
		
		write(bm, &address, 4);
		write(bm, &size, 4);
		byte = 0;
		offset_in_byte = 0;
		
		for (i=address; i<address+size; i+=2) {
			if (needreloc(i)) {
			  // set at offset_in_byte in byte
			  setbit(byte, offset_in_byte);
			} else {
			  clearbit(byte, offset_in_byte);
			}
			offset_in_byte++;
			
			if (offset_in_byte == 8) {
				// write to file
				write(bm, &byte, 1);
				byte=0;
				offset_in_byte = 0;
			}
		}
		lseek(raw, size, SEEK_CUR);
		
		
		if (address==0 && size==0) {
			break; // its the end of file
		}
	}
}

void gensym()
{
	char cmd[300];
	unsigned short addr = 0;
	rela_info_t *ptr;
	int index=0;
	
	// generate sym table according to sym.txt and modify the adresses in elf file
	sprintf(cmd, "%s/build/telosb/sym.txt", dir);
	newsymtxt = fopen(cmd, "r"); // for checking
	
	if (newsymtxt == NULL) return;
	
    // (1) Write to sym.raw	
	sprintf(cmd, "%s/build/telosb/sym.raw", dir);
	symraw = open(cmd, O_RDWR|O_CREAT); 
	
	// (2) Write out.exe
	index=0;
	while (!feof(newsymtxt)) {
		addr = 0;
		fscanf(newsymtxt, "%s %x", cmd, &addr);
		// write(out, instr, 2);
		write(symraw, &addr, 2);
		
		for (ptr=rela_header.vnext; ptr!=NULL; ptr=ptr->vnext) {
			struct elf32_sym symbol = findsymbol(ptr->entry.r_addr);
			rela_info_t *pp;
			if (strcmp(getstring(symbol.st_name, strtab), cmd) == 0) {
				//symbol.st_other = index;
				for (pp=ptr; pp!=NULL; pp=pp->hnext) {
					lseek(out, pp->elf_offset, SEEK_SET);
					write(out, &index, 2);
				}
			}
		}
		index++;
	}
	
	fclose(newsymtxt);
	close(symraw);
}

void free_rela_hline(rela_info_t *ptr)
{
  if (ptr->hnext == NULL) {
    free(ptr);
    return;
  }
  free_rela_hline(ptr->hnext);
}

// free_rela(rela_header.vnext)
void free_rela(rela_info_t *ptr)
{
  // free this line?
  if (ptr->vnext == NULL) {
    free_rela_hline(ptr);
    return;
  }
  free_rela(ptr->vnext);
}

int main(int argc, char **argv) 
{
	int offset;
    int i;
	reloc_t myloc;

	char cmd[300];
	
	//argv[1] is the dir
    dir = argv[1];

	printf("The working directory of bi (binary instrumentation) is %s\n", dir);

	sprintf(cmd, "cp %s/build/telosb/main.exe %s/build/telosb/out.exe", dir, dir);        
	system(cmd);

	sprintf(cmd, "rm -f %s/build/telosb/rela.raw", dir);
	system(cmd);
	
	sprintf(cmd, "%s/build/telosb/main.exe", dir);
	in = open(cmd, O_RDWR);

	sprintf(cmd, "%s/build/telosb/out.exe", dir);
	out = open(cmd, O_RDWR);
	
	sprintf(cmd, "%s/build/telosb/rela.raw", dir);
	rel = open(cmd, O_RDWR|O_CREAT);
	
	// the chained reference version
	sprintf(cmd, "%s/build/telosb/crela.raw", dir);
	crel = open(cmd, O_RDWR|O_CREAT);
	
	sprintf(cmd, "%s/build/telosb/rela.txt", dir);
	reltxt = fopen(cmd, "w+");
	
	// the chained reference version
	sprintf(cmd, "%s/build/telosb/crela.txt", dir);
	creltxt = fopen(cmd, "w+");
	
	// the bitmap indicating relocation: assume the existance of main.raw
	sprintf(cmd, "%s/build/telosb/main.raw", dir);
	raw = open(cmd, O_RDWR);
	
	sprintf(cmd, "%s/build/telosb/bm.raw", dir);
	bm = open(cmd, O_RDWR|O_CREAT); 
	
	// symbols address and allocation of 'jump table'
	/*
	sprintf(cmd, "%s/build/telosb/oldsym.txt", dir);
	oldsymtxt = fopen(cmd, "r");
	*/
	
	
       
	if (in <0) {
		printf("failed to open build/telosb/main.exe\n");
		return -1;
	}
	
	// read in elf header
	read(in, &ehdr, sizeof(ehdr));
	if (memcmp(ehdr.e_ident, elf_magic_header, 7) != 0 /*|| ehdr.e_type != ET_REL*/)
	{
		printf("incorrect elf header in main.exe\n");
		return -1;	
	}
	offset = ehdr.e_shoff + ehdr.e_shstrndx*ehdr.e_shentsize;
	lseek(in, offset, SEEK_SET);
	read(in, &shdr, sizeof(shdr));
	
	shstrtab = (char*)malloc(shdr.sh_size);
	lseek(in, shdr.sh_offset, SEEK_SET);
	read(in, shstrtab, shdr.sh_size);
	
	for (i=0; i<ehdr.e_shnum; ++i) 
	{
		offset = ehdr.e_shoff + i*ehdr.e_shentsize;
		lseek(in, offset, SEEK_SET);
		read(in, &shdr, sizeof(shdr));
		
		if (shdr.sh_size == 0)
			continue;
		switch (shdr.sh_type) 
		{
			case SHT_NULL:
				break;
			case SHT_SYMTAB:
				if (strcmp(".symtab", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					symtab_off = shdr.sh_offset;
					symtab_size = shdr.sh_size;
				}
				break;
			case SHT_STRTAB:
				if (strcmp(".strtab", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					strtab_off = shdr.sh_offset;
					strtab_size = shdr.sh_size;
				}
				break;
			case SHT_PROGBITS: // text + data
				if (strcmp(".data", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					data_off = shdr.sh_offset;
					data_size = shdr.sh_size;
					datandx = i;
					
					data_addr = shdr.sh_addr;
				}
				else if (strcmp(".text", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					text_off = shdr.sh_offset;
					text_size = shdr.sh_size;
					textndx = i;
					
					text_addr = shdr.sh_addr;
				}
				else if (strcmp(".vectors", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					vec_off = shdr.sh_offset;
					vec_size = shdr.sh_size;
					
					vecndx = i;
					vec_addr = shdr.sh_addr;
				}
				break;
			case SHT_NOBITS:
				if (strcmp(".bss", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					bss_off = shdr.sh_offset;
					bss_size = shdr.sh_size;
					bssndx = i;
					
					bss_addr = shdr.sh_addr;
				}
				break;
			case SHT_REL:
				// do not handle this
				break;
			case SHT_RELA:
				if (strcmp(".rela.text", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					rela_off = shdr.sh_offset;
					rela_size = shdr.sh_size;
					rela_sec = shdr.sh_info;
				}
				else if (strcmp(".rela.data", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					rela_data_off = shdr.sh_offset;
					rela_data_size = shdr.sh_size;
					rela_data_sec = shdr.sh_info;
				}
				else if (strcmp(".rela.vectors", getstring(shdr.sh_name, shstrtab)) == 0)
				{
					rela_voff = shdr.sh_offset;
					rela_vsize = shdr.sh_size;
					rela_vsec = shdr.sh_info;
				}	
				break;	
			default:
				break;
		}
	}
	
	free(shstrtab);
	
	strtab = (char*)malloc(strtab_size);
	lseek(in, strtab_off, SEEK_SET);
	read(in, strtab, strtab_size);
	
	printf("Number of relocation entries: %d(.rela.text)+%d(.rela.data)+%d(.rela.vectors)=%d\n", 
	                                      rela_size/sizeof(rela), 
	                                      rela_data_size/sizeof(rela),
										  rela_vsize/sizeof(rela),
	                                      (rela_size+rela_data_size+rela_vsize)/sizeof(rela));
	if (rela_size+rela_data_size+rela_vsize == 0) {
		// not relocatable file
		goto exit;
	}
/////////////////////////////////////////////for rela.text////////////////////////////////////////////
	for (i=0; i<rela_size; i+=sizeof(rela))
	{
		int addr;
		unsigned char realb[2];
		unsigned char instr[2];
		
		lseek(in, rela_off+i, SEEK_SET);
		read(in, &rela, sizeof(rela));
		
		// ��relocation entry��Ӧ�ĸ�symbol
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		lseek(in, offset, SEEK_SET);
		read(in, &symbol, sizeof(symbol));
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // ���Ե�ַ
		//else if (symbol.st_shndx == SHN_COMMON) {} // the section which the symbol resides in not allocated yet!!!
		//else if (symbol.st_shndx == SHN_UNDEF) {}
		
		if (rela_sec == textndx) offset = text_off - text_addr; // off: �ļ�ƫ��, addr: memory address
		else if (rela_sec == datandx) offset = data_off - data_addr;
		else if (rela_sec == bssndx) offset = bss_off - bss_addr;
		else if (rela_sec == vecndx) offset = vec_off - vec_addr;
		
		// for exe, rela.r_offset is the virtual address that needs to be modified
		offset += rela.r_offset; // convert memory address to file address
		
		instr[0] = (unsigned char)addr;
		instr[1] = (unsigned char)(addr >> 8);
		
		lseek(in, offset, SEEK_SET);
		read(in, realb, 2);
		
		if (!symbol.st_name) {
			// see if we can find one
			symbol = findsymbol( (realb[1]<<8)+realb[0]); // st_value should also be fixed
			//fixing this also
			rela.r_addend = (realb[1]<<8)+realb[0] - symbol.st_value;
		}
		// note that realb[1]realb[0] is the right address, we need to fix the symbol.st_value
		
		if (rela.r_addend == 0) {
			sprintf(str, "%s", getstring(symbol.st_name, strtab));
		} else {
			sprintf(str, "%s+%d", getstring(symbol.st_name, strtab), rela.r_addend);
		}
		printf("ref_sym_text <%s> %02x%02x (from code) = %x (%x+ from symbol) Mem[%x]\n", 
		       str, realb[1], realb[0], 
			   symbol.st_value+rela.r_addend, symbol.st_value, 
		       rela.r_offset); 
	    // fixbug: ������GCC������, symbol address��̫�ԣ���ʹ��readelfҲ���������⡣
		// ����ͨ��realb���з�����ң��ҵ���Ӧ��symbol
		
		
		//printf("OFFSET1: %d\n", offset);
		
		// (1) write to elf file: simply set it to zero
		lseek(out, offset, SEEK_SET);
		instr[0] = instr[1] = 0;
		write(out, instr, 2);
		
		// (2) write to rel
		// ��Ҫ�����ĵ�ַ address in the file or the virtual address (i.e. load address)
		// we use the virtual address first
		myloc.r_offset = rela.r_offset; // ������Ҫ�޸�
		
		lseek(in, offset, SEEK_SET);
		read(in, &myloc.r_addr, 2); // �޸ĳ�ʲôֵ
		
		write(rel, &myloc, sizeof(myloc));
		
        fprintf(reltxt, "%04X %04X\n", myloc.r_offset, myloc.r_addr);
        store_rela(offset, myloc);                
	}
	
/////////////////////////////////////////////for rela.data////////////////////////////////////////////	
	for (i=0; i<rela_data_size; i+=sizeof(rela))
	{
		int addr;
		unsigned char realb[2];
		unsigned char instr[2];
		
		lseek(in, rela_data_off+i, SEEK_SET);
		read(in, &rela, sizeof(rela));
		
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		lseek(in, offset, SEEK_SET);
		read(in, &symbol, sizeof(symbol));
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // ���Ե�ַ
		//else if (symbol.st_shndx == SHN_COMMON) {} // the section which the symbol resides in not allocated yet!!!
		//else if (symbol.st_shndx == SHN_UNDEF) {}
		
		if (rela_data_sec == textndx) offset = text_off - text_addr;
		else if (rela_data_sec == datandx) offset = data_off - data_addr;
		else if (rela_data_sec == bssndx) offset = bss_off - bss_addr;
		else if (rela_data_sec == vecndx) offset = vec_off - vec_addr;
		
		// for exe, rela.r_offset is the virtual address that needs to be modified
		offset += rela.r_offset;
		
		instr[0] = (unsigned char)addr;
		instr[1] = (unsigned char)(addr >> 8);
		
		lseek(in, offset, SEEK_SET);
		read(in, realb, 2);
		
		if (rela.r_addend == 0) {
			sprintf(str, "%s", getstring(symbol.st_name, strtab));
		} else {
			sprintf(str, "%s+%d", getstring(symbol.st_name, strtab), rela.r_addend);
		}
		// note that realb[1]realb[0] is the right address, we need to fix the symbol.st_value
		printf("ref_sym_data <%s> %02X%02X = %x Mem[%x]\n", 
		       str, realb[1], realb[0], symbol.st_value+rela.r_addend,
		       rela.r_offset);
		
		//printf("OFFSET2: %d\n", offset);
		
		// (1) Write to elf:  set it to zero
		lseek(out, offset, SEEK_SET);
		instr[0] = instr[1] = 0;
		write(out, instr, 2);
		
		// (2) Write to rel
		myloc.r_offset = offset; 
		lseek(in, offset, SEEK_SET);
		read(in, &myloc.r_addr, 2);
		
		write(rel, &myloc, sizeof(myloc));
		
		fprintf(reltxt, "%04X %04X\n", myloc.r_offset, myloc.r_addr);
        store_rela(offset, myloc);
	}
	
/////////////////////////////////////////////for rela.vectors////////////////////////////////////////////	
	for (i=0; i<rela_vsize; i+=sizeof(rela))
	{
		int addr;
		unsigned char realb[2];
		unsigned char instr[2];
		
		lseek(in, rela_voff+i, SEEK_SET);
		read(in, &rela, sizeof(rela));
		
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		lseek(in, offset, SEEK_SET);
		read(in, &symbol, sizeof(symbol));
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // ���Ե�ַ
		//else if (symbol.st_shndx == SHN_COMMON) {} // the section which the symbol resides in not allocated yet!!!
		//else if (symbol.st_shndx == SHN_UNDEF) {}
		
		if (rela_vsec == textndx) offset = text_off - text_addr;
		else if (rela_vsec == datandx) offset = data_off - data_addr;
		else if (rela_vsec == bssndx) offset = bss_off - bss_addr;
		else if (rela_vsec == vecndx) offset = vec_off - vec_addr;
		
		// for exe, rela.r_offset is the virtual address that needs to be modified
		offset += rela.r_offset;
		
		instr[0] = (unsigned char)addr;
		instr[1] = (unsigned char)(addr >> 8);
		
		lseek(in, offset, SEEK_SET);
		read(in, realb, 2);
		
		if (rela.r_addend == 0) {
			sprintf(str, "%s", getstring(symbol.st_name, strtab));
		} else {
			sprintf(str, "%s+%d", getstring(symbol.st_name, strtab), rela.r_addend);
		}
		// note that realb[1]realb[0] is the right address, we need to fix the symbol.st_value
		printf("ref_sym_vectors <%s> %02X%02X = %x Mem[%x]\n", 
		       str, realb[1], realb[0], symbol.st_value+rela.r_addend,
		       rela.r_offset);
		
		//printf("OFFSET3: %d\n", offset);
		
		// (1) Write to elf: set it to zero
		lseek(out, offset, SEEK_SET);
		instr[0] = instr[1] = 0;
		write(out, instr, 2);
		
		// (2) Write to rel
		myloc.r_offset = offset; 
		lseek(in, offset, SEEK_SET);
		read(in, &myloc.r_addr, 2);
		
		write(rel, &myloc, sizeof(myloc));
		
		fprintf(reltxt, "%04X %04X\n", myloc.r_offset, myloc.r_addr);
        store_rela(offset, myloc);
	}

	
//  perform_chain_ref(out);
//  write into exe/elf file
	
	rela_info_t * ptr;
        
	if (chained) {
		for (ptr = rela_header.vnext; ptr != NULL; ptr = ptr->vnext) {
          rela_info_t *pp;
          for (pp=ptr; pp != NULL; pp=pp->hnext) {
            unsigned char instr[2];
            instr[0] = (unsigned char)pp->cr; instr[1] = (unsigned char)(pp->cr>>8);
            lseek(out, pp->elf_offset, SEEK_SET);
            write(out, instr, 2);
          }
		} 
	}
        
	// write the relocation entry table
    for (ptr = rela_header.vnext; ptr != NULL; ptr = ptr->vnext) {
      write(crel, &ptr->entry, sizeof(reloc_t));
      fprintf(creltxt, "%04X %04X\n", ptr->entry.r_offset, ptr->entry.r_addr);
    }
	
    print_rela();
	//printf("test: %s\n", getstring(findsymbol(0x1100).st_name, strtab));
	
	genbitmap();

exit:
	close(in);
	close(out);
	close(rel);     
	close(crel);
	
	close(bm);
	
	fclose(reltxt); 
	fclose(creltxt);
       
    free_rela(rela_header.vnext);
	return 0;
}