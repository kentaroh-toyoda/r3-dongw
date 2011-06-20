#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $osname="win32";
  $diff = "..\\diff_r3\\$osname\\diff.exe";
}
elsif ($os =~ /linux/) {
	$osname = "linux";
	$diff = "../diff_r3/$osname/diff.exe";
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

open cc, "<changecases.lst" or die "cannot open changecases.lst\n";
while (<cc>) {
	chomp;
	
  if ($_) {
  	@rs = split;
  	$no = $rs[0];
  	$dir1 = "../benchmarks/$rs[1]";
		$dir2 = "../benchmarks/$rs[2]";
		
		print ">>>processing case\#$no: $dir1 -> $dir2\n";
		
		# diff the two raws
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/main-n.ihex $dir1/build/telosb/main-n.raw > $dir1/build/telosb/hex2raw-n.log");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/main-n.ihex $dir2/build/telosb/main-n.raw > $dir2/build/telosb/hex2raw-n.log");
		
		# old file, new file, delta file
		&excmd("$diff $dir1/build/telosb/main-n.raw $dir2/build/telosb/main-n.raw ../benchmarks/delta-$no.raw > ../benchmarks/native-$no.log");
		$deltasize = -s "../benchmarks/delta-$no.raw";
		print "<<< $rs[1] $rs[2] $deltasize\n";
	}
}
close cc;

exit;

