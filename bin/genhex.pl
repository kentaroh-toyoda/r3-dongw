#!/usr/bin/perl

$dir = $ARGV[0];
$rfn = $ARGV[1];

if (!$dir) {
  $dir = "../Blink-base";
}

$asm = "$dir/build/telosb/main-n.asm";
$tempinfo = `msp430-objdump -zhD $dir/build/telosb/main-n.exe > $asm`;

$inhex = "$dir/build/telosb/main-n.ihex";
$outhex = "$dir/build/telosb/out-h.ihex";

$o1hex = "$dir/build/telosb/out-h1.ihex";
$o2hex = "$dir/build/telosb/out-h2.ihex";

$start = 0;

@functions = ();
@labels = ();
# functions' jump slot address
@fjmpaddr = ();

@fixaddr = ();
@fixfunc = ();

# find func name according the allocated address
sub find() {
  my ($l) = @_;
  for (my $i=0; $i<@labels; $i++) {
    if (hex("$l") == hex("$labels[$i]")) {
      return $functions[$i]; # return the function name
    }
  }
  return "unresolved";
}

# find the index according the func name
sub findndx() {
  my ($func) = @_;

  for (my $i=0; $i<@functions; $i++) {
    if ($func eq $functions[$i]) {
      return $i;
    }
  }
  return -1; # cannot find it
}

open fd, "<$asm" or die "cannot open asm file\n";

while (<fd>) {
  chomp;
  if (/_reset_vector__/) { $start=1; }
  if ($start) {
    if (/^[abcdef\d]{8} <.+>:/) {
      my @rs = split /[:<>\s]+/, $_;
      #print "$rs[0] $rs[1]\n";
      if ($rs[1] =~ /^\./) {} # its the section name
      else {
        push @functions, $rs[1]; # its the function name
        push @labels, $rs[0];    # the function's allocated address
      }
    }
    if (/call/) {
      #print "$_\n";
      # the function's address?
      my @rs = split /[:;\s]+/, $_;
      #for ($i=0; $i<@rs; $i++) { print "$i $rs[$i];"; }
      #print "\n";
      # index 8 is the label in hex
      my $l = $rs[-1]; # #0x????
      
      #print "l=$l\n";
      
    }
  }
}

close fd;

$slots = @labels;
print "There are $slots functions\n";

$addr = 0xffe0;
@infunc = ();
@inaddr = ();
@inuse=(); # still in use??

# if there exists a tab file?

if ($rfn) {
  open intab, "<$rfn" or die "cannot open reference func tab: $rfn\n";
  while (<intab>) {
    chomp;
    my @rs = split;
    push @infunc, $rs[0];
    push @inaddr, $rs[1];
    if (hex("$rs[1]")<$addr) {
      $addr = hex("$rs[1]");
    }
  }
  close intab;	
}
else {
	print "need to create func.txt\n";
}

#####
for (my $j=0; $j<@infunc; $j++) {
	# is infunc[j] in functions??
	my $in=0;
	for (my $i=0; $i<@labels; $i++) {
		if ($infunc[$j] eq $functions[$i]) {
			$in=1;
		}
	}
	$inuse[$j]=$in;
}
## the new func.tab
open outtab, ">$dir/build/telosb/func.txt" or die "cannot open $dir/build/telosb/func.txt\n";
# addr is currently the minimum address
for (my $i=0; $i<@labels; $i++) {
  # is the function in the old file?
  my $yes = 0;
  my $la = 0;
  my $lb = 0;
  for (my $j=0; $j<@infunc; $j++) {
    if ($infunc[$j] eq $functions[$i]) {
      $yes = 1;
      $la = $inaddr[$j];
    }
  }
  if ($yes) {
    $lb = hex("$la");
    print "find $functions[$i]\n";
  } else {
  	## is there any free space??
  	my $usefree=0;
  	for (my $j=0; $j<@inuse; $j++) {
  		if (!$inuse[$j]) {
  			# we occupy this
  			$lb = hex("$inaddr[$j]");
  			$usefree=1;
  			print "cannot find $functions[$i], use free\n";
  			$inuse[$j]=1; ## be used now
  			last;
  		}
  	}
  	
  	if (!$usefree) {
      $addr = $addr - 6; ## 简单的利用上面的空间，而不是复用可能被删除而空余的空间
      $lb = $addr;
      print "cannot find $functions[$i], use new\n";
    }
  }
  my $loc16 = sprintf "%04X", $lb;
  print outtab "$functions[$i] $loc16\n";
  $fjmpaddr[$i] = $lb;
}

close outtab;

# functions[i]'s is indirected via fjmpaddr[i]

open fd2, "<$asm";
while (<fd2>) {
  chomp;
  if (/call/) {
  	# DW: Is this correct?
      my @rs = split /[:;\s]+/, $_;  
      # index 8 is the label in hex
      my $l = $rs[-1];
      my @l2 = split /x/, $l;
      my $f = &find($l2[1]);
      my $loc = hex("$rs[1]")+2;
      my $loc16 = sprintf "%04x", $loc;
      print "$_ => call $f [fix word at memory address $loc16, l=$l]\n";
      push @fixaddr, $loc; # at which address makes the call
      push @fixfunc, $f;
  }
}

close fd2;

# modify the ihex file correspondingly

open hx, "<$inhex" or die "cannot open $inhex file\n";
open hx2, ">$o1hex" or die "cannot open $o1hex file\n";

my $lineno = 0;

while (<hx>) {
  $lineno++;
  # locate the position that needs relocation
  chomp;
  my @chars = split //;
  $reclen = hex("$chars[1]$chars[2]");
  $offset = hex("$chars[3]$chars[4]$chars[5]$chars[6]");
  $rectyp = hex("$chars[7]$chars[8]");

  my $fmod = 0;
  # 9-> offset, 10->offset+1
  # 4000 -> 400f
  # is there is any bytes that need fixed?
  for (my $j=0; $j<@fixaddr; $j++) {
    if ($offset<=$fixaddr[$j] && $fixaddr[$j]<=$offset+0x0f) {
      if ($fixaddr[$j]+1>$offset+0xff) {
        print "ERROR\n";
        exit;
      }
      # fixit to fixfunc's allocated address
      my $loc16 = sprintf "%04X", $fixaddr[$j];
      print "fix loc: $loc16\n";

      $fmod = 1; # CRC needs recomputation
      my $ndx = &findndx($fixfunc[$j]);
      if ($ndx == -1) { print "ERROR\n"; exit; }
      # the address is in fjmpaddr
      my $c = 9 + ($fixaddr[$j] - $offset)*2;
      my $loc1 = $fjmpaddr[$ndx];
      my $loc16 = sprintf "%04X", $loc1;
      my @bts = split //, $loc16;
      $chars[$c] = $bts[2];
      $chars[$c+1] = $bts[3];
      $chars[$c+2] = $bts[0];
      $chars[$c+3] = $bts[1];
      
      print "modify to $bts[0]$bts[1]$bts[2]$bts[3]\n";     
    }
  }
#  if (!$fmod) {
#    print hx2 "$_\n";
#  } 
#  else 
  {
    if ($fmod) { print "The $lineno line is modified\n"; }

    my $sum = $reclen+hex("$chars[3]$chars[4]")+hex("$chars[5]$chars[6]")+$rectyp;

    print hx2 ":";
    for (my $i=1; $i<=8; $i++) {
      print hx2 "$chars[$i]";
    }
    for (my $j=0; $j<$reclen; $j++) {
      my $ix1 = 9+2*$j;
      my $ix2 = 9+2*$j+1;
      print hx2 "$chars[$ix1]$chars[$ix2]";
      $sum += hex("$chars[$ix1]$chars[$ix2]");
      
    }
    # write crc
    $sum = (256-$sum) % 256;
    my $crc = sprintf "%02X", $sum;
    print hx2 "$crc\n";
  }
}
close hx;

# lastly we need to write the jump table
close hx2;

open jp, ">$o2hex" or die "cannot open $o2hex\n";

# note: some functions are not called, we can further remove those.
for (my $i=0; $i<@functions; $i++) {
  my $impl = hex("$labels[$i]");
  # $addr: B0 12 $impl; 30 41
  print jp ":06";
  my $o = $addr+$i*6;
  my $o16 = sprintf "%04X", $o;
  
  print "Write jump table at $o16: $functions[$i]=$labels[$i]\n";
  
  print jp "$o16";
  print jp "00";
  print jp "B012";
  # the address
  my $a16 = sprintf "%04X", $impl;
  my @as = split //, $a16;
    
  print jp "$as[2]$as[3]$as[0]$as[1]";
  print jp "3041";
  # print CRC
  my @os = split //, $o16;
  my $sum = 6+hex("$os[2]$os[3]")+hex("$os[0]$os[1]")+0;
  $sum += 0xb0+0x12+hex("$as[2]$as[3]")+hex("$as[0]$as[1]");
  $sum += 0x30+0x41;

  $sum = (256-$sum) % 256;
  my $crc = sprintf "%02X", $sum;
  print jp "$crc\n";
}

close jp;

# rm out1 out2 and combine to out

$info = `wc -l $o1hex`;
@lino = split / /, $info;

$line = $lino[0]-2;

$info = `head -n $line $o1hex > $outhex`;
$info = `cat $o2hex >> $outhex`;
$info = `tail -n 2 $o1hex >> $outhex`;


print "genhex finished!\n";

#$info = `rm $o1hex`;
#$info = `rm $o2hex`;
