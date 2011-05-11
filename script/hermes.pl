#!/usr/bin/perl

$cpcost = 8;

$base = $ARGV[0];
$update = $ARGV[1];

if (!$base) {
  $base = "../Blink-base";
}

if (!$update) {
  $update = "../Blink-update";
}

print "Base version is in $base\n";
print "Update version is in $update\n";

## compile: here we use some temp code
$info = `echo "CFLAGS+=-Wl,--section-start=.bss=0x1300" > $base/mfh`;
$info = `cat $base/Makefile >> $base/mfh`;
$cmd = "cd $base; make telosb -f mfh; cd ../script";
print "$cmd\n";
$info = `$cmd`;

$info = `echo "CFLAGS+=-Wl,--section-start=.bss=0x1300" > $update/mfh`;
$info = `cat $update/Makefile >> $update/mfh`;
$cmd = "cd $update; make telosb -f mfh; cd ../script";
print "$cmd\n";
$info = `$cmd`;

# gen info directory and three info files
$cmd = "perl ./geninfo.pl $base";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./geninfo.pl $update";
print "$cmd\n";
$info = `$cmd`;

# add indirection table
# generate func.tab in base for reference in the updated version
# combine jump table with the original hex to out.hex
$info = `rm -rf $base/func.tab`;

$cmd = "perl ./genhex.pl $base";
print "$cmd\n";
$info = `$cmd`;

# copy func.tab from base to update
print "copy func.tab from base to update version\n";
$info = `cp $base/func.tab $update/func.tab`;
# according to base's func.tab, allocate jump slots
# combine jump table with the original hex to out.hex
$cmd = "perl ./genhex.pl $update";
print "$cmd\n";
$info = `$cmd`;

# temp code generate for out1 (i.e. without the jump table)
$cmd = "perl ./hex2raw.pl $base/build/telosb/out1.ihex $base/build/telosb/out1.raw > $base/hex2raw1.log";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./hex2raw.pl $update/build/telosb/out1.ihex $update/build/telosb/out1.raw > $update/hex2raw1.log";
print "$cmd\n";
$info = `$cmd`;

# generate raw files
$cmd = "perl ./hex2raw.pl $base/build/telosb/out.ihex $base/build/telosb/out.raw > $base/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./hex2raw.pl $update/build/telosb/out.ihex $update/build/telosb/out.raw > $update/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;


# CHX IT!!!!!!!!
$cmd = "../rmtd_r2/rmtd.exe $base/build/telosb/out1.raw $update/build/telosb/out1.raw $cpcost > hermes.log";
print "$cmd\n";
$info = `$cmd`;
