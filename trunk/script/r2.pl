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

# RC: generate out.exe with reference inflated with 0s
# and also generate a relocation table in rela.raw file

$cmd = "../bi/bi.exe $base";
print "$cmd\n";
$info = `$cmd`;

$cmd = "../bi/bi.exe $update";
print "$cmd\n";
$info = `$cmd`;

# generate out.ihex from out.exe first

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

$cmd = "../rmtd_r2/rmtd.exe $base/build/telosb/out.raw $update/build/telosb/out.raw $cpcost > r2.log";
print "$cmd\n";
$info = `$cmd`;
