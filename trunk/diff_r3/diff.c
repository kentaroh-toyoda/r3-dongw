#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define alpha 0
#define beta  8

#define p (beta-alpha)
#define b 256
#define q 257

typedef struct _htentry_t {
	int offset;
	struct _htentry_t *next;	
} htentry_t;

///////////////////////////////////////////////////
int hash(unsigned char *string, int offset);
void generatefootprint();
void freefootprint();
void freefootprintentry(htentry_t *e);
int findk(int current, int *rm);
void diff();
//////////////////////////////////////////////////


htentry_t *hthead[q]; 
htentry_t *httail[q];

FILE *ofile, *nfile;
int osize, nsize;
unsigned char *ommap, *nmmap;
int *opt;

int main(int argc, char **argv)
{
	ofile = fopen(argv[1], "rb");
	if (ofile == NULL) return -1;
	
	fseek(ofile, 0, SEEK_END);
	osize = ftell(ofile);
	rewind(ofile);
	
	nfile = fopen(argv[2], "rb");
	if (nfile == NULL) return -1;
	
	fseek(nfile, 0, SEEK_END);
	nsize = ftell(nfile);
	rewind(nfile);
	
	ommap = (unsigned char*)malloc(osize+1);
	fread(ommap, 1, osize, ofile);
	ommap[osize]=0;
	
	nmmap = (unsigned char*)malloc(nsize+1);
	fread(nmmap, 1, nsize, nfile);
	nmmap[nsize]=0;
	
	fclose(ofile);
	fclose(nfile);
	
	opt = (int*)malloc((nsize+1)*sizeof(int));
	memset(opt, 0, (nsize+1)*sizeof(int));
	
	generatefootprint();
	diff();
	
	freefootprint();
	free(ommap);
	free(nmmap);
	free(opt);
	return 0;
}

int hash(unsigned char *string, int offset)
{
	int i;
	int val=0;
	
	for (i=0; i<p; i++) {
		val = (val*256) % q;
		val += string[offset+i];
	}
	return val % q;
}

void generatefootprint()
{
	int i;
	for (i=0; i<=osize-p; i++) {
		int val = hash(ommap, i);
		htentry_t *newentry = (htentry_t*)malloc(sizeof(htentry_t));
		newentry->offset = i;
		newentry->next = NULL;
		
		if (hthead[val] == NULL) {
			hthead[val] = httail[val] = newentry;
		} else {
			httail[val]->next = newentry;
			httail[val] = newentry;
		}
	}
}

void freefootprint()
{
	int i;
	for (i=0; i<q; i++) {
		freefootprintentry(hthead[i]);
	}
}

void freefootprintentry(htentry_t *e) {
	if (e->next== NULL) {
		free(e);
		return;
	}
	freefootprintentry(e->next);
}

// rm is the offset in the old code
int findk(int current, int *rm)
{
	int i;
	int k=current+1;
	for (i=current-p+1; i<=current && i<=nsize-p; i++) {
		int val = hash(nmmap, i);
		if (hthead[val]) { // there are entries, false match??
		  htentry_t *e;
		  for (e=hthead[val]->next; e; e=e->next) {
			  int ii=i+p-1; // new
			  int jj=e->offset+p-1; // old
			  
			  int l=0; // matching symbol count
			  for ( ; nmmap[ii]==ommap[jj]; ii--, jj--) l++;
			  // ii+1 is k
			  if (ii+1 < k) {
			  	k=ii+1; 
			  	if (rm) *rm=jj+1;
			  }
		  }
		}
	}
	return k;
} 

void diff()
{
  // opt[0]=0
  int i;
  int lastcopy=1; // so the overhead of add can be accounted in
  // when considering opt[i], we know opt[0]..opt[i-1]. 
  // opt[i-1] is the overhead constructing bytes [0,...,i-2]
  // opt[i]   is the overhead constructing bytes [0,...,i-1]
  for (i=1; i<=nsize; i++) {
  	int rm=0;
  	int k = findk(i-1, &rm);
  	if (k>i-1) { // no common segments, add
  		opt[i] = opt[i-1]+1;
  		if (lastcopy) opt[i] += alpha;
  		lastcopy=0;
  		printf("add byte %d, opt[%d]=%d\n", i-1, i, opt[i]);
  	} else { // common segments found, copy or add
  		int copyoverhead=opt[k]+beta; // [0..k-1]'s overhead is opt[k] and [k..i-1] is copied
  		int addoverhead=opt[i-1]+1;
  		if (lastcopy) addoverhead += alpha;
  		
  		if (copyoverhead<addoverhead) { // or <=, use copy
		  opt[i] = copyoverhead;
  		  lastcopy=1;	
  		  printf("copy bytes New[%d,%d] from Old[%d..], opt[%d]=%d\n", k, i-1, rm, i, opt[i]);
  		}
  		else { // use add
  			opt[i] = addoverhead;
  			lastcopy=0;
  			printf("add byte %d, opt[%d]=%d\n", i-1, i, opt[i]);
  		}
  	}
  }	
}