#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *ofile, *dfile, *nfile;
int osize, dsize, nsize;

int main(int argc, char **argv)
{
	unsigned char *dbuffer;
	int read=0;
	
	ofile = fopen(argv[1], "rb");
	if (ofile == NULL) {
		printf("old file err\n");	
		return -1;
	}
	dfile = fopen(argv[2], "rb");
	if (dfile == NULL){
		printf("diff file err\n");	
		return -1;
	}
	
	nfile = fopen(argv[3], "wb");
	if (nfile == NULL){
		printf("new file err\n");			
		return -1;
	}
	fseek(dfile, 0, SEEK_END);
	dsize = ftell(dfile);
	rewind(dfile);
	fseek(ofile, 0, SEEK_END);
	osize = ftell(ofile);
	rewind(ofile);
	
	dbuffer = (unsigned char*)malloc(osize);
	
	while (read<dsize) {
		unsigned char type;
		unsigned short length;
		
		fread(&type, 1, 1, dfile);
		fread(&length, 2, 1, dfile);
		read += 3;
//		printf("type=%d length=%d\n",type,length);
		if (type == 0) { //add
			printf("ADD[%d]\n", length);
			fread(dbuffer, length, 1, dfile);
			read += length;
			fwrite(dbuffer, length, 1, nfile);
		} else { // copy
			unsigned short inew;
			unsigned short iold;
		//	fread(&inew, 2, 1, dfile);
			fread(&iold, 2, 1, dfile);
			printf("COPY[%d]  from Old[%d,%d]\n", length, iold, iold+length-1);
			read += 2;
			fseek(ofile, iold, SEEK_SET);
			fread(dbuffer, length, 1, ofile);
			fwrite(dbuffer, length, 1, nfile);
		}
	}
	
	
	fclose(ofile); 
	fclose(dfile); 
	fclose(nfile); 
	free(dbuffer);
	
	return 0;
}


