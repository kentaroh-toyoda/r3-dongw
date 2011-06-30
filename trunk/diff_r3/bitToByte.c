#include <stdio.h>
#include <stdlib.h>

FILE *bitFile, *byteFile;
int main(int argc,char** argv)
{
	int addrByte;
	int bitOfByte;
	int  sec1_start, sec1_end, sec2_start;
	int bitSize, byteSize;
	unsigned char *bitMap, *byteMap;
	int byteAddr;
	int i;
	unsigned char curByte;

	bitFile = fopen(argv[1],"rb");
	if (bitFile == NULL) return -1;
	byteFile = fopen(argv[2],"wb");
	if (byteFile == NULL) return -1;

	fseek(bitFile,0,SEEK_END);
	bitSize = ftell(bitFile);
	rewind(bitFile);
	sec1_start = 8;
	sec2_start = bitSize - 10;
	sec1_end = bitSize - 18;

	bitSize -= 24;
	bitMap = (unsigned char*)malloc((bitSize+1)*sizeof(unsigned char));
	byteSize = bitSize * 8;
	byteMap = (unsigned char*)malloc((byteSize+1)*sizeof(unsigned char));
	i= sec1_start;
	fseek(bitFile,sec1_start,SEEK_SET);
	fread(bitMap,1,sec1_end-sec1_start,bitFile);
	fseek(bitFile,sec2_start,SEEK_SET);
	fread(bitMap+sec1_end-sec1_start,1,2,bitFile);

	byteAddr =0;
	for(addrByte =0;addrByte<bitSize; addrByte++)
	{
		curByte = bitMap[addrByte];
		for(bitOfByte =0;bitOfByte<8; bitOfByte++)
		{
			if((curByte >> bitOfByte) & 0x1)
			{
				byteMap[byteAddr] = 0xFF;
			}
			else
			{
				byteMap[byteAddr] = 0x0;
			}
			byteAddr ++;
		}
	}
	printf("bit size: %d byte size: %d\n",bitSize,byteAddr);
	fwrite(byteMap,1,byteAddr,byteFile);
	fclose(bitFile);
	fclose(byteFile);
//	system("PAUSE");

}