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

// 0: the out.exe inflated with 0
// 1: chained
// 2: symbol table index
int option=0; 

typedef struct reloc_t {
	unsigned short r_offset; 
	unsigned short r_addr;
	elf32_word st_name;
	elf32_sword r_addend;
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
// 把main.exe中rela.text和rela.data放在一个单独的section中
// extract out rela.ihex and then modify main.exe correspondingly
FILE *in; 

struct elf32_ehdr ehdr;
struct elf32_shdr shdr;

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
		fseek(in, symtab_off+i, SEEK_SET);
		fread(&symbol, sizeof(symbol), 1, in);
		
		if (symbol.st_value == addr) {
		  if (ELF32_ST_TYPE(symbol.st_info) == STT_SECTION) continue;
		  else return symbol;
		}
	}
	memset(&symbol, 0, sizeof(symbol));
	return symbol;
}

int main(int argc, char **argv) 
{
	unsigned char op[2];
	
	int offset;
    int i;
	reloc_t myloc;

	char cmd[300];
	
	//argv[1] is the dir
	if (argc == 2) {
		option = 0;
		dir = argv[1];
	} else {
	    option = atoi(argv[1]);
        dir = argv[2];
	}

  // dir is the main.exe now
	printf("The processed file is %s\n", dir);

	in = fopen(dir, "rb+");

	if (in == NULL) {
		printf("failed to open %s\n", dir);
		return -1;
	}
	
	// read in elf header
	fread(&ehdr, sizeof(ehdr), 1, in);
	if (memcmp(ehdr.e_ident, elf_magic_header, 7) != 0 /*|| ehdr.e_type != ET_REL*/)
	{
		printf("incorrect elf header in main.exe\n");
		return -1;	
	}
	offset = ehdr.e_shoff + ehdr.e_shstrndx*ehdr.e_shentsize;
	fseek(in, offset, SEEK_SET);
	fread(&shdr, sizeof(shdr), 1, in);
	
	shstrtab = (char*)malloc(shdr.sh_size);
	fseek(in, shdr.sh_offset, SEEK_SET);
	fread(shstrtab, shdr.sh_size, 1, in);
	
	for (i=0; i<ehdr.e_shnum; ++i) 
	{
		offset = ehdr.e_shoff + i*ehdr.e_shentsize;
		fseek(in, offset, SEEK_SET);
		fread(&shdr, sizeof(shdr), 1, in);
		
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
	fseek(in, strtab_off, SEEK_SET);
	fread(strtab, strtab_size, 1, in);
	
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
		
		
		fseek(in, rela_off+i, SEEK_SET);
		fread(&rela, sizeof(rela), 1, in);
		
		// 该relocation entry对应哪个symbol
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		fseek(in, offset, SEEK_SET);
		fread(&symbol, sizeof(symbol), 1, in);
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // 绝对地址
		//else if (symbol.st_shndx == SHN_COMMON) {} // the section which the symbol resides in not allocated yet!!!
		//else if (symbol.st_shndx == SHN_UNDEF) {}
		
		if (rela_sec == textndx) offset = text_off - text_addr; // off: 文件偏移, addr: memory address
		else if (rela_sec == datandx) offset = data_off - data_addr;
		else if (rela_sec == bssndx) offset = bss_off - bss_addr;
		else if (rela_sec == vecndx) offset = vec_off - vec_addr;
		
		// for exe, rela.r_offset is the virtual address that needs to be modified
		offset += rela.r_offset; // convert memory address to file address
		
		instr[0] = (unsigned char)addr;
		instr[1] = (unsigned char)(addr >> 8);
		
		fseek(in, offset, SEEK_SET);
		fread(realb, 2, 1, in);
		
		if (!symbol.st_name) {
			// see if we can find one: 优先考虑原来的symbol
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
		
		
		fseek(in, offset-2, SEEK_SET);
		fread(op, 2, 1, in);
		
		printf("ref_sym_text <%s> %02x%02x (from code) = %x (%x+ from symbol) Mem[%x] %02x%02x\n", 
		       str, realb[1], realb[0], 
			   symbol.st_value+rela.r_addend, symbol.st_value, 
		       rela.r_offset,
		       op[0], op[1]); 
	    // fixbug: 可能是GCC的问题? symbol address不太对，即使用readelf也好像有问题。
		// 可以通过realb进行反向查找，找到相应的symbol
		
		
		//printf("OFFSET1: %d\n", offset);
		
		                
	}
	
/////////////////////////////////////////////for rela.data////////////////////////////////////////////	
	for (i=0; i<rela_data_size; i+=sizeof(rela))
	{
		int addr;
		unsigned char realb[2];
		unsigned char instr[2];
		
		fseek(in, rela_data_off+i, SEEK_SET);
		fread(&rela, sizeof(rela), 1, in);
		
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		fseek(in, offset, SEEK_SET);
		fread(&symbol, sizeof(symbol), 1, in);
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // 绝对地址
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
		
		fseek(in, offset, SEEK_SET);
		fread(realb, 2, 1, in);
		
		if (!symbol.st_name) {
			// see if we can find one: 优先考虑原来的symbol
			symbol = findsymbol( (realb[1]<<8)+realb[0]); // st_value should also be fixed
			//fixing this also
			rela.r_addend = (realb[1]<<8)+realb[0] - symbol.st_value;
		}
		
		if (rela.r_addend == 0) {
			sprintf(str, "%s", getstring(symbol.st_name, strtab));
		} else {
			sprintf(str, "%s+%d", getstring(symbol.st_name, strtab), rela.r_addend);
		}
		
		fseek(in, offset-2, SEEK_SET);
		fread(op, 2, 1, in);
		// note that realb[1]realb[0] is the right address, we need to fix the symbol.st_value
		printf("ref_sym_data <%s> %02X%02X = %x Mem[%x] %02x%02x\n", 
		       str, realb[1], realb[0], symbol.st_value+rela.r_addend,
		       rela.r_offset,
		       op[0], op[1]);
		
		
	}
	
/////////////////////////////////////////////for rela.vectors////////////////////////////////////////////	
	for (i=0; i<rela_vsize; i+=sizeof(rela))
	{
		int addr;
		unsigned char realb[2];
		unsigned char instr[2];
		
		fseek(in, rela_voff+i, SEEK_SET);
		fread(&rela, sizeof(rela), 1, in);
		
		offset = symtab_off + sizeof(struct elf32_sym)*ELF32_R_SYM(rela.r_info);
		fseek(in, offset, SEEK_SET);
		fread(&symbol, sizeof(symbol), 1, in);
		
		if (symbol.st_shndx == textndx) addr = text_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == datandx) addr = data_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == bssndx) // cannot happen if real bss. if symbol resides in bss, the index will be SHN_COMMON
			addr = bss_addr + symbol.st_value + rela.r_addend;
		else if (symbol.st_shndx == SHN_ABS) addr = symbol.st_value; // 绝对地址
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
		
		fseek(in, offset, SEEK_SET);
		fread(realb, 2, 1, in);
		
		if (!symbol.st_name) {
			// see if we can find one: 优先考虑原来的symbol
			symbol = findsymbol( (realb[1]<<8)+realb[0]); // st_value should also be fixed
			//fixing this also
			rela.r_addend = (realb[1]<<8)+realb[0] - symbol.st_value;
		}
		
		if (rela.r_addend == 0) {
			sprintf(str, "%s", getstring(symbol.st_name, strtab));
		} else {
			sprintf(str, "%s+%d", getstring(symbol.st_name, strtab), rela.r_addend);
		}
		
		fseek(in, offset-2, SEEK_SET);
		fread(op, 2, 1, in);
		// note that realb[1]realb[0] is the right address, we need to fix the symbol.st_value
		printf("ref_sym_vectors <%s> %02X%02X = %x Mem[%x] %02x%02x\n", 
		       str, realb[1], realb[0], symbol.st_value+rela.r_addend,
		       rela.r_offset,
		       op[0], op[1]);
		
		
	}


exit:	
	fclose(in);
	
  
	return 0;
}
