#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

open bm, "<benchmarks.lst" or die "cannot open benchmarks.lst\n";
while (<bm>) {
	chomp;
  if ($_) {
		$dir = "../benchmarks/$_";
		print ">>>processing at $dir\n";
		
		# 1. make clean
		&excmd("perl ./hex2raw.pl $dir/build/telosb/main-n.ihex $dir/build/telosb/main-n.raw > $dir/hex2raw-n.log");
		$rawsize = -s "$dir/build/telosb/main-n.raw";
		
		&excmd("gzip -f -1 $dir/build/telosb/main-n.raw"); # gen main-n.raw.gz
		$gzsize = -s "$dir/build/telosb/main-n.raw.gz";
		
		print "<<< $_ $rawsize $gzsize\n";
	}
}
close bm;

exit;
