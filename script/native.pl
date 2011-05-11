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

$cmd = "cd $base; make telosb; cd ../script";
print "$cmd\n";
$info = `$cmd`;

$cmd = "cd $update; make telosb; cd ../script";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./hex2raw.pl $base/build/telosb/main.ihex $base/build/telosb/main.raw > $base/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;

$cmd = "perl ./hex2raw.pl $update/build/telosb/main.ihex $update/build/telosb/main.raw > $update/hex2raw.log";
print "$cmd\n";
$info = `$cmd`;

$os = $^O;

if ($os =~ /MSWin32/) {
  $cmd = "..\\rmtd\\Debug\\rmtd.exe $base/build/telosb/main.raw $update/build/telosb/main.raw $cpcost > native.log";
  #$cmd = "..\\rmtd_r2\\rmtd.exe $base/build/telosb/main.raw $update/build/telosb/main.raw $cpcost > native.log";
}
elsif ($os =~ /linux/) {
	#$cmd = "../rmtd/rmtd.exe $base/build/telosb/main.raw $update/build/telosb/main.raw $cpcost > native.log";
	$cmd = "../rmtd_r2/rmtd.exe $base/build/telosb/main.raw $update/build/telosb/main.raw $cpcost > native.log";
}

print "$cmd\n";
$info = `$cmd`;
