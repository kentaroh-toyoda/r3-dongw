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
$info = `gcc -o $dir/bi.exe bi.c`;
## note: build patch.exe has problem in Win7
$info = `gcc -o $dir/loader.exe r3loader.c`;

$info = `gcc -o $dir/si.exe si.c`;
