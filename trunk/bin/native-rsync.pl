#!/usr/bin/perl

$blocksize=32;
$option="";

# the first argument is the blocksize
if ($ARGV[0]) {
	$blocksize = $ARGV[0];
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}


open cc, "<../benchmarks/changecases.lst" or die "cannot open changecases.lst\n";

while (<cc>) {
	chomp;
	
  if ($_) {
  	@rs = split;
  	$no = $rs[0];
  	$dir1 = "../benchmarks/$rs[1]";
		$dir2 = "../benchmarks/$rs[2]";
        $bmk1 = $rs[1]; $bmk2 = $rs[2];
		
		print ">>>processing case\#$no: $dir1 -> $dir2\n";
		
		# diff the two raws
		#&excmd("perl ./hex2raw.pl $dir1/build/telosb/main-n.ihex $dir1/build/telosb/main-n.raw > $dir1/build/telosb/hex2raw-n.log");
		#&excmd("perl ./hex2raw.pl $dir2/build/telosb/main-n.ihex $dir2/build/telosb/main-n.raw > $dir2/build/telosb/hex2raw-n.log");
		
		# old file, new file, delta file
		&excmd("java -jar ../rsync/rsync.jar $option -b $blocksize signature $dir1/build/telosb/main-n.raw $dir1/build/telosb/main-n.sig");
		&excmd("java -jar ../rsync/rsync.jar $option -b $blocksize delta $dir1/build/telosb/main-n.sig $dir2/build/telosb/main-n.raw ../benchmarks/delta-$no.raw >../benchmarks/rsync-$no.log");
				
		#$deltasize = -s "../benchmarks/delta-$no.raw";
		
		$info = `perl ./rsynccost.pl ../benchmarks/rsync-$no.log`;
		#print "<<< INFO: $info\n";
		@rs = split / /, $info;
		$deltasize = $rs[1];
		
		print "<<< $no   $deltasize\n";
		
	}
}
close cc;

exit;

