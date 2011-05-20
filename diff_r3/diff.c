#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define alpha 3
#define beta  7

#define p (beta-alpha)
#define b 256
#define q 257

typedef struct _htentry_t {
	int offset;
	struct _htentry_t *next;	
} htentry_t;

typedef struct _cmd_t {
	int type; // add or copy
	int length;
	int inew; // start offset of the matching segment in new code
	int iold; // start offset of the matching segment in old code
} cmd_t;

///////////////////////////////////////////////////
int hash(unsigned char *string, int offset);
void generatefootprint();
void freefootprint();
void freefootprintentry(htentry_t *e);
int findk(int current, int *rm);
int diff();
void printcmds(int t, int i);
//////////////////////////////////////////////////

htentry_t *hthead[q]; 
htentry_t *httail[q];

FILE *ofile, *nfile, *delta;
int osize, nsize, dsize;
unsigned char *ommap, *nmmap;
unsigned char *dmmap;

int *opt;
int *opt0; // if add
int *opt1; // if copy

cmd_t *cmds;
cmd_t *cmds0;
cmd_t *cmds1;

int *s0;
int *s1;

int *ss0;
int *ss1;

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
	
	opt0 = (int*)malloc((nsize+1)*sizeof(int));
	memset(opt0, 0, (nsize+1)*sizeof(int));
	
	opt1 = (int*)malloc((nsize+1)*sizeof(int));
	memset(opt1, 0, (nsize+1)*sizeof(int));
	
	cmds = (cmd_t*)malloc((nsize+1)*sizeof(cmd_t));
	cmds0 = (cmd_t*)malloc((nsize+1)*sizeof(cmd_t));
	cmds1 = (cmd_t*)malloc((nsize+1)*sizeof(cmd_t));
	
	

	s0 = (int*)malloc((nsize+1)*sizeof(int));
	s0[0] = 0;

	s1 = (int*)malloc((nsize+1)*sizeof(int));
	s1[0] = 0;
	
	ss0 = (int*)malloc((nsize+1)*sizeof(int));
	ss0[0] = 0;
	
	ss1 = (int*)malloc((nsize+1)*sizeof(int));
	ss1[0] = 0;
	
	generatefootprint();
	
	printcmds(diff(), nsize);
	
	if (argc >=4 && argv[3] != NULL) {
	  delta = fopen(argv[3], "wb");
	  fwrite(dmmap, dsize, 1, delta);
	  fclose(delta);
	}
	
	freefootprint();
	free(ommap);
	free(nmmap);
	free(dmmap);
	free(opt); free(opt0); free(opt1);
	free(cmds); free(cmds0); free(cmds1);
	free(s0); free(s1);
	free(ss0); free(ss1); 
	
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
		  for (e=hthead[val]; e; e=e->next) {
			  int ii=i+p-1; // new
			  int jj=e->offset+p-1; // old
			  
			  int l=0; // matching symbol count
			  for ( ; nmmap[ii]==ommap[jj] && ii>=0 && jj>=0; ii--, jj--) l++;
			  // ii+1 is k
			  if (ii+1 < k) {
			  	k=ii+1; 
			  	if (rm) *rm=jj+1;
			  }
		  }
		}
	  }
//	printf("%d:%d\n",current,k);
	return k;
} 

int diff()
{
  // opt[0]=0
  int i;
  int lastcmd=-1; // -1: init, 0: add, 1: opt1 is copy
  
  // when considering opt[i], we know opt[0]..opt[i-1]. 
  // opt[i-1] is the overhead constructing bytes [0,...,i-2]
  // opt[i]   is the overhead constructing bytes [0,...,i-1]
  for (i=1; i<=nsize; i++) {
  	int rm=0;
  	int k = findk(i-1, &rm);
	
	ss0[i] = ss1[i] = i-1;
	
	if (lastcmd == -1) {
	  ss0[i] = ss1[i] = 0; // no last cmd actually
	  opt0[i] = alpha+1;
	  cmds0[i].type = 0; cmds0[i].length = 1; cmds0[i].inew = i-1;
	  if (k>i-1) { // cannot copy
		opt1[i] = opt0[i];
		cmds1[i].type = 0; cmds1[i].length = 1; cmds1[i].inew = i-1;
	    lastcmd=0;
	  } else { // can copy
		opt1[i] = beta;
		cmds1[i].type = 1; cmds1[i].length = i-k; cmds1[i].inew = k; cmds1[i].iold = rm;
		ss1[i]=k;
	    lastcmd=1;
	  }
	}
	else if (lastcmd == 0) {
	  // the last byte can only be added
      s0[i] = s1[i] = 0; 
	  opt0[i] = opt0[i-1]+1;
	  cmds0[i].type = 0; cmds0[i].length = 1; cmds0[i].inew = i-1;
	  if (k>i-1) { // cannot copy
		opt1[i] = opt0[i];
		cmds1[i].type = 0; cmds1[i].length = 1; cmds1[i].inew = i-1;
		lastcmd=0;
	  } else { // can copy
		opt1[i] = opt0[i-1]+beta;
		cmds1[i].type = 1; cmds1[i].length = i-k; cmds1[i].inew = k; cmds1[i].iold = rm;
		ss1[i]=k;
		lastcmd=1;
	  }
	}
	else if (lastcmd == 1) {
	  // add,add vs copy,add
	  int addadd  = opt0[i-1]+1;
	  int copyadd = opt1[i-1]+alpha+1;
	  if (copyadd <= addadd) {
	    opt0[i] = copyadd;
		s0[i] = 1;
	  } else {
	    opt0[i] = addadd;
		s0[i] = 0;
	  }
	  cmds0[i].type = 0; cmds0[i].length = 1; cmds0[i].inew = i-1;
	  
	  if (k>i-1) { // cannot copy: add
		opt1[i] = opt0[i];
		s1[i] = s0[i];
		cmds1[i].type = 0; cmds1[i].length = 1; cmds1[i].inew = i-1;
		lastcmd=0;
	  } else { // can copy: choose last add or last copy?
		int addcopy = opt0[i-1]+beta;
		int copycopy;
		
		if (k==cmds1[i-1].inew) {
		  // The same segment
		  copycopy = opt1[i-1];
		} else {
		  // different segments: same as addcopy, what's the better choice?
		  copycopy = opt1[i-1]+beta;  
		}
  	    if (copycopy <= addcopy) {
		  opt1[i] = copycopy;
		  s1[i] = 1;
		} else {
		  opt1[i] = addcopy;
		  s1[i] = 0;
		}
		cmds1[i].type = 1; cmds1[i].length = i-k; cmds1[i].inew = k; cmds1[i].iold = rm;
		ss1[i]=k;
		lastcmd=1;
	  }
	}
  }
  if (opt0[nsize]<opt1[nsize]) {
	dsize = opt0[nsize];
	dmmap = (unsigned char*)malloc(dsize);
	return 0;
  } else {
	dsize = opt1[nsize];
	dmmap = (unsigned char*)malloc(dsize);
	return 1;
  }
}

int alen=0;
int alendx=0;
int dx=0;

void printcmds(int t, int i)
{
  if (i<=0) 
	return;
  if (t==0) {
	// cmds0
	//printcmds2(s0[i], s[i]);
	printcmds(s0[ss0[i]+1], ss0[i]);
	switch (cmds0[i].type) {
    case 0:
	  printf("ADD[%d] New[%d]: opt[%d]=%d\n", cmds0[i].length, cmds0[i].inew, i, opt0[i]);
	  if (i==1 || s0[ss0[i]+1]==1) { // start or last cmd is copy
		//fwrite(&cmds0[i].type, 1, 1, delta);
		//fwrite(&cmds0[i].length, 2, 1, delta);
		dmmap[dx] = cmds0[i].type;
		memcpy(&dmmap[dx+1], &cmds0[i].length, 2);
		alendx = dx+1; 
		dx += alpha;
	  }
	  dmmap[dx++] = nmmap[cmds0[i].inew];
	  alen++;
	  if (i==nsize) {
		  memcpy(&dmmap[alendx], &alen, 2);
		  alen = 0;
	  }
	  break;
    case 1:	
	  printf("COPY[%d] New[%d,%d] from Old[%d,%d]: opt[%d]=%d\n",
	               cmds0[i].length,
	               cmds0[i].inew, cmds0[i].inew+cmds0[i].length-1,
				   cmds0[i].iold, cmds0[i].iold+cmds0[i].length-1,
				   i, opt0[i]);
      //fwrite(&cmds0[i].type, 1, 1, delta);
	  //fwrite(&cmds0[i].length, 2, 1, delta);
	  //fwrite(&cmds0[i].inew, 2, 1, delta);
	  //fwrite(&cmds0[i].iold, 2, 1, delta);
	  dmmap[dx] = cmds0[i].type;
	  memcpy(&dmmap[dx+1], &cmds0[i].length, 2);
	  memcpy(&dmmap[dx+3], &cmds0[i].inew, 2);
	  memcpy(&dmmap[dx+5], &cmds0[i].iold, 2);
	  dx += beta;
	  if (alendx>0) {
		  memcpy(&dmmap[alendx], &alen, 2);
		  alen = 0;
	  }	
	  break;
    default:
	  break;
    }
  }
  else {
	// cmds1
	//printcmds2(s1[i], s[i]);
	//printcmds2(s1[s[i]+1], s[i]);
	printcmds(s1[ss1[i]+1], ss1[i]);
	switch (cmds1[i].type) {
    case 0:
	  printf("ADD[%d] New[%d]: opt[%d]=%d\n", cmds1[i].length, cmds1[i].inew, i, opt1[i]);
	  if (i==1 || s1[ss1[i]+1]==1) { // start or last cmd is copy
		//fwrite(&cmds0[i].type, 1, 1, delta);
		//fwrite(&cmds0[i].length, 2, 1, delta);
		dmmap[dx] = cmds1[i].type;
		memcpy(&dmmap[dx+1], &cmds1[i].length, 2);
		alendx = dx+1; 
		dx += alpha;
	  }
	  dmmap[dx++] = nmmap[cmds1[i].inew];
	  alen++;
	  if (i==nsize) {
		  memcpy(&dmmap[alendx], &alen, 2);
		  alen = 0;
	  }
	  break;
    case 1:	
	  printf("COPY[%d] New[%d,%d] from Old[%d,%d]: opt[%d]=%d\n",
	               cmds1[i].length,
	               cmds1[i].inew, cmds1[i].inew+cmds1[i].length-1,
				   cmds1[i].iold, cmds1[i].iold+cmds1[i].length-1,
				   i, opt1[i]);
	  dmmap[dx] = cmds1[i].type;
	  memcpy(&dmmap[dx+1], &cmds1[i].length, 2);
	  memcpy(&dmmap[dx+3], &cmds1[i].inew, 2);
	  memcpy(&dmmap[dx+5], &cmds1[i].iold, 2);
	  dx += beta;
	  if (alendx>0) {
		  memcpy(&dmmap[alendx], &alen, 2);
		  alen = 0;
	  }				   
	  break;
    default:
	  break;
    }
  }
}
