#include <stdio.h>
#include <stdlib.h>

#define COPY_COST 8 //7
#define COPYX_COST 9
#define COPYY_COST 9
#define COPYXY_COST 11
#define INSERT_COST 0 //3

int file_size_global;
int new_size_global;
unsigned char** Table_C;
unsigned char ** Table_D;
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

void StoreCommonSeg(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile, int osize, int nsize);
void StoreCommonSegNewcode(unsigned char** Table_D, unsigned char * nfile, int nsize);
Twoint SearchSeg(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile, int m, int n);
Twoint SearchSegBackward(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile, int m, int n);
Segment * StoreIntoDB( Segment seg , int source);

int N ;
int * Local_Optimum;
int * S;
char ** Message ;

int beta;
int Transfer_length = 0;

void runMDCD(unsigned char * newfile);
void PrintMessage(int i);
Segment FindJ(int i);

// helper functions
int testeq(unsigned char **Table_C, int i, int j)
{
  unsigned char byte = Table_C[i][j>>3];
  return byte & (0x1<<(j&0x7));
}
void seteq(unsigned char **Table_C, int i, int j)
{
  Table_C[i][j>>3] |= (0x1<<(j&0x7));
}

void setueq(unsigned char **Table, int i, int j)
{
  Table_C[i][j>>3] &= ~(0x1<<(j&0x7));
}

/***************************End of Declaration**************************************************************/
int main(int argc, char *argv[])
{
  /* open  the original file and read it into an array   */
  //get file size
  int originalsize;
  FILE *pFile;
  pFile = fopen (argv[1],"rb");

  if (pFile!=NULL)
  {
    fseek (pFile, 0, SEEK_END);
    originalsize = ftell (pFile);
    rewind (pFile);
  }

  beta = atoi(argv[3]);
  //read file into an array

  unsigned char * originalfile=(unsigned char *)malloc((originalsize + 1)*sizeof(unsigned char));

  int c , i;
  i=0;

  fread(originalfile, 1, originalsize, pFile);
  // need to do so??	
  originalfile[originalsize]='\0';

  /* open  the new file and read it into an array   */
  //get new file size
  FILE * qFile;
  int newsize;

  qFile = fopen (argv[2],"rb");

  if (qFile!=NULL){
    fseek (qFile, 0, SEEK_END);
    newsize=ftell (qFile);
    rewind (qFile);
  }

  // read new file into an array
  unsigned char * newfile=(unsigned char *)malloc((newsize + 1)*sizeof(unsigned char));
  int j = 0;

  fread(newfile, 1, newsize, qFile);
  // need to do so??	
  newfile[newsize]='\0';

// Segment size 

// printf("Segment size is  %d  \n" , sizeof(Segment));
// printf("Char size is  %d  \n" , sizeof(char));
// printf("Int size is  %d  \n" , sizeof(int));

// initialize file_size_global
  file_size_global = newsize ;
  new_size_global = newsize ;
  int maxsize = (originalsize>newsize)?originalsize:newsize;

// printf("maxsize is : %d  \n", maxsize);
//Initialize Table C

  Table_C = malloc((originalsize) * sizeof(unsigned char *));

  if(Table_C == NULL)
  {
    fprintf(stderr, "1 out of memory\n");
    exit(1);
  }
	
  for(i = 0; i < originalsize; i++)
  {
    Table_C[i] = malloc((newsize+7)/8);
    if(Table_C[i] == NULL)
    {
      fprintf(stderr, "2 out of memory\n");
      exit(1);
    }
  }

// StoreCommon Segments
//printf("originalsize = %d\n", originalsize);
//printf("newsize = %d\n", newsize);

  StoreCommonSeg(Table_C, originalfile, newfile, originalsize, newsize);

  // free Table C

  for(i = 0; i < originalsize; i++)
  {
    free(Table_C[i]);
  }
  free(Table_C);


  //Initilize Table D
  Table_D = malloc((newsize) * sizeof(unsigned char *));
  // printf("Table D size is %d \n", newsize);
  if(Table_D == NULL)
  {
    fprintf(stderr, "3 out of memory\n");
    exit(1);
  }
  for(i = 0; i < newsize; i++)
  {
//   printf("Initialize D  i is %d \n", (newsize - i ));
    Table_D[i] = malloc((newsize+7)/8);
    if(Table_D[i] == NULL)
    {
      fprintf(stderr, "4 out of memory\n");
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


  printf("Seg Counter is : %d \n",Seg_counter );

/*
Segment * tmp = (&Seghead) -> next ;


for( i = 0; i < Seg_counter ; i++ ){
     
     
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
  PrintMessage(N);
  //system("PAUSE");	
  return 0;
}

/***********************************End of Main Function**********************************************/
void StoreCommonSeg(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile, int osize,int nsize)
{
  int i , j , m , n ;
  Segment seg;
  Twoint  ti;

  for (i = 0; i < osize; i++) {
    for (j = 0; j < nsize; j++) {
      if ( ofile[i] == nfile[j] ) {
       seteq(Table_C, i, j);
      } else {
        setueq(Table_C, i, j);
        // The differnece
        //if (i==j) printf("%X: %02X %02X\n", i, ofile[i], nfile[j]);
      }
    }
  }
// store the common segment in the forward order from old code

  for (m = osize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= 0; n--) {
      seg.Ending_X = m;
      seg.Ending_Y = n;
      ti = SearchSeg(Table_C, ofile, nfile, m, n);
      seg.Starting_X = ti.x;
      seg.Starting_Y = ti.y; 
      // the length is actally  seg.Ending_Y - seg.Starting_Y+1
      if ((seg.Ending_Y - seg.Starting_Y+1) + INSERT_COST> beta) {
        lastseg -> next = StoreIntoDB(seg , 1);
        lastseg = lastseg -> next;
      }
    }
  }
//  store the common segment in the backward order from old code
/*
  for (m = osize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= 0; n--) {
      seg.Starting_X = m;
      seg.Starting_Y = n;
      ti = SearchSegBackward(Table_C, ofile, nfile, m, n);
      seg.Ending_X = ti.x;
      seg.Ending_Y = ti.y;
      if ((seg.Ending_Y - seg.Starting_Y+1)+INSERT_COST > beta) {
        lastseg -> next = StoreIntoDB(seg , 2); 
        lastseg = lastseg -> next;
      }
    }
  }
*/
}

void StoreCommonSegNewcode(unsigned char** Table_D, unsigned char * nfile, int nsize){
  int i , j , m , n ;
  Segment seg;
  Twoint ti;
  for (i = 0; i < nsize; i++) { 
    for (j = i ; j < nsize ; j++) {
      if ( nfile[i] == nfile[j] && j > i ) {
        //Table_D[i][j] = 'z';
        seteq(Table_D, i, j);
      } else {
        //Table_D[i][j] = 'n';
        setueq(Table_D, i, j);
      }
    }
  }	

// store the common segment in the forward order from new code
  for (m = nsize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= m; n--) {
      seg.Ending_X = m;
      seg.Ending_Y = n;
      ti = SearchSeg(Table_D, nfile, nfile, m, n);
      seg.Starting_X = ti.x;
      seg.Starting_Y = ti.y; 
      //wei: > or >=
      if ((seg.Ending_Y - seg.Starting_Y+1 )+INSERT_COST> beta ) {
        lastseg -> next = StoreIntoDB(seg , 3);
        lastseg = lastseg -> next;
      }
    }
  }

//  store the common segment in the backward order from new code
/*
  for (m = nsize - 1; m >= 0; m--) {
    for (n = nsize - 1; n >= m; n--) {
      seg.Starting_X = m;
      seg.Starting_Y = n;
      ti = SearchSegBackward(Table_D, nfile, nfile, m, n);
      seg.Ending_X = ti.x;
      seg.Ending_Y = ti.y;
      if ((seg.Ending_Y - seg.Starting_Y+1)+INSERT_COST > beta) {
        lastseg -> next = StoreIntoDB(seg , 4);
        lastseg = lastseg -> next;
      }
    }
  }
*/
}

/***********************************End of StoreSeg Function**********************************************/
Twoint SearchSeg(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile,int m, int n){
  Twoint  t ;
  if (m == -1 || n == -1) {
    t.x = m + 1;
    t.y = n + 1;
    return t;
  }
  if (ofile[m] == nfile[n] && testeq(Table_C, m, n)) {
    //Table_C[m][n] = 's';
    setueq(Table_C, m, n);
    t = SearchSeg(Table_C, ofile, nfile, m - 1, n - 1);
  } else {
    t.x = m + 1;
    t.y = n + 1;
  }
  return t;
}

Twoint SearchSegBackward(unsigned char** Table_C, unsigned char * ofile, unsigned char * nfile, int m, int n){
  Twoint t ;
  if (m == -1 || n == new_size_global) {
    t.x = m + 1;
    t.y = n - 1;
    return t;
  }
  if (ofile[m] == nfile[n] && testeq(Table_C, m, n) /*Table_C[m][n] == 's'*/) {
    //Table_C[m][n] = 'n'; //why?
    t = SearchSegBackward(Table_C, ofile, nfile, m - 1, n + 1);
  } else {
    t.x = m + 1;
    t.y = n - 1;
  }
  return t;
}

/***********************************End of SearchSeg Function**********************************************/
Segment * StoreIntoDB(Segment seg, int source){
  Segment * newnode = (Segment *)malloc(sizeof(Segment));
  newnode -> Starting_X = seg.Starting_X ;
  newnode -> Starting_Y = seg.Starting_Y ; 
  newnode -> Ending_X = seg.Ending_X ;
  newnode -> Ending_Y = seg.Ending_Y ;
  newnode -> source = source ;   // 1 from old code forward 2 from old code backward 3 from new code forward 4 from new code backward 
  newnode -> num = Seg_counter;
  Seg_counter ++ ;
  printf("%d old(%d,%d) new(%d,%d)\n", source, seg.Starting_X, seg.Ending_X,
                                               seg.Starting_Y, seg.Ending_Y);
  return newnode;
}

/***********************************End of StoreIntoDB Function**********************************************/
void runMDCD(unsigned char * newfile) {
  int i,k, length;
  char conmsg[500];
  char  convt[32];
  int lastcopy = 1;
     
  for (i = 1; i < N + 1; i++) {
    if (!lastcopy) Local_Optimum[i] = Local_Optimum[i - 1] + 1;
    else Local_Optimum[i] = Local_Optimum[i-1]+1+INSERT_COST;
    lastcopy = 0;
    S[i] = i - 1;
    sprintf(conmsg,"[%d] %s ", Local_Optimum[i], " Download:  ");
    sprintf(convt," %04X [%04X]", newfile[i-1], i-1 + 0x4000-8);
    strcat(conmsg, convt);

    Segment Seg;
    Seg = FindJ(i);
			
    for ( k = (Seg.Starting_Y); k <= i - 1; k++ ) {
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
          sprintf(conmsg,"[%d] %s ", Local_Optimum[i], " Copy from old code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        } else if(Seg.source == 2){
          sprintf(conmsg,"[%d] %s ", Local_Optimum[i], " Copy from old code backward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        }else if(Seg.source == 3){
          sprintf(conmsg,"[%d] %s ", Local_Optimum[i], " Copy from new code forward, StartingX = ");
          sprintf(convt," %d ", l );
          strcat(conmsg, convt);
          strcat(conmsg, ", Starting Y =" );
          sprintf(convt," %d ", k );
          strcat(conmsg, convt);
          strcat(conmsg, ", length = " );
          sprintf(convt," %d ", length );
          strcat(conmsg, convt);
        }else if (Seg.source == 4) {
          sprintf(conmsg,"[%d] %s ", Local_Optimum[i], " Copy from new code forward, StartingX = ");
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
    //    char * tmpstr = (char *)malloc(300 * sizeof(char));
    //    strcpy(tmpstr,conmsg);
    strcpy(Message[i], conmsg);
    //   Message[i] = tmpstr ;
    //   printf("%s  \n", Message[i]);
  }
}
	
/***********************************End of runMDCD Function**********************************************/

Segment FindJ(int i) {
  // This i indicates that
  // in this iteration, we need to construct a total of i bytes with indexes from 0 to i-1
  Segment S;
  S.Starting_Y = i + 1;
  // this is J
  Segment * tmp = (&Seghead) -> next ;

  int k;
  for( k = 0 ; k < Seg_counter ; k++ ){
    //why? start<=i-1<=end
    if(tmp -> Starting_Y < i && tmp -> Ending_Y >= (i-1)){
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
  if (i == 0) {
    // printf("%s \n", Message[0]);
    return;
  } else {
    PrintMessage(S[i]);
    if (strstr(Message[i],"Copy")== NULL) {
      Transfer_length += 1;
    } else {
      Transfer_length += beta;
    }
  printf("%s \n", Message[i]);
  //printf("Total Bytes need so far is:  %d \n" , Transfer_length);
  }
}

/**********************************End of PrintMessage Function**********************************************/


