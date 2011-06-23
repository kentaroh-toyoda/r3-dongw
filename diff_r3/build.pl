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
$info = `gcc -o $dir/diff.exe diff.c`;
## note: build patch.exe has problem in Win7
$info = `gcc -o $dir/cons.exe patch.c`;
