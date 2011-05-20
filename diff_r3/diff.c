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
void diff();
void printcmds(int i);
int diff2();
void printcmds2(int t, int i);
//////////////////////////////////////////////////

htentry_t *hthead[q]; 
htentry_t *httail[q];

FILE *ofile, *nfile;
int osize, nsize;
unsigned char *ommap, *nmmap;
int *opt;
int *opt0; // if add
int *opt1; // if copy

cmd_t *cmds;
cmd_t *cmds0;
cmd_t *cmds1;
int *s;
int *s0;
int *s1;

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
	
	s = (int*)malloc((nsize+1)*sizeof(int));
	s[0] = 0;

	s0 = (int*)malloc((nsize+1)*sizeof(int));
	s0[0] = 0;

	s1 = (int*)malloc((nsize+1)*sizeof(int));
	s1[0] = 0;
	
	
	generatefootprint();
	
	//diff(); printcmds(nsize);
	printcmds2(diff2(), nsize);
	
	freefootprint();
	free(ommap);
	free(nmmap);
	free(opt); free(opt0); free(opt1);
	free(cmds); free(cmds0); free(cmds1);
	free(s); free(s0); free(s1);
	
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

void diff()
{
  // opt[0]=0
  int i;
  int lastcopy=1; // -1: init, 0: add, 1: copy
  
  // when considering opt[i], we know opt[0]..opt[i-1]. 
  // opt[i-1] is the overhead constructing bytes [0,...,i-2]
  // opt[i]   is the overhead constructing bytes [0,...,i-1]
  for (i=1; i<=nsize; i++) {
  	int rm=0;
  	int k = findk(i-1, &rm);
	//tmp
	
	if (k>i-1) { // no common segments, add
  		opt[i] = opt[i-1]+1;
  		if (lastcopy) opt[i] += alpha;
  		lastcopy=0;
  		printf("add byte %d, opt[%d]=%d\n", i-1, i, opt[i]);
		cmds[i].type = 0;
		cmds[i].length = 1;
		cmds[i].inew = i-1;
		s[i] = i-1;
  	} else { // common segments found, copy or add
  		int copyoverhead=opt[k]+beta; // [0..k-1]'s overhead is opt[k] and [k..i-1] is copied
  		int addoverhead=opt[i-1]+1;
  		if (lastcopy) addoverhead += alpha;
  		
  		if (copyoverhead<addoverhead) { // or <=, use copy
		  opt[i] = copyoverhead;
  		  lastcopy=1;	
  		  printf("copy bytes New[%d,%d] from Old[%d..], opt[%d]=%d\n", k, i-1, rm, i, opt[i]);
		  cmds[i].type = 1;
		  cmds[i].length = i-k;
		  cmds[i].inew = k;
		  cmds[i].iold = rm;
		  s[i] = k; // k is the first index of CS
  		}
  		else { // use add
  			opt[i] = addoverhead;
  			lastcopy=0;
  			printf("add byte %d, opt[%d]=%d\n", i-1, i, opt[i]);
			cmds[i].type = 0;
		    cmds[i].length = 1;
		    cmds[i].inew = i-1;
			s[i] = i-1;
  		}
  	}
  }	
}

int diff2()
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
	s[i] = i-1;
	if (i==1387) {
		s[i] = i-1;
	}
	
	if (lastcmd == -1) {
	  s0[i] = s1[i] = 0; // no last cmd actually
	  opt0[i] = alpha+1;
	  cmds0[i].type = 0; cmds0[i].length = 1; cmds0[i].inew = i-1;
	  if (k>i-1) { // cannot copy
		opt1[i] = opt0[i];
		cmds1[i].type = 0; cmds1[i].length = 1; cmds1[i].inew = i-1;
	    lastcmd=0;
	  } else { // can copy
		opt1[i] = beta;
		cmds1[i].type = 1; cmds1[i].length = i-k; cmds1[i].inew = k; cmds1[i].iold = rm;
		s[i]=k;
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
		s[i]=k;
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
		s[i]=k;
		lastcmd=1;
	  }
	}
  }
  if (opt0[nsize]<opt1[nsize]) {
	return 0;
  } else {
	return 1;
  }
}

void printcmds(int i)
{
  if (i<=0) {
	return;
  }
  printcmds(s[i]);
  // print cmds[i]
  switch (cmds[i].type) {
    case 0:
	  printf("ADD[%d] New[%d]: opt[%d]=%d\n", cmds[i].length, cmds[i].inew, i, opt[i]);
	  break;
    case 1:	
	  printf("COPY[%d] New[%d,%d] from Old[%d,%d]: opt[%d]=%d\n",
	               cmds[i].length,
	               cmds[i].inew, cmds[i].inew+cmds[i].length-1,
				   cmds[i].iold, cmds[i].iold+cmds[i].length-1,
				   i, opt[i]);
	  break;
    default:
	  break;
  }
}

void printcmds2(int t, int i)
{
  if (i<=0) return;
  if (t==0) {
	// cmds0
	printcmds2(s0[i], s[i]);
	switch (cmds0[i].type) {
    case 0:
	  printf("ADD[%d] New[%d]: opt[%d]=%d, (%d)\n", cmds0[i].length, cmds0[i].inew, i, opt0[i], s0[i]);
	  break;
    case 1:	
	  printf("COPY[%d] New[%d,%d] from Old[%d,%d]: opt[%d]=%d, (%d)\n",
	               cmds0[i].length,
	               cmds0[i].inew, cmds0[i].inew+cmds0[i].length-1,
				   cmds0[i].iold, cmds0[i].iold+cmds0[i].length-1,
				   i, opt0[i], s0[i]);
	  break;
    default:
	  break;
    }
  }
  else {
	// cmds1
	printcmds2(s1[i], s[i]);
	switch (cmds1[i].type) {
    case 0:
	  printf("ADD[%d] New[%d]: opt[%d]=%d, (%d)\n", cmds1[i].length, cmds1[i].inew, i, opt1[i], s1[i]);
	  break;
    case 1:	
	  printf("COPY[%d] New[%d,%d] from Old[%d,%d]: opt[%d]=%d, (%d)\n",
	               cmds1[i].length,
	               cmds1[i].inew, cmds1[i].inew+cmds1[i].length-1,
				   cmds1[i].iold, cmds1[i].iold+cmds1[i].length-1,
				   i, opt1[i], s1[i]);
	  break;
    default:
	  break;
    }
  }
}


