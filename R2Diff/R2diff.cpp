#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <malloc.h>
#include <string.h>

#define FPNUM 2800
#define P_DEFAULT 4
#define SYMBOL_NUM 256


unsigned char* oldVersion;
int oldSize;
unsigned char* newVersion;
int newSize;

int p;

typedef struct Segment Segment;
typedef struct Footprint Footprint;
struct Segment {

	int Starting_X;

	int Starting_Y;

	int Ending_X;

	int Ending_Y;
	
	Segment * next;

	int type;

	int fx;
	
	int num; //0 denotes from old code 1 denotes from new code
	
} ;

struct Footprint {

	int offsets[1000];

	int count;


};


Footprint* footPrints;
Footprint* newfootPrints;

Segment Seghead ;

Segment * lastseg = &Seghead;

void findCommonSegment(unsigned char* oldV, unsigned char* newV, int osize, int nsize);
int compareSegment(unsigned char* oldV, unsigned char* newV,int ooffset, int noffset);
void generalFootPrint(unsigned char* ref, int length);
int findK(int index);
Segment* conver(int index);
void generalMessage(int alpha, int beta);
int cFx(int pos, unsigned char* ver,int n);

int main(int argc, char *argv[])
{
	if(argv[3] != NULL)
	{
		p=atoi(argv[3]);
	}
	else
	{
		p = P_DEFAULT;
	}
	FILE* oldFile = fopen (argv[1],"rb");
	if (oldFile!=NULL)
	{
		fseek (oldFile, 0, SEEK_END);
		oldSize = ftell (oldFile);
		rewind (oldFile);
	}
	oldVersion=(unsigned char *)malloc((oldSize+1)*sizeof(unsigned char));
	int c , i;

	i=0;

	do {
		  c = fgetc (oldFile);
		  oldVersion[i]=c;
		  i++;
		} while (c != EOF);
	
	fread(oldVersion, 1, oldSize, oldFile);
	oldVersion[oldSize]='\0';	
	
	FILE* newFile = fopen (argv[2],"rb");
	
	if (newFile!=NULL)
	{
		fseek (newFile, 0, SEEK_END);
		newSize = ftell (newFile);
		rewind (newFile);
	}
	newVersion=(unsigned char *)malloc((newSize+1)*sizeof(unsigned char));

	int j=0;

	fread(newVersion, 1, newSize, newFile);

	newVersion[newSize]='\0';


	fclose(oldFile);
	fclose(newFile);
	generalFootPrint(oldVersion, oldSize);
	findCommonSegment(oldVersion,newVersion,oldSize,newSize);
	generalMessage(0,8);
//	system("PAUSE");
//	free(Seghead);
	free(footPrints);
	
	return 0;
}

void generalFootPrint(unsigned char* ref, int length)
{
//	printf("length=%d\n",length);
	int curPos = 0;
	int i;
	int* curBlock = new int[p];
	long* Fx;
	Fx= new long[length-p];
	footPrints = new Footprint[FPNUM];
	for(i=0;i<FPNUM;i++)
	{
		footPrints[i].count = 0;
	}
	while(curPos + p < length)
	{
		Fx[curPos] = cFx(curPos,ref,p);

		curPos ++;
	}
	for(i=0;i< length-p ;i++)
	{
//		printf("i=%d Fx=%d\n",i,Fx[i] );
		int count =footPrints[Fx[i]].count;
		footPrints[Fx[i]].offsets[count] = i;
		footPrints[Fx[i]].count ++;
	}
	/*
	²âÊÔ´úÂë
	*/
	//for(i=0;i<FPNUM;i++)
	//{
	//	int j;
	//	int length = footPrints[i].count;
	//	for(j=0;j<length;j++)
	//	{
	//		printf("fp=%d pos=%d \n",i,footPrints[i].offsets[j]);
	//	}
	//}
	//int o1 = 1820;
	//int o2 = 1832;
	//int fx1 = cFx(o1,oldVersion,p);
	//int fx2 = cFx(o2,oldVersion,p);

	//for(int i=0;i<p;i++)
	//{
	//	printf("%d : %d\n",oldVersion[o1+i],oldVersion[o2+i]);
	//}
	//printf("%d : %d\n%d : %d\n",o1,o2,fx1,fx2);
} 

void findCommonSegment(unsigned char* oldV, unsigned char* newV, int osize, int nsize)
{
	int i;
	int curPos = 0;
	int* curBlock = new int[p];
	long* nFx = new long[nsize-p];
	Footprint * coFP;
	for(i=0;i<nsize-p;i++)
	{
		nFx[i] = -1;
	}
	while(curPos + p < nsize)
	{
		nFx[curPos] = cFx(curPos,newV,p);
		coFP = &footPrints[nFx[curPos]];
		int j;
		int length =0;
		int refOffset =0;
		for(j=0;j<coFP->count;j++)
		{
			int ooffset = coFP->offsets[j];
			int noffset = curPos;
			int count; 
			count = compareSegment(oldVersion,newVersion,ooffset,noffset);
			if(count > length)
			{
				length = count;
				refOffset = ooffset;
			}
		}
		if(length < 4)
		{
			curPos++;
		}
		else 
		{
			Segment* tmpSeg = new Segment();
			tmpSeg->Starting_X = refOffset;
			tmpSeg->Starting_Y = curPos;
			tmpSeg->num = length;
			tmpSeg->Ending_X = refOffset + length;
			tmpSeg->Ending_Y = curPos + length;
			tmpSeg->type = 1;
			tmpSeg->fx = nFx[curPos];
			lastseg->next = tmpSeg;
			lastseg = tmpSeg;
			curPos += length;
		}
	}
	Segment* curSeg = &Seghead;
	
	newfootPrints = new Footprint[FPNUM];
	for(i=0;i<FPNUM;i++)
	{
		newfootPrints[i].count =0;
	}
	for(i=0;i< nsize-p ;i++)
	{
//		printf("i=%d Fx=%d\n",i,Fx[i] );
		if(nFx[i] != -1)
		{
			int count =newfootPrints[nFx[i]].count;
			newfootPrints[nFx[i]].offsets[count] = i;
			newfootPrints[nFx[i]].count ++;
		}
	}
	for(i=0;i<FPNUM;i++)
	{
		int j;
		Footprint * curfp = &newfootPrints[i];
		for(j=0;j<curfp->count;j++)
		{
			int k;
			for(k=j+1;k<curfp->count;k++)
			{
				int off1 = curfp->offsets[j];
				int off2 = curfp->offsets[k];
				int gap = off2-off1;
				if(gap<0)
				{
					gap = -gap;
				}
				int length = compareSegment(newVersion,newVersion,off1,off2);
				if(length >gap)
				{
					length = gap;
				}
				if(length >=4)
				{
					Segment* tmpSeg = new Segment();
					tmpSeg->Starting_X = off1;
					tmpSeg->Starting_Y = off2;
					tmpSeg->num = length;
					tmpSeg->Ending_X = off1 + length;
					tmpSeg->Ending_Y = off2 + length;
					tmpSeg->type = 0;
					lastseg->next = tmpSeg;
					lastseg = tmpSeg;
				}
			}
		}
	}
	/*
		²âÊÔ´úÂë
	*/
//	printf("common seg\n");
//	curSeg = &Seghead;
	//while(curSeg->next != NULL)
	//{
	//	curSeg = curSeg->next;

	//	printf("%d %d %d %d",curSeg->Starting_X,curSeg->Starting_Y,curSeg->num,curSeg->fx);
	//	//for(int j=0;j<curSeg->num;j++)
	//	//{
	//	//	printf("%d ",oldVersion[curSeg->Starting_X+j]);
	//	//}
	//	//printf("new:");
	//	//for(int j=0;j<curSeg->num;j++)
	//	//{
	//	//	printf("%d ",newVersion[curSeg->Starting_Y+j]);
	//	//}
	//	printf("\n");
	

	//}
}

int compareSegment(unsigned char* oldVer, unsigned char* newVer,int ooffset, int noffset)
{
	int i = ooffset;
	int j = noffset;
	int count = 0;
	while(oldVer[i] != EOF && newVer[j] != EOF && oldVer[i] == newVer[j])
	{
		count ++;
		i++;
		j++;
	}
	return count;
}

Segment* conver(int index)
{
	Segment* curSeg = &Seghead; 
	while(curSeg->next != NULL)
	{
		curSeg = curSeg->next;
		if(curSeg->Ending_Y > index)
		{
			if(curSeg->Starting_Y <= index)
			{
				return curSeg;
			}
			else
			{
				return NULL;
			}
		}
	}
	return NULL;
}

void generalMessage(int alpha, int beta)
{
	int i;
	int* opt = new int[newSize+1];
	int* stat = new int[newSize]; //0 denotes to add, k denotes to copy seg reference start position 
	int* pos = new int[newSize];
	int *opos = new int[newSize];
	opt[0] = 0;
	int k;
//	Segment * pastSeg;
	for(i=0;i<newSize+1;i++)
	{
		opt[i] =0;
		stat[i] = 0;
		pos[i] = 0;
		opos[i] = 0;
	}
	for(i=0;i< newSize; i++)
	{
		int k;
		Segment * converSeg = conver(i);
		if(i ==0 || stat[i-1] !=0)
		{
			if(converSeg != NULL)
			{
				k =converSeg->Starting_Y;
				pos[i] =k;
				opos[i] = converSeg->Starting_X;
				//if(k>i)
				//{
				//	opt[k] = opt[i]+1;
				//}
				if((opt[k]+beta)<(opt[i]+1+alpha))
				{
					opt[i+1] = opt[k]+beta;
					stat[i] = converSeg->Starting_X;
					if(converSeg->type == 0)
					{
						stat[i] = -stat[i];
					}
				}
				else
				{
					opt[i+1] = opt[i]+1+alpha;
					stat[i] =0;
				}

			}
			else
			{
				opt[i+1] = opt[i]+1+alpha;
				stat[i] =0;
			}
		}
		else
		{
			if(converSeg != NULL)
			{
				k = converSeg->Starting_Y;
				pos[i] = k;
				opos[i] = converSeg->Starting_X;
				//if(k >= i)
				//{
				//	opt[k] = opt[i] +1;
				//}
				if(opt[k] + beta < opt[i] +1)
				{
					opt[i+1] =opt[k] + beta ;
					stat[i] = converSeg->Starting_X;
					int n;
					for(n=k;n<i;n++)
					{
						if(stat[n] == 0)
						{
							stat[n] =  converSeg->Starting_X;
							if(converSeg->type == 0)
							{
								stat[i] = -stat[i];
							}
						}
					}
				}
				else
				{
					opt[i+1] = opt[i] +1;
					stat[i] =0;
				}
			}
			else
			{
				opt[i+1] = opt[i] +1;
				stat[i] =0;
			}
		}
//		pastSeg = converSeg;
	}
	//printf("optimum\n");
	//for(i=0;i<newSize;i++)
	//{
	//	printf("%d : %d : %d : %d\n",opt[i+1],stat[i],pos[i],opos[i]);
	//}
	int copyFlag = 0;
	int lastCopyFlag = 0;
	int lastCpStart = 0;
	int pastCopyStart =0;
	int lastAddStart = 0;
	for(i=0;i<newSize;i++)
	{
		if(i ==0)
		{
			if(stat[i] != 0)
			{
				lastCpStart = i;
				copyFlag = 1;
			}
			else
			{
				lastAddStart = i;
				copyFlag = 0;
			}
		}
		else
		{
			if(stat[i] != 0)
			{
				if(stat[i-1] ==0)
				{
					lastCpStart = i;
					copyFlag = 1;
					lastCopyFlag = copyFlag;
				}
				else
				{
					if(stat[i] != stat[i-1])
					{
						pastCopyStart = lastCpStart;
						lastCpStart = i;
						copyFlag ++;
					}
				}
			}
			else
			{
				if(stat[i-1]!=0)
				{
					lastAddStart = i;
					copyFlag = 0;
				}
				else
				{
					copyFlag = 0;
				}
			}
		}
		if(copyFlag >0)
		{
			if(lastCpStart == i)
			{
				if(copyFlag > lastCopyFlag)
				{
					int length = i - pastCopyStart;
					printf("%d",length);
					lastCopyFlag = copyFlag;
				}
				printf("\tcost:%d\ncopy from ",opt[i]);
				if(stat[i] >0)
				{
					printf("old code\toldPos=%d\tnewPos=%d\tlength=",stat[i], i);
				}
				else
				{
					printf("new code\toldPos=%d\tnewPos=%d\tlength=",-stat[i], i);
				}
			}
		}
		else
		{
			if(lastAddStart == i)
			{
				int length = i- lastCpStart;
				printf("%d\tcost:%d\n add %x ",length,opt[i],newVersion[i]);
			}
			else
			{
				printf("%x ",newVersion[i]);
			}
		}
		if(i == newSize -1)
		{
			int length;
			if(copyFlag >0)
			{
				length = i+1 - lastCpStart;
			}
			else
			{
				length = i +1- lastAddStart;
			}
			printf("%d\tcost:%d",length,opt[i]);
		}

	}

//	int fx1 = cFx(1322,oldVersion,p);
//	int fx2 = cFx(1442,newVersion,p);
//	printf("\n%d: %d",fx1,fx2);
}
	int cFx(int pos, unsigned char* ver, int n)
	{
		int i;
		int fx =0;
		for(i=0;i<n;i++)
		{
			fx += ver[pos + i] * SYMBOL_NUM^(n-1-i);
		}
		fx = fx % FPNUM;
		return fx;
	}