#include <stdio.h>
#include <stdlib.h>
#include<string.h>


// 1 op, 2 oldOffset, 2 newOffset, 2 length
#define COPY_COST 7
#define COPYX_COST 9
#define COPYY_COST 9
#define COPYXY_COST 11
// 1 op, 2 length
#define INSERT_COST 1

typedef struct sym_t {
  unsigned short offset;  // virtual address that needs to be fixed
  unsigned short address; // use this address
} sym_t;

int file_size_global;
int new_size_global;
sym_t ** Table_C;
sym_t ** Table_D;
int Seg_counter = 0;

typedef struct Segment Segment;

struct Segment {
	int Starting_X;
	int Starting_Y;
	int Ending_X;
	int Ending_Y;
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
void StoreCommonSegNewcode(sym_t** Table_D, sym_t * nfile, int nsize);
Twoint SearchSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value);
Twoint SearchSegBackward(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value);
Segment * StoreIntoDB( Segment seg , int source);

int N ;
int * Local_Optimum;
int * S;

char ** Message ;

int beta;
int Transfer_length = 0;

void runMDCD(sym_t * newfile);
void PrintMessage(int i);
Segment FindJ(int i);

/***************************End of Declaration**************************************************************/
int main(int argc, char *argv[])
{
  int originalsize;
  FILE *pFile;

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

  sym_t * originalfile=(sym_t*)malloc((originalsize + 1)*sizeof(sym_t));

  int c , i;
  i=0;

  fread(originalfile, sizeof(sym_t), originalsize, pFile);
  // need to do so??	
  originalfile[originalsize].offset=originalfile[originalsize].address=0;

  rewind(pFile);
  for (i=0; i<originalsize; i++) {
    sym_t mysym;
    fread(&mysym, sizeof(sym_t), 1, pFile);
    fprintf(txtfile1, "%04X %04X\n", mysym.offset, mysym.address);
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
  sym_t * newfile=(sym_t *)malloc((newsize + 1)*sizeof(sym_t));

  int j = 0;

  fread(newfile, sizeof(sym_t), newsize, qFile);
  // need to do so??	
  newfile[newsize].offset=newfile[newsize].address=0;

  rewind(qFile);
  for (i=0; i<newsize; i++) {
    sym_t mysym;
    fread(&mysym, sizeof(sym_t), 1, qFile);
    fprintf(txtfile2, "%04X %04X\n", mysym.offset, mysym.address);
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
  printf("originalsize = %d\n", originalsize);
  printf("newsize = %d\n", newsize);


  

  StoreCommonSeg(Table_C, originalfile, newfile, originalsize, newsize);

  // free Table C
/*  for(i = 0; i < originalsize; i++)
  {
    free(Table_C[i]);
  }
  free(Table_C); */
/*
  //Initilize Table D
  Table_D = malloc((newsize) * sizeof(sym_t *));
  // printf("Table D size is %d \n", newsize);

  if(Table_D == NULL)
  {
    fprintf(stderr, "out of memory\n");
    exit(1);
  }
	
  for(i = 0; i < newsize; i++)
  {
//   printf("Initialize D  i is %d \n", (newsize - i ));
    Table_D[i] = malloc((newsize) * sizeof(sym_t));
    if(Table_D[i] == NULL)
    {
      fprintf(stderr, "out of memory\n");
      exit(1);
    }
  }

  // StoreCommon Segments in the new code
  StoreCommonSegNewcode(Table_D, newfile, newsize);

  // Free Table D
  for(i = 0; i < newsize; i++)
  {
    free(Table_D[i]);
  }
  free(Table_D);
*/
  printf("Seg Counter is : %d \n",Seg_counter );

  /*
  Segment * tmp = (&Seghead) -> next ;
  for( i = 0; i < Seg_counter ; i++ ) {
    printf("The %d Seg's StartingX is %d , Ending X is %d , StartingY is %d, EndingY is %d  \n", tmp->num, tmp->Starting_X , tmp->Ending_X, tmp->Starting_Y, tmp->Ending_Y);
    tmp = tmp -> next ;
  }
  */

  // run MDCD
  N = newsize;
  Local_Optimum = (int *) malloc( (N+1) * sizeof(int));
  S = (int *) malloc( (N+1) * sizeof(int));

  Message = (char **) malloc((N+1) * sizeof(char *)) ;
  for( i = 0 ; i < N+1 ; i++) {
    Message[i] = (char *) malloc(300 * sizeof(char));
  }
  //char   Message[N+1][300]; 
  //int beta;
  //int Transfer_length;
  Local_Optimum[0] = 0;
  Message[0] = "Here is the beginning of the new code image" ;

  //printf("%s", Message[0]);
  S[0] = 0;
  //printf("\n %d \n", beta);
  runMDCD(newfile);
  //for(i=0;i<N+1;i++)
  //{
	 // printf("i=%d s[i]=%d %s\n",i,S[i],Message[i]);
  //}
  PrintMessage(N);
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
      if ((seg.Ending_Y - seg.Starting_Y+1)*sizeof(sym_t)+INSERT_COST > beta) {
        lastseg -> next = StoreIntoDB(seg , 1);
        lastseg = lastseg -> next;
      }
    }
  }
		
//  store the common segment in the backward order from old code
  for (m = osize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= 0; n--) {
      seg.Starting_X = m;
      seg.Starting_Y = n;
      ti = SearchSegBackward(Table_C, ofile, nfile, m, n, Table_C[m][n]);
      seg.Ending_X = ti.x;
      seg.Ending_Y = ti.y;
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
      
      if ((seg.Ending_Y - seg.Starting_Y+1)*sizeof(sym_t)+INSERT_COST > beta) {
        lastseg -> next = StoreIntoDB(seg , 2); 
        lastseg = lastseg -> next;
      }
    }
  }
}

void StoreCommonSegNewcode(sym_t** Table_D, sym_t * nfile, int nsize){
  int i , j , m , n ;
  Segment seg;
  Twoint ti;

  for (i = 0; i < nsize; i++) { 
    for (j = i ; j < nsize ; j++) {
      /* if ( nfile[i] == nfile[j] && j > i ) {
        Table_D[i][j] = 'z';
      } else {
        Table_D[i][j] = 'n'; // this prevents searching in wrong areas???
      } */
      Table_C[i][j].offset = nfile[j].offset - nfile[i].offset;
      Table_C[i][j].address = nfile[j].address - nfile[i].address;
    }
  }	

// store the common segment in the forward order from new code
  for (m = nsize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= m; n--) {
      seg.Ending_X = m;
      seg.Ending_Y = n;
      ti = SearchSeg(Table_D, nfile, nfile, m, n, Table_D[m][n]);
      seg.Starting_X = ti.x;
      seg.Starting_Y = ti.y; 
      //wei: > or >=
      if ((seg.Ending_Y - seg.Starting_Y )*sizeof(sym_t)> beta ) {
        lastseg -> next = StoreIntoDB(seg , 3);
        lastseg = lastseg -> next;
      }
    }
  }
		
//  store the common segment in the backward order from new code
  for (m = nsize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= m; n--) {
      seg.Starting_X = m;
      seg.Starting_Y = n;
      ti = SearchSegBackward(Table_D, nfile, nfile, m, n, Table_D[m][n]);
      seg.Ending_X = ti.x;
      seg.Ending_Y = ti.y;
      if ((seg.Ending_Y - seg.Starting_Y)*sizeof(sym_t) > beta) {
        lastseg -> next = StoreIntoDB(seg , 4);
        lastseg = lastseg -> next;
      }
    }
  }
}

/***********************************End of StoreSeg Function**********************************************/
Twoint  SearchSeg(sym_t** Table_C, sym_t * ofile, sym_t * nfile, int m, int n, sym_t value) {
  Twoint  t ;
  if (m == -1 || n == -1) {
    t.x = m + 1;
    t.y = n + 1;
    return t;
  }
  if ( (Table_C[m][n].offset == value.offset) && (Table_C[m][n].address == value.address)) {
    t = SearchSeg(Table_C, ofile, nfile, m - 1, n - 1, value);
  } else {
    t.x = m + 1;
    t.y = n + 1;
  }
  return t;
}

Twoint SearchSegBackward(sym_t** Table_C, sym_t * ofile, sym_t* nfile, int m, int n, sym_t value){
  Twoint t ;
  if (m == -1 || n == new_size_global) {
    t.x = m + 1;
    t.y = n - 1;
    return t;
  }
//  if (ofile[m] == nfile[n] && Table_C[m][n] == 's') {
  if ( (Table_C[m][n].offset==value.offset)&&(Table_C[m][n].address==value.address)) {
    //Table_C[m][n] = 'n';
    t = SearchSegBackward(Table_C, ofile, nfile, m - 1, n + 1, value);
  } else {
    t.x = m + 1;
    t.y = n - 1;
  }
  return t;
}

/***********************************End of SearchSeg Function**********************************************/

Segment * StoreIntoDB(Segment seg, int source)
{
  Segment * newnode = (Segment *)malloc(sizeof(Segment));
    
  newnode -> Starting_X = seg.Starting_X ;
  newnode -> Starting_Y = seg.Starting_Y ; 
  newnode -> Ending_X = seg.Ending_X ;
  newnode -> Ending_Y = seg.Ending_Y ;
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
      if (Table_C[l][k].offset == 0 && Table_C[l][k].address == 0) {
        beta = COPY_COST;
        copycmd = ' ';
      }
      else if (Table_C[l][k].offset != 0 && Table_C[l][k].address != 0) {
        beta = COPYXY_COST;
        copycmd = 'z';
      }
      else if (Table_C[l][k].offset != 0 && Table_C[l][k].address == 0) {
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
          sprintf(conmsg,"[%d] [%4d|%4d] %s%c %s ", Local_Optimum[i], Table_C[l][k].offset, Table_C[l][k].address,
                   "Copy", copycmd, "from old code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        } else if(Seg.source == 2) {
          sprintf(conmsg,"[%d] [%4d|%4d] %s%c %s ", Local_Optimum[i], Table_C[l][k].offset, Table_C[l][k].address,
			  "Copy", copycmd, "from old code backward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        } else if(Seg.source == 3) {
          sprintf(conmsg," %s%c %s ", "Copy", copycmd, "from new code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        } else if (Seg.source == 4) {
          sprintf(conmsg," %s%c %s ", "Copy", copycmd, "from new code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        }
      }
    }
    strcpy(Message[i], conmsg);
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
      }
    } 
    tmp = tmp -> next ;
  }
  return S;
}
	
/***********************************End of FindJ Function**********************************************/

void PrintMessage(int i) {
//	printf("[%d]\n",i);
  //if (i == 0) {
  //  // printf("%s \n", Message[0]);
  //  return;
  //} else {
  //  PrintMessage(S[i]);
  //  //if (strstr(Message[i],"Copy")== NULL) {
  //  //  Transfer_length += sizeof(sym_t); // 1
  //  //} else {
  //  //  Transfer_length += beta;
  //  //}
  //  printf("%s \n", Message[i]);
    //printf("Total Bytes need so far is:  %d \n" , Transfer_length);
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
	while(count >=0)
	{
		printf("%s \n",Message[stack[count]]);
		count--;
	}
	free(stack);
  
}

/***********************************End of PrintMessage Function**********************************************/

