#include <stdio.h>
#include <stdlib.h>
#include<string.h>
// 1 op, 2 oldOffset, 2 newOffset, 2 length
#define COPY_COST 5
#define COPYX_COST 7
#define COPYY_COST 7
#define COPYXY_COST 9
// 1 op, 2 length
#define INSERT_COST 0

#define  ADD_COST 3
typedef struct sym_t {
  unsigned short offset;  // virtual address that needs to be fixed
  unsigned short address; // use this address
} sym_t;

typedef struct cmd_t {
	unsigned int type;
	int length;
	int iold;
	int inew;
	int x_off;
	int y_off;
} cmd_t;

int file_size_global;
int new_size_global;
sym_t ** Table_C;
sym_t ** Table_D;
int Seg_counter = 0;
sym_t *originalfile, *newfile;
typedef struct Segment Segment;
FILE * deltaFile= NULL;
struct Segment {
	int Starting_X;
	int Starting_Y;
	int Ending_X;
	int Ending_Y;
	
	int offset;
	int address;
	
	int source;
	Segment * next;
	int num;
} ;

Segment Seghead ;
Segment * lastseg = &Seghead;

typedef struct Twoint {
        int x;
        int y;
} Twoint ;

void StoreCommonSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int osize, int nsize);
Twoint SearchSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value);
Twoint SearchSegBackward(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value);
Segment * StoreIntoDB( Segment seg , int source);
void sort(sym_t* arr,int start, int end);
int partition(sym_t* arr, int start, int end);
void exchange(sym_t* a, sym_t* b);

int N ;
int * Local_Optimum;
int * S;

char ** Message ;
cmd_t* cmd;

int beta;
int Transfer_length = 0;
int copyLength =0;
void runMDCD(sym_t * newfile);
void PrintMessage(int i);
Segment FindJ(int i);

/***************************End of Declaration**************************************************************/
int main(int argc, char *argv[])
{
  int originalsize;
  FILE *pFile;
  
	if(argc >=5 && argv[4] != NULL)
	{
		deltaFile = fopen(argv[4],"wb");
	}
  // size of sym_t is 4 bytes
  pFile = fopen (argv[1],"rb");

  FILE *txtfile1 = fopen("rela1.txt","w+");
  FILE *txtfile2 = fopen("rela2.txt","w+");
    
  if (pFile!=NULL)
  {
    fseek (pFile, 0, SEEK_END);
    originalsize = ftell (pFile); 
    
    originalsize /= sizeof(sym_t); // in terms of # of symbols
    rewind (pFile);
  }

  beta = atoi(argv[3]);

  originalfile=(sym_t*)malloc((originalsize + 1)*sizeof(sym_t));

  int c , i;
  i=0;

  fread(originalfile, sizeof(sym_t), originalsize, pFile);
  // need to do so??	
  originalfile[originalsize].offset=originalfile[originalsize].address=0;

  rewind(pFile);
  sort(originalfile,0,originalsize-1);
  for (i=0; i<originalsize; i++) {
    //sym_t mysym;
    //fread(&mysym, sizeof(sym_t), 1, pFile);

    fprintf(txtfile1, "%04X %04X\n", originalfile[i].offset, originalfile[i].address);
  }
  fclose(txtfile1);
  /* open  the new file and read it into an array   */
  
  FILE * qFile;
  int newsize;

  qFile = fopen (argv[2],"rb");

  if (qFile!=NULL){
    fseek (qFile, 0, SEEK_END);
    newsize=ftell (qFile); newsize /= sizeof(sym_t);
    rewind (qFile);
  }

  // read new file into an array
  newfile=(sym_t *)malloc((newsize + 1)*sizeof(sym_t));

  int j = 0;

  fread(newfile, sizeof(sym_t), newsize, qFile);
  // need to do so??	
  newfile[newsize].offset=newfile[newsize].address=0;

  rewind(qFile);
  sort(newfile,0,newsize-1);
  for (i=0; i<newsize; i++) {
    fprintf(txtfile2, "%04X %04X\n", newfile[i].offset, newfile[i].address);
  }
  fclose(txtfile2);

  // Segment size 

  // printf("Segment size is  %d  \n" , sizeof(Segment));
  // printf("Char size is  %d  \n" , sizeof(char));
  // printf("Int size is  %d  \n" , sizeof(int));

  // initialize file_size_global
  file_size_global = newsize ; // in terms of # of symbols
  new_size_global = newsize ;  // in terms of # of symbols

  int maxsize = (originalsize>newsize)?originalsize:newsize; // in terms of # of symbols

  // printf("maxsize is : %d  \n", maxsize);
  
  //Initialize Table C
  Table_C = (sym_t**)malloc((originalsize) * sizeof(sym_t *));

  if(Table_C == NULL)
  {
    fprintf(stderr, "out of memory\n");
    exit(1);
  }
	
  for(i = 0; i < originalsize; i++)
  {
    Table_C[i] = (sym_t*)malloc(newsize * sizeof(sym_t));
    if(Table_C[i] == NULL)
    {
      fprintf(stderr, "out of memory\n");
      exit(1);
    }
  }

  // StoreCommon Segments
  printf("originalsize %d\n", originalsize*sizeof(sym_t));
  printf("newsize %d\n", newsize*sizeof(sym_t));


  StoreCommonSeg(Table_C, originalfile, newfile, originalsize, newsize);

  
  printf("SegCounter %d \n",Seg_counter );

  //
  //Segment * tmp = (&Seghead) -> next ;
  //for( i = 0; i < Seg_counter ; i++ ) {
	 // printf("The %d Seg's length=%d StartingX is %d , Ending X is %d , StartingY is %d, EndingY is %d (%d,%d) \n", tmp->num,tmp->Ending_Y-tmp->Starting_Y, tmp->Starting_X , tmp->Ending_X, tmp->Starting_Y, tmp->Ending_Y,
  //      tmp->offset, tmp->address);
  //  tmp = tmp -> next ;
  //}
  

  // run MDCD
  N = newsize;
  Local_Optimum = (int *) malloc( (N+1) * sizeof(int));
  S = (int *) malloc( (N+1) * sizeof(int));

  Message = (char **) malloc((N+1) * sizeof(char *)) ;
  cmd = (cmd_t*)malloc((N+1)*sizeof(cmd_t));
  for( i = 0 ; i < N+1 ; i++) {
    Message[i] = (char *) malloc(300 * sizeof(char));
  }
  //char   Message[N+1][300]; 
  //int beta;
  //int Transfer_length;
  Local_Optimum[0] = 0;
  Message[0] = "Here is the beginning of the new code image" ;
  cmd[0].type = -1;
  cmd[0].length =-1;
  cmd[0].inew=-1;
  cmd[0].iold = -1;
  //printf("%s", Message[0]);
  S[0] = 0;
  //printf("\n %d \n", beta);
  runMDCD(newfile);
  //for(i=1;i<N+1;i++)
  //{
	 // printf("%s\n",Message[i]);
  //}
  //PrintMessage1(N);
  PrintMessage(N);
  printf("delta %d\n",Transfer_length);
  printf("copyLength %d\n",copyLength);
  // system("PAUSE");
  
  for(i = 0; i < originalsize; i++)
    free(Table_C[i]);
  free(Table_C);

  return 0;
}

/***********************************End of Main Function**********************************************/
void StoreCommonSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int osize, int nsize) {
  int i , j , m , n;
  Segment seg;
  Twoint  ti;
  int off, addr;

  for (i = 0; i < osize; i++) {
    for (j = 0; j < nsize; j++) {
      //if ( ofile[i] == nfile[j] ) {
      //  Table_C[i][j] = 'z';
      //} else {
      //  Table_C[i][j] = 'n';
        // The differnece
      //  if (i==j) printf("%X: %02X %02X\n", i, ofile[i], nfile[j]);
      //}
      Table_C[i][j].offset = nfile[j].offset-ofile[i].offset;
      Table_C[i][j].address = nfile[j].address-ofile[i].address;
    }
  }
		
// store the common segment in the forward order from old code
  for (m = osize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= 0; n--) {
		
      seg.Ending_X = m;
      seg.Ending_Y = n;
      
      seg.offset = Table_C[m][n].offset;
      seg.address = Table_C[m][n].address;
      ti = SearchSeg(Table_C, ofile, nfile, m, n, Table_C[m][n]);
      seg.Starting_X = ti.x;
      seg.Starting_Y = ti.y; 
      
      // set value of beta
      if (Table_C[m][n].offset == 0 && Table_C[m][n].address == 0) {
        beta = COPY_COST;
      }
      else if (Table_C[m][n].offset != 0 && Table_C[m][n].address != 0) {
        beta = COPYXY_COST;
      }
      else {
        beta = COPYX_COST; // COPYY_COST is the same
      }
      
      // the length is actally  seg.Ending_Y - seg.Starting_Y+1
      if ((seg.Ending_Y - seg.Starting_Y+1)*sizeof(sym_t) > beta) {
        lastseg -> next = StoreIntoDB(seg , 1);
        lastseg = lastseg -> next;
      }
    }
	
  }
  ////  store the common segment in the backward order from old code
  //for (m = osize - 1; m >= 0; m--) {
  //  for (n = nsize - 1; n >= 0; n--) {
  //    seg.Starting_X = m;
  //    seg.Starting_Y = n;
  //    ti = SearchSegBackward(Table_C, ofile, nfile, m, n, Table_C[m][n]);
  //    seg.Ending_X = ti.x;
  //    seg.Ending_Y = ti.y;
  //    // set value of beta
  //    if (Table_C[m][n].offset == 0 && Table_C[m][n].address == 0) {
  //      beta = COPY_COST;
  //    }
  //    else if (Table_C[m][n].offset != 0 && Table_C[m][n].address != 0) {
  //      beta = COPYXY_COST;
  //    }
  //    else {
  //      beta = COPYX_COST; // COPYY_COST is the same
  //    }
  //    
  //    if ((seg.Ending_Y - seg.Starting_Y+1)*sizeof(sym_t)+INSERT_COST > beta) {
  //      lastseg -> next = StoreIntoDB(seg , 2); 
  //      lastseg = lastseg -> next;
  //    }
  //  }
  //}
}

/***********************************End of StoreSeg Function**********************************************/
Twoint  SearchSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value) {
  Twoint  t;
  if (m == -1 || n == -1) {
    t.x = m + 1;
    t.y = n + 1;
    return t;
  }
  if ( (Table_C[m][n].offset == value.offset) && (Table_C[m][n].address == value.address)
	 && (Table_C[m][n].offset != 0xffff) && (Table_C[m][n].address != 0xffff)
	  ) {
    //DW::
    //Table_C[m][n] = 's';
    t = SearchSeg(Table_C, ofile, nfile, m - 1, n - 1, value);
    Table_C[m][n].offset  = 0xffff;
    Table_C[m][n].address = 0xffff;
    
  } else {
    t.x = m + 1;
    t.y = n + 1;
  }
  return t;
}
//Twoint SearchSegBackward(sym_t** Table_C, sym_t * ofile, sym_t* nfile, int m, int n, sym_t value){
//  Twoint t ;
//  if (m == -1 || n == new_size_global) {
//    t.x = m + 1;
//    t.y = n - 1;
//    return t;
//  }
////  if (ofile[m] == nfile[n] && Table_C[m][n] == 's') {
//  if ( (Table_C[m][n].offset==value.offset)&&(Table_C[m][n].address==value.address)) {
//    //Table_C[m][n] = 'n';
//    t = SearchSegBackward(Table_C, ofile, nfile, m - 1, n + 1, value);
//  } else {
//    t.x = m + 1;
//    t.y = n - 1;
//  }
//  return t;
//}
/***********************************End of SearchSeg Function**********************************************/

Segment * StoreIntoDB(Segment seg, int source)
{
  Segment * newnode = (Segment *)malloc(sizeof(Segment));
    
  newnode -> Starting_X = seg.Starting_X ;
  newnode -> Starting_Y = seg.Starting_Y ; 
  newnode -> Ending_X = seg.Ending_X ;
  newnode -> Ending_Y = seg.Ending_Y ;
  newnode -> offset = seg.offset;
  newnode -> address = seg.address;
  newnode -> source = source ;   // 1 from old code forward 2 from old code backward 3 from new code forward 4 from new code backward 
  newnode -> num = Seg_counter;
  Seg_counter ++ ;
    
  return newnode;
}

/***********************************End of StoreIntoDB Function**********************************************/
// need to modify this function!!!
void runMDCD(sym_t* newfile) {
  int i,k, length;
  char conmsg[500];
  char  convt[32];
  int lastcopy = 1;
  cmd_t* tmpcmd;
  // N=newsize   
  for (i = 1; i < N + 1; i++) {
    // printf("MDCD %dth round \n", i);
    if (!lastcopy) { // must an insert
      Local_Optimum[i] = Local_Optimum[i - 1] + sizeof(sym_t);
    }
    else { // i.e. lastcopy = 1
      Local_Optimum[i] = Local_Optimum[i-1] + sizeof(sym_t) + INSERT_COST;
    }
    // defaults to a download command
    lastcopy = 0;
    S[i] = i - 1;
    sprintf(conmsg,"[%d] %s ", Local_Optimum[i], "Download:  ");
    sprintf(convt," %04X %04X ", newfile[i-1].offset, newfile[i-1].address );
    strcat(conmsg, convt);
	tmpcmd = (cmd_t*)malloc(sizeof(cmd_t));
	tmpcmd->type = 0;
	tmpcmd->inew = i-1;
	tmpcmd->iold = -1;
	tmpcmd->length = sizeof(sym_t);
    // printf("%s \n", conmsg);
    Segment Seg;
    Seg = FindJ(i);
    // printf("Seg Starting Y %d", Seg.Starting_Y);
    for ( k = (Seg.Starting_Y); k <= i - 1; k++ ) {
      int l = 0;
      if (Seg.source == 1 || Seg.source == 3) {
        l = (k - Seg.Starting_Y + Seg.Starting_X);
      } else if (Seg.source == 2 || Seg.source == 4) {
        l = (Seg.Starting_X - (k - Seg.Starting_Y)  );
      }
      // set beta
      char copycmd = ' ';
      
      //if (Table_C[l][k].offset == 0 && Table_C[l][k].address == 0) {
      if (Seg.offset == 0 && Seg.address == 0) {
        beta = COPY_COST;
        copycmd = ' ';
      }
      //else if (Table_C[l][k].offset != 0 && Table_C[l][k].address != 0) {
      else if (Seg.offset != 0 && Seg.address != 0) {
        beta = COPYXY_COST;
        copycmd = 'z';
      }
      //else if (Table_C[l][k].offset != 0 && Table_C[l][k].address == 0) {
      else if (Seg.offset != 0 && Seg.address == 0) {
        beta = COPYX_COST; 
        copycmd = 'x';
      }
      else {
        beta = COPYY_COST; // COPYY_COST is the same
        copycmd = 'y';
      }

      if (Local_Optimum[i] >= Local_Optimum[k] + beta) {
        lastcopy = 1;
        Local_Optimum[i] = Local_Optimum[k] + beta;
        S[i] = k;
        int l = 0;
        if (Seg.source == 1 || Seg.source == 3) {
          l = (k - Seg.Starting_Y + Seg.Starting_X);
        } else if (Seg.source == 2 || Seg.source == 4) {
          l = (Seg.Starting_X - (k - Seg.Starting_Y)  );
        }
        length = i - k;
        if (Seg.source == 1) {
          sprintf(conmsg," [%d] [%4d|%4d] %s%c %s ", Local_Optimum[i], Seg.offset, Seg.address,
                   "Copy", copycmd, "from old code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
			tmpcmd->length =  length;
			tmpcmd->inew =  k;
			tmpcmd->iold = l;
		  if(copycmd == ' ')
		  {
			  tmpcmd->type = 1;
		  }
		  else if(copycmd == 'x')
		  {
			  tmpcmd->type =2;
			  tmpcmd->x_off = Seg.offset;
			  tmpcmd->y_off = 0;
		  }
		  else if(copycmd == 'y')
		  {
			  tmpcmd->type = 3;
			  tmpcmd->x_off = 0;
			  tmpcmd->y_off = Seg.address;
		  }
		  else if(copycmd == 'z')
		  {
			  tmpcmd->type =4;
			  tmpcmd->x_off = Seg.offset;
			  tmpcmd->y_off = Seg.address;
		  }

        } 
      }
    }
    strcpy(Message[i], conmsg);
	cmd[i] = *tmpcmd;
  }
}

/***********************************End of runMDCD Function**********************************************/
Segment FindJ(int i) 
{
  // This i indicates that
  // in this iteration, we need to construct a total of i bytes with indexes from 0 to i-1
  Segment S;
  S.Starting_Y = i + 1;
  // this is J
  Segment * tmp = (&Seghead) -> next ;
  int k;
  for( k = 0 ; k < Seg_counter ; k++ ){
    //why? start<=i-1<=end
    if(tmp -> Starting_Y < i && tmp -> Ending_Y >= (i-1)) {
      if(S.Starting_Y > tmp-> Starting_Y){// find a smaller j
        S.Starting_Y = tmp-> Starting_Y;
        S.Starting_X = tmp-> Starting_X;
        S.Ending_X = tmp-> Ending_X;
        S.Ending_Y = tmp-> Ending_Y;
        S.source = tmp-> source ; 
		S.offset = tmp->offset;
		S.address = tmp->address;
		S.num = tmp->num;
      }
    } 
    tmp = tmp -> next ;
  }
  return S;
}
	
/***********************************End of FindJ Function**********************************************/
int lastcmd = 1;
//void PrintMessage1(int i)
//{
//	  if (i == 0) {
//    // printf("%s \n", Message[0]);
//    return;
//  } else {
//    PrintMessage(S[i]);
//    if (strstr(Message[i],"Copy")== NULL) {
//      Transfer_length += sizeof(sym_t); // 1
//    } else {
//      Transfer_length += beta;
//    }
//    printf("%s \n", Message[i]);
//	  }
//}
void PrintMessage(int i) {
  //if (i == 0) {
  //  // printf("%s \n", Message[0]);
  //  return;
  //} else {
  //  PrintMessage(S[i]);
  //  if (strstr(Message[i],"Copy")== NULL) {
  //    Transfer_length += sizeof(sym_t); // 1
  //  } else {
  //    Transfer_length += beta;
  //  }
  //  printf("%s \n", Message[i]);  	
	int* stack = (int*) malloc(i*sizeof(int));
	int count =0;
	int j=i;
	while(j>0)
	{
		stack[count] = j;
		j=S[j];
		count++;
	}
	count--;
	int cmdTail = count;
	//int* CE = (int*)malloc(count * sizeof(int));
	//int ceCount =0;
	//AE_t* AE2 = (AE_t*)malloc(count * sizeof(AE_t));
	//int aeCount = 0;
	int lastInew = -1;
	int lastAdd = -1;
	int lastAdd2 = -1;
	int AE2Length= 0;
	while(count >=0)
	{
		if(cmd[stack[count]].type ==0)
		{
			unsigned short last_addr = -1;
			if(lastInew >= 0)
			{
				last_addr = newfile[lastInew].address;
			}
			unsigned short cur_addr = newfile[cmd[stack[count]].inew].address;
			if(lastcmd)
			{
				lastInew = cmd[stack[count]].inew;
				//lastAdd2 = lastAdd;
				lastAdd = stack[count];
				AE2Length =1;
				Transfer_length += ADD_COST;
				Transfer_length += sizeof(sym_t);
			}
			else if(last_addr == cur_addr)
			{
				if(lastAdd2 >=0 && cmd[lastAdd2].type == 0)
				{
					lastInew = cmd[lastAdd].inew;
					AE2Length =1;
					Transfer_length += ADD_COST;
					lastAdd2 = lastAdd;
				}
				cmd[lastAdd].type =5;
				cmd[stack[count]].type =5;
				Transfer_length += 2;
				AE2Length ++;
				cmd[lastAdd].length = AE2Length;
			}
			else
			{
				if(cmd[lastAdd].type == 5)
				{
					lastInew = cmd[stack[count]].inew;
					lastAdd2 = lastAdd;
					lastAdd = stack[count];
					AE2Length =1;
					Transfer_length += ADD_COST;
					Transfer_length += sizeof(sym_t);
				}
				else
				{
					Transfer_length += sizeof(sym_t);
					lastAdd2 = lastAdd;
					lastAdd = stack[count];
					lastInew = cmd[stack[count]].inew;
				}
			}
			lastcmd = 0;
		}
		else if(cmd[stack[count]].type == 1)
		{
			Transfer_length += COPY_COST;
			lastcmd =1;
			lastAdd2=-1;
		}
		else if(cmd[stack[count]].type == 2)
		{
			Transfer_length += COPYX_COST;
			lastcmd =1;
			lastAdd2=-1;
		}
		else if(cmd[stack[count]].type == 3)
		{
			Transfer_length += COPYY_COST;
			lastcmd =1;
			lastAdd2=-1;
		}
		else if(cmd[stack[count]].type == 4)
		{
			Transfer_length += COPYXY_COST;
			lastcmd =1;
			lastAdd2=-1;
		}

		printf("%s %d, %d\n",Message[stack[count]],Transfer_length, AE2Length);
		count--;
	}
	unsigned char* dmmap = (unsigned char *)malloc(Transfer_length * sizeof(unsigned char));

	lastcmd = 1;
	int alen =0;
	int alendx = 0;
	int dx =0;
	while(cmdTail >=0)
	{
		int idx = stack[cmdTail];
		if(cmd[idx].type ==0)
		{
			if(lastcmd)
			{
				dmmap[dx] = cmd[idx].type;
				memcpy(&dmmap[dx+1],&cmd[idx].length,2);
				alendx = dx+1;
				dx += ADD_COST;
			}
			memcpy(&dmmap[dx],&newfile[cmd[idx].inew].offset,2);
			memcpy(&dmmap[dx+2],&newfile[cmd[idx].inew].address,2);
			dx += sizeof(sym_t);
			if(dx == new_size_global)
			{
				memcpy(&dmmap[alendx],&alen,2);
			}
			lastcmd = 0;
		}
		else if(cmd[idx].type == 1)
		{
			dmmap[dx] = cmd[idx].type;
			memcpy(&dmmap[dx+1],&cmd[idx].length,2);
			copyLength += cmd[idx].length;
			memcpy(&dmmap[dx+3],&cmd[idx].iold,2);
			dx += COPY_COST;
			if (alendx>0) {
				memcpy(&dmmap[alendx], &alen, 2);
				alen = 0;
				alendx=0;
			}	
			lastcmd =1;
		}
		else if(cmd[idx].type == 2)
		{
			dmmap[dx] = cmd[idx].type;
			
			memcpy(&dmmap[dx+1],&cmd[idx].length,2);
			copyLength += cmd[idx].length;
			memcpy(&dmmap[dx+3],&cmd[idx].iold,2);
			memcpy(&dmmap[dx+5],&cmd[idx].x_off,2);
			dx += COPYX_COST;
			if (alendx>0) {
				memcpy(&dmmap[alendx], &alen, 2);
				alen = 0;
				alendx=0;
			}	
			lastcmd =1;
		}
		else if(cmd[idx].type == 3)
		{			
			dmmap[dx] = cmd[idx].type;
			
			memcpy(&dmmap[dx+1],&cmd[idx].length,2);
			copyLength += cmd[idx].length;
			memcpy(&dmmap[dx+3],&cmd[idx].iold,2);
			memcpy(&dmmap[dx+5],&cmd[idx].y_off,2);
			dx += COPYY_COST;
			if (alendx>0) {
				memcpy(&dmmap[alendx], &alen, 2);
				alen = 0;
				alendx=0;
			}	
			lastcmd =1;
		}
		else if(cmd[idx].type == 4)
		{
			dmmap[dx] = cmd[idx].type;
			
			memcpy(&dmmap[dx+1],&cmd[idx].length,2);
			copyLength += cmd[idx].length;
			memcpy(&dmmap[dx+3],&cmd[idx].iold,2);
			memcpy(&dmmap[dx+5],&cmd[idx].x_off,2);
			memcpy(&dmmap[dx+7],&cmd[idx].y_off,2);
			dx += COPYXY_COST;
			if (alendx>0) {
				memcpy(&dmmap[alendx], &alen, 2);
				alen = 0;
				alendx=0;
			}
			lastcmd =1;
		}
		else if(cmd[idx].type == 5)
		{
			int i;
			dmmap[dx] = cmd[idx].type;
			memcpy(&dmmap[dx+1],&cmd[idx].length,2);
			memcpy(&dmmap[dx+3],&newfile[cmd[idx].inew].address,2);
			dx += 5;

			for(i=0;i<cmd[idx].length;i++)
			{
				int curidx = stack[cmdTail-i];
				memcpy(&dmmap[dx+2*i],&newfile[cmd[curidx].inew].offset,2);
			}
			dx += cmd[idx].length *2;
			cmdTail -= cmd[idx].length;
			cmdTail ++;
			if (alendx>0) {
				memcpy(&dmmap[alendx], &alen, 2);
				alen = 0;
				alendx=0;
			}
			lastcmd=1;

		}
		//printf("%s %d\n",Message[stack[cmdTail]],dx);
		cmdTail --; 
	}
	if(deltaFile != NULL)
	{
		fwrite(dmmap,Transfer_length,1,deltaFile);
		fclose(deltaFile);
	}
	free(dmmap);
	free(stack);
    //printf("Total Bytes need so far is:  %d \n" , Transfer_length);
  
}

/***********************************End of PrintMessage Function**********************************************/

void sort(sym_t* arr,int start, int end)
{
	if(start>= end)
		return;
	int q = end+1;
	if(start < end) q = partition(arr,start,end);
	sort(arr,start,q-1);
	sort(arr,q,end);
}

int partition(sym_t* arr, int start, int end)
{
	sym_t* tmp;
	tmp = &arr[end];
	int i = start-1;
	int j;
	for(j=start;j<end;j++)
	{
		if(arr[j].address<= tmp->address)
		{
			i++;
			exchange(&arr[i],&arr[j]);
		}
	}
	exchange(&arr[i+1],&arr[end]);
	return i+1;
}

void exchange(sym_t* a, sym_t* b)
{
	sym_t tmp;
	tmp.address = a->address;
	tmp.offset = a->offset;
	a->address = b->address;
	a->offset = b->offset;
	b->address = tmp.address;
	b->offset = tmp.offset;
}