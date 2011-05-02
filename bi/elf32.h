

#ifndef __ELF32_H__
#define __ELF32_H__

/*
 * ELF definitions common to all 32-bit architectures.
 */


#define EI_NIDENT 16
#define ELF_MAGIC_HEADER_SIZE    7

typedef unsigned int uint32_t;



typedef unsigned int    elf32_word;
typedef  int            elf32_sword;
typedef unsigned short  elf32_half;
typedef unsigned int    elf32_off;
typedef unsigned int    elf32_addr;

struct elf32_ehdr {
  unsigned char e_ident[EI_NIDENT];    	   /* ident bytes */
  elf32_half e_type;                   /* file type */ 
  elf32_half e_machine;                /* target machine */
  elf32_word e_version;                /* file version */
  elf32_addr e_entry;                  /* start address */
  elf32_off e_phoff;                   /* phdr file offset */
  elf32_off e_shoff;                   /* shdr file offset */
  elf32_word e_flags;                  /* file flags */
  elf32_half e_ehsize;                 /* sizeof ehdr */
  elf32_half e_phentsize;              /* sizeof phdr */
  elf32_half e_phnum;                  /* number phdrs */
  elf32_half e_shentsize;              /* sizeof shdr */
  elf32_half e_shnum;                  /* number shdrs */
  elf32_half e_shstrndx;               /* shdr string index */
};

/* Values for e_type. */
#define ET_NONE         0       /* Unknown type. */
#define ET_REL          1       /* Relocatable. */
#define ET_EXEC         2       /* Executable. */
#define ET_DYN          3       /* Shared object. */
#define ET_CORE         4       /* Core file. */


/* Values for e_machine, which identifies the architecture.  These numbers
   are officially assigned by registry@caldera.com.  See below for a list of
   ad-hoc numbers used during initial development.  */

#define EM_NONE		  0	/* No machine */
#define EM_M32		  1	/* AT&T WE 32100 */
#define EM_SPARC	  2	/* SUN SPARC */
#define EM_386		  3	/* Intel 80386 */
#define EM_68K		  4	/* Motorola m68k family */
#define EM_88K		  5	/* Motorola m88k family */
#define EM_486		  6	/* Intel 80486 *//* Reserved for future use */
#define EM_860		  7	/* Intel 80860 */
#define EM_MIPS		  8	/* MIPS R3000 (officially, big-endian only) */
#define EM_S370		  9	/* IBM System/370 */
#define EM_MIPS_RS3_LE	 10	/* MIPS R3000 little-endian (Oct 4 1999 Draft) Deprecated */

#define EM_AVR		 83	/* Atmel AVR 8-bit microcontroller */
#define EM_MSP430	105	/* TI msp430 micro controller */

#define elf_check_arch(x) ((x)->e_machine == EM_AVR)

struct elf32_shdr {
  elf32_word sh_name; 		/* section name */
  elf32_word sh_type; 		/* SHT_... */
  elf32_word sh_flags; 	    /* SHF_... */
  elf32_addr sh_addr; 		/* virtual address */
  elf32_off sh_offset; 	    /* file offset */
  elf32_word sh_size; 		/* section size */
  elf32_word sh_link; 		/* misc info */
  elf32_word sh_info; 		/* misc info */
  elf32_word sh_addralign; 	/* memory alignment */
  elf32_word sh_entsize; 	/* entry size if table */
};

/* sh_type */
#define SHT_NULL        0               /* inactive */
#define SHT_PROGBITS    1               /* program defined information */
#define SHT_SYMTAB      2               /* symbol table section */
#define SHT_STRTAB      3               /* string table section */
#define SHT_RELA        4               /* relocation section with addends*/
#define SHT_HASH        5               /* symbol hash table section */
#define SHT_DYNAMIC     6               /* dynamic section */
#define SHT_NOTE        7               /* note section */
#define SHT_NOBITS      8               /* no space section */
#define SHT_REL         9               /* relation section without addends */
#define SHT_SHLIB       10              /* reserved - purpose unknown */
#define SHT_DYNSYM      11              /* dynamic symbol table section */
#define SHT_LOPROC      0x70000000      /* reserved range for processor */
#define SHT_HIPROC      0x7fffffff      /* specific section header types */
#define SHT_LOUSER      0x80000000      /* reserved range for application */
#define SHT_HIUSER      0xffffffff      /* specific indexes */


/* Values for section header, sh_flags field.  */

#define SHT_WRITE	(1 << 0)	/* Writable data during execution */
#define SHT_ALLOC	(1 << 1)	/* Occupies memory during execution */
#define SHT_EXECINSTR	(1 << 2)	/* Executable machine instructions */
#define SHT_MERGE	(1 << 4)	/* Data in this section can be merged */
#define SHT_STRINGS	(1 << 5)	/* Contains null terminated character strings */
#define SHT_INFO_LINK	(1 << 6)	/* sh_info holds section header table index */
#define SHT_LINK_ORDER	(1 << 7)	/* Preserve section ordering when linking */
#define SHT_OS_NONCONFORMING (1 << 8)	/* OS specific processing required */
#define SHT_GROUP	(1 << 9)	/* Member of a section group */
#define SHT_TLS		(1 << 10)	/* Thread local storage section */


struct elf32_rel {
  elf32_addr      r_offset;       /* Location to be relocated. */
  elf32_word      r_info;         /* Relocation type and symbol index. */
};

struct elf32_rela {
  elf32_addr      r_offset;       /* Location to be relocated. */
  elf32_word      r_info;         /* Relocation type and symbol index. */
  elf32_sword     r_addend;       /* Addend. */
};

struct elf32_sym {
  elf32_word		st_name;        /* String table index of name. */
  elf32_addr		st_value;       /* Symbol value. */
  elf32_word		st_size;        /* Size of associated object. */
  unsigned char		st_info;        /* Type and binding information. */
  unsigned char		st_other;       /* Reserved (not used). */
  elf32_half		st_shndx;       /* Section index of symbol. */
};


/* Values for e_type. */
#define ET_NONE         0       /* Unknown type. */
#define ET_REL          1       /* Relocatable. */
#define ET_EXEC         2       /* Executable. */
#define ET_DYN          3       /* Shared object. */
#define ET_CORE         4       /* Core file. */


/* sh_type */
#define SHT_NULL        0               /* inactive */
#define SHT_PROGBITS    1               /* program defined information */
#define SHT_SYMTAB      2               /* symbol table section */
#define SHT_STRTAB      3               /* string table section */
#define SHT_RELA        4               /* relocation section with addends*/
#define SHT_HASH        5               /* symbol hash table section */
#define SHT_DYNAMIC     6               /* dynamic section */
#define SHT_NOTE        7               /* note section */
#define SHT_NOBITS      8               /* no space section */
#define SHT_REL         9               /* relation section without addends */
#define SHT_SHLIB       10              /* reserved - purpose unknown */
#define SHT_DYNSYM      11              /* dynamic symbol table section */
#define SHT_LOPROC      0x70000000      /* reserved range for processor */
#define SHT_HIPROC      0x7fffffff      /* specific section header types */
#define SHT_LOUSER      0x80000000      /* reserved range for application */
#define SHT_HIUSER      0xffffffff      /* specific indexes */

/* sh_flags */
#define SHF_WRITE	0x1
#define SHF_ALLOC	0x2
#define SHF_EXECINSTR	0x4
#define SHF_MASKPROC	0xf0000000

/* special section indexes */
#define SHN_UNDEF	0
#define SHN_LORESERVE	0xff00
#define SHN_LOPROC	0xff00
#define SHN_HIPROC	0xff1f
#define SHN_ABS		0xfff1
#define SHN_COMMON	0xfff2
#define SHN_HIRESERVE	0xffff


#define ELF32_R_SYM(info)       ((info) >> 8)
#define ELF32_R_TYPE(info)      ((unsigned char)(info))

/* Type for the symbols */
 
#define STT_NOTYPE	0		/* Symbol type is unspecified */
#define STT_OBJECT	1		/* Symbol is a data object */
#define STT_FUNC	2		/* Symbol is a code object */
#define STT_SECTION	3		/* Symbol associated with a section */
#define STT_FILE	4		/* Symbol gives a file name */
#define STT_COMMON	5		/* An uninitialised common block */
#define STT_TLS		6		/* Thread local data object */
#define STT_LOOS	10		/* OS-specific semantics */
#define STT_HIOS	12		/* OS-specific semantics */
#define STT_LOPROC	13		/* Application-specific semantics */
#define STT_HIPROC	15		/* Application-specific semantics */


/**
 * The relation types for ELF file
 */
 
#define R_AVR_NONE             0
#define R_AVR_32               1
#define R_AVR_7_PCREL          2
#define R_AVR_13_PCREL         3
#define R_AVR_16               4
#define R_AVR_16_PM            5
#define R_AVR_LO8_LDI          6
#define R_AVR_HI8_LDI          7
#define R_AVR_HH8_LDI          8
#define R_AVR_LO8_LDI_NEG      9
#define R_AVR_HI8_LDI_NEG     10
#define R_AVR_HH8_LDI_NEG     11
#define R_AVR_LO8_LDI_PM      12
#define R_AVR_HI8_LDI_PM      13
#define R_AVR_HH8_LDI_PM      14
#define R_AVR_LO8_LDI_PM_NEG  15
#define R_AVR_HI8_LDI_PM_NEG  16
#define R_AVR_HH8_LDI_PM_NEG  17
#define R_AVR_CALL            18


/**
 * Return value from load_module() indicating that loading worked.
 */
#define ELF_OK                  0
#define ELF_BAD_ELF_HEADER      1
#define ELF_BAD_ELF_TYPE		2	
#define ELF_NO_SYMTAB           3
#define ELF_NO_STRTAB           4
#define ELF_NO_TEXT             5
#define ELF_SYMBOL_NOT_FOUND    6
#define ELF_SEGMENT_NOT_FOUND   7
#define ELF_NO_STARTPOINT       8
#define ELF_BAD_RELTYPE		  	9
#define ELF_COMMON_SYM			10
#define ELF_NO_MEMORY			11


/**
 * The magic number of the ELF file.
 */
const static unsigned char elf_magic_header[] =
{
	0x7f, 0x45, 0x4c, 0x46,  /* 0x7f, 'E', 'L', 'F' */
   	0x01,                    /* Only 32-bit objects. */
   	0x01,                    /* Only LSB data. */
   	0x01,                    /* Only ELF version 1. */
};




#define ALLOC_OK			0
#define ALLOC_NO_ROM		1
#define ALLOC_NO_RAM		2


#define ELF32_ST_BIND(i)	((i)>>4)
#define ELF32_ST_TYPE(i)	((i)&0xf)
#define ELF32_ST_INFO(b, t)	(((b)<<4)+((t)&0xf))

#endif /* ELF32_H */


