#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#define MIN(a,b) ((a)<(b)?(a):(b))

FILE *sym, *bm, *code, *newfile;
int symsize, bmsize, codesize;
int main(int argc, char **argv)
{
	unsigned char *codebuf, *bmbuf;
	int codeaddr, bmaddr,symaddr;
	codebuf = (unsigned char*)malloc(480);
	bmbuf = (unsigned char*)malloc(30);
	sym = fopen(argv[1], "rb");
	if (sym == NULL) {
		printf("sym file err\n");	
		return -1;
	}
	bm = fopen(argv[2], "rb");
	if (bm == NULL){
		printf("bm file err\n");	
		return -1;
	}
	
	code = fopen(argv[3], "rb");
	if (code == NULL){
		printf("code file err\n");			
		return -1;
	}	
	newfile = fopen(argv[4], "wb");
	if (newfile == NULL){
		printf("new file err\n");			
		return -1;
	}
	fseek(code, 0, SEEK_END);
	codesize = ftell(code);
	rewind(code);

	fseek(bm, 0, SEEK_END);
	bmsize = ftell(bm);
	rewind(bm);

	fseek(sym, 0, SEEK_END);
	symsize = ftell(sym);
	rewind(sym);

	codeaddr=0;
	bmaddr=0;
	symaddr=0;
	while (codeaddr < codesize) {
		unsigned int section_base_address=0;
		int section_size=0;
		unsigned int memaddr=0;
		int mylen=0, mybase=0, bmlen=0;
	//  section_base_address = ?; // 4bytes
	//  section_size = ?; // 4 bytes
		fread(&section_base_address,4,1,code);
		fread(&section_size,4,1,code);
		mylen = section_size;
		mybase = section_base_address;
		printf("section_size=%d, base addr=%d\n",section_size,section_base_address);
		if(section_base_address ==0 && section_size ==0)
		{
			break;
		}
		codeaddr += 8;
		bmaddr += 8;
		memaddr = section_base_address;
		while (section_size > 0) {
			int i ;
			mylen = MIN(480, section_size);
//			mybase += mylen;
			fread(codebuf,mylen,1,code);
//			codebuf <- read at addr for mylen
			codeaddr += mylen;
//			section_size -= mylen;
			bmlen = MIN(30, (mylen+15)/16);
			fread(bmbuf,bmlen,1,bm);
//			bmbuf <- read at bmaddr for bmlen
			bmaddr += bmlen;
//			relocate(codebuf);
			for(i=0;i<mylen;i+=2)
			{
				int addr = memaddr+i;
				int byteaddr = i/16;
				int bitaddr = (i/2)%8;
				if(bmbuf[byteaddr] & (0x1 <<(bitaddr)))
				{
					int  index, target;
					index = (codebuf[i+1] <<8) + codebuf[i];
					fseek(sym,symaddr+index*2,SEEK_SET);
					fread(&target,1,2,sym);
					codebuf[i+1] = target>>8;
					codebuf[i] = target & 0xff;
				}
			}
//			printf("memaddr=%d\n",memaddr);
			fseek(newfile,memaddr,SEEK_SET);
			fwrite(codebuf,mylen,1,newfile);
			section_size -= mylen;
			memaddr += mylen;
		}

	}
	free(codebuf);
	free(bmbuf);
	fclose(bm);
	fclose(code);
	fclose(sym);
	fclose(newfile);
	return 0;
}