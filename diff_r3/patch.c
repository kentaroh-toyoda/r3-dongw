#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *ofile, *dfile, *nfile;
int osize, dsize, nsize;

int main(int argc, char **argv)
{
	unsigned char *dbuffer, *obuffer, *nbuffer;
	int read=0;
	
	ofile = fopen(argv[1], "rb");
	if (ofile == NULL) return -1;
	
	dfile = fopen(argv[2], "rb");
	if (dfile == NULL) return -1;
	
	nfile = fopen(argv[3], "wb");
	if (nfile == NULL) return -1;
	
	fseek(dfile, 0, SEEK_END);
	dsize = ftell(dfile);
	rewind(dfile);
	
	fseek(ofile, 0, SEEK_END);
	osize = ftell(ofile);
	rewind(ofile);
	
	dbuffer = (unsigned char*)malloc(dsize);
	obuffer = (unsigned char*)malloc(osize);
	
	fread(dbuffer, dsize, 1, dfile);
	fread(obuffer, osize, 1, ofile);
	
	while (read<dsize) {
		unsigned char type;
		unsigned short length;
		
		//fread(&type, 1, 1, dfile);
		//fread(&length, 2, 1, dfile);
		type = dbuffer[read];
		length = (dbuffer[read+2]<<8) + dbuffer[read+1];
		
		read += 3;
		
		if (type == 0) { //add
			printf("ADD[%d]\n", length);
			//fread(dbuffer, length, 1, dfile);
			
			//fwrite(dbuffer, length, 1, nfile);
			fwrite(&dbuffer[read], length, 1, nfile);
			read += length;
		} else if (type == 1) { // copy
			unsigned short inew;
			unsigned short iold;
			//fread(&inew, 2, 1, dfile);
			//fread(&iold, 2, 1, dfile);
			inew = (dbuffer[read+1]<<8) + dbuffer[read];
			iold = (dbuffer[read+3]<<8) + dbuffer[read+2];
			
			printf("COPY[%d] New[%d,%d] from Old[%d,%d]\n", length, inew, inew+length-1, iold, iold+length-1);
			read += 4;
			//fseek(ofile, iold, SEEK_SET);
			//fread(dbuffer, length, 1, ofile);
			//fwrite(dbuffer, length, 1, nfile);
			fwrite(&obuffer[iold], length, 1, nfile);
		}
		else {
			printf("error\n");
			return -1;
		}
	}
	
	fclose(nfile);
	fclose(dfile); 
	fclose(ofile);
	
	free(dbuffer);
	free(obuffer);

	return 0;
}


