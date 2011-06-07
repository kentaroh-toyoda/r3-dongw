#!/usr/bin/perl

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
$info = `echo "CFLAGS += -Wl,-q" > $base/mfr`;
$info = `cat $base/Makefile >> $base/mfr`;
$cmd = "cd $base; make telosb -f mfr; cd ../script";
print "$cmd\n";
$info = `$cmd`;

$info = `echo "CFLAGS += -Wl,-q" > $update/mfr`;
$info = `cat $update/Makefile >> $update/mfr`;
$cmd = "cd $update; make telosb -f mfr; cd ../script";
print "$cmd\n";
$info = `$cmd`;

## bi requires main.raw
$cmd = "perl hex2raw.pl $base/build/telosb/main.ihex $base/build/telosb/main.raw";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl hex2raw.pl $update/build/telosb/main.ihex $update/build/telosb/main.raw";
print "$cmd\n";
$info = `$cmd`;

# RC: generate out.exe with reference inflated with 0s
# and also generate a relocation table in rela.raw file

$cmd = "../bi/bi.exe 2 $base >$base/build/telosb/bi.txt";
print "$cmd\n";
$info = `$cmd`;

$cmd = "../bi/bi.exe 2 $update >$update/build/telosb/bi.txt";
print "$cmd\n";
$info = `$cmd`;

## generate sym.txt
$cmd = "perl gensym.pl $base/build/telosb/bi.txt >$base/build/telosb/sym.txt";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl gensym.pl $update/build/telosb/bi.txt $base/build/telosb/sym.txt >$update/build/telosb/sym.txt";
print "$cmd\n";
$info = `$cmd`;

## re-execute bi.exe, 前一次地址填充为0, 这一次(因为有sym.txt存在)
## 填充为正确的jump table index
$cmd = "../bi/bi.exe 2 $base >$base/build/telosb/bi2.txt";
print "$cmd\n";
$info = `$cmd`;

$cmd = "../bi/bi.exe 2 $update >$update/build/telosb/bi2.txt";
print "$cmd\n";
$info = `$cmd`;

# generate out.ihex from out.exe first
# 另外还有sym.raw为jump table, bm.raw为bitmaps, 这些也是额外的overhead

## $(OBJCOPY) --output-target=ihex $(MAIN_EXE) $(MAIN_IHEX)
$info = `msp430-objcopy --output-target=ihex $base/build/telosb/out.exe $base/build/telosb/out.ihex`;
$info = `msp430-objcopy --output-target=ihex $update/build/telosb/out.exe $update/build/telosb/out.ihex`;


# hex to raw and compare the binary file -- still need to compare rela file
$cmd = "perl ./hex2raw.pl $base/build/telosb/out.ihex $base/build/telosb/out.raw > $base/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./hex2raw.pl $update/build/telosb/out.ihex $update/build/telosb/out.raw > $update/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;

#$cmd = "../rmtd_r2/rmtd.exe $base/build/telosb/out.raw $update/build/telosb/out.raw 8 > r3.log";
$cmd = "../diff_r3/diff.exe $base/build/telosb/out.raw $update/build/telosb/out.raw delta.raw > r3.log";
print "$cmd\n";
$info = `$cmd`;

