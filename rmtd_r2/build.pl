#!/usr/bin/perl

$dir=".";
$os = $^O;
if ($os =~ /MSWin32/) {
  $dir="./win32";
}
elsif ($os =~ /linux/) {
	$dir="./linux";
}
$info = `rm -rf $dir`; # clean
$info = `mkdir $dir`;  # mkdir
$info = `gcc -o $dir/rmtd.exe rmtd.c`;
## note: build patch.exe has problem in Win7
$info = `gcc -o $dir/xrmtd.exe xrmtd.c`;
$info = `gcc -o $dir/xrmtd_dw.exe xrmtd_dw.c`;

$info = `gcc -o $dir/rmtd_dmt.exe rmtd_dmt.c`;

