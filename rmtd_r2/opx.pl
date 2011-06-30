#!/usr/bin/perl
#

$file = $ARGV[0];

open fd, "<$file" or die "cannot open file\n";

my @uaddrs = ();
my @caddrs = ();

my $dnsegs = 0;
my $lastcopy = 1;

while (<fd>) {
  chomp;
  if (/Download/) {
    if ($lastcopy) {
      $dnsegs++;
      $lastcopy = 0;
    }
    my @rs = split;
    # rs[3] is the symbol's address
    my $a = hex("$rs[3]");
    #print "$a\n";
    my $find = 0;
    for (my $i=0; $i<@uaddrs; $i++) {
      if ($a == $uaddrs[$i]) {
        $find = 1;
        $caddrs[$i]++;
        last;
      }
    }
    if (!$find) {
      push @uaddrs, $a;
      my $index = @uaddrs -1;
      $caddrs[$index] = 1;
    }
  }
  elsif (/Copy/) {
    $lastcopy = 1;
  }
}

close fd;

my $un = @uaddrs;
print "count = $un\n";

# when count >= 2 we can optimize for it
my $reducedbytes = 0;

# cmd + sym + fix1 + fix2 + ...
# 1 + 2 + 2 + 2
for (my $i=0; $i<@uaddrs; $i++) {
  if ($caddrs[$i] >= 2) {
    # we can reduce it
    # 2 -> 8-7=1
    # 3 -> 12-9=3
    # 4 -> 16-11=5, etc
    my $v = $caddrs[$i]*4 - 2 - 2 - $caddrs[$i]*2;
    $reducedbytes += $v;
#    print "caddr = $caddrs[$i]\n";
  }
}

print "reduced >= $reducedbytes\n";
print "download seg = $dnsegs\n";

open fd, "<$file";
open fd2, ">info.temp";

while (<fd>) {
  chomp;
  if (/Download/) {
    my @rs = split;
    my $a = hex("$rs[3]");
    my $refs = 0;
    for (my $i=0; $i<@uaddrs; $i++) {
      if ($uaddrs[$i] == $a) {
        $refs = $caddrs[$i]; last;
      }
    }
    print fd2 "$_   $refs\n";    
  } 
  else {
    print fd2 "$_\n";
  }
}

close fd;
close fd2;

open fd, "<info.temp";
open fd2, ">info.temp2";


while (<fd>) {

  chomp;
  if (/Download/) {
    my @rs = split;
    my $r = hex("$rs[4]");

    if ($r < 2) {
      print fd2 "$_\n";
    }
  }
  else {
    print fd2 "$_\n";
  }
}

close fd;
close fd2;

my $lastcopy = 1;
my $newsegs = 0;

open fd2, "<info.temp2";
while (<fd2>) {
  chomp;

  if (/Download/) {
    if ($lastcopy) {
      $newsegs++;
      $lastcopy = 0;
    }
  }
  elsif (/Copy/) {
    $lastcopy = 1;
  }
}

close fd2;

print "segs = $newsegs now\n";

my $rsegs = $dnsegs - $newsegs;
my $realbytes = $reducedbytes + 3*$rsegs; # 3 is alpha?

print "reducedbytes: $realbytes\n";
