#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

#open bm, "<../benchmarks/benchmarks.lst" or die "cannot open benchmarks.lst\n";
open cc, "<../benchmarks/changecases.lst" or die "cannot open changecases.lst\n";
open out, ">../gnuplot/gzip.log" or die "cannot open gzip.log\n";

print out "\# results for Stream and gzip\n";
print out "\#\n";
print out "\# No old new Stream gzip compression_ratio\n";

while (<cc>) {
	chomp;
  if ($_) {
  	my @rs = split;
  	my $no = $rs[0];
  	my $bmk1 = $rs[1];
  	my $bmk2 = $rs[2];
  	
		$dir = "../benchmarks/$bmk2";
		print ">>>processing at $dir\n";
		
		&excmd("perl ./hex2raw.pl $dir/build/telosb/main-n.ihex $dir/build/telosb/main-n.raw > $dir/hex2raw-n.log");
		$rawsize = -s "$dir/build/telosb/main-n.raw";
		
		&excmd("gzip -f -9 $dir/build/telosb/main-n.raw"); # gen main-n.raw.gz
		$gzsize = -s "$dir/build/telosb/main-n.raw.gz";
		
		print "<<< $bmk2 $rawsize $gzsize\n";
		my $ratio = ($rawsize-$gzsize) / $rawsize;
		print out "$no $bmk1 $bmk2 $rawsize $gzsize $ratio\n";
	}
}

#close bm;
close cc;
close out;

exit;
