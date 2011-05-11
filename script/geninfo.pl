#!/usr/bin/perl

$base = $ARGV[0];

if (!$base)
{
  $base = "../Blink-base";
}

print "Base version is $base\n";

$elf = "$base/build/telosb/main.exe";

$info = `readelf -S $elf > elf.info`;

open fd, "<elf.info" or die "cannot open elf.info\n";

while (<fd>) {
  chomp;
  my @rs = split /[\[\]\s]+/;
  if ($rs[1] =~ /\d+/) {
    #print "$rs[2] $rs[1]\n";
    push @sectionnames, $rs[2];
    push @sectionnumbers, $rs[1];
  }
}
close fd;

########################################
# the next phase

for (my $i=0; $i<@sectionnames; $i++) {
  if ($sectionnames[$i] =~ /text/) {
    $textndx = $i;
  } 
  elsif ($sectionnames[$i] =~ /data/) {
    $datandx = $i;
  }
  elsif ($sectionnames[$i] =~ /bss/) {
    $bssndx = $i;
  }
}

$info = `readelf -s -W $elf > elf.info`;
open fd, "<elf.info" or die "cannot open elf.info file\n";

$info = `rm -rf $base/info`;
$info = `mkdir $base/info`;

open text_file, ">$base/info/text.info" or die "cannot open text.info\n";
open data_file, ">$base/info/data.info" or die "cannot open data.info\n";
open bss_file, ">$base/info/bss.info" or die "cannot open bss.info\n";


while (<fd>) {
  chomp;
  my @rs = split;

  if ($rs[3] =~ /SECTION/ || $rs[3] =~ /FILE/) {
    next;
  }
  my $addr = hex("$rs[1]");
  my $loc16 = sprintf "%04X", $addr;

  if ($rs[6] == $textndx) {
    print text_file "$rs[7] $loc16\n";
  }
  elsif ($rs[6] == $datandx) {
    print data_file "$rs[7] $loc16\n";
  }
  elsif ($rs[6] == $bssndx) {
    print bss_file "$rs[7] $loc16\n";
  }  
}

close fd;
$info = `rm -f elf.info`;

close text_file;
close data_file;
close bss_file;
