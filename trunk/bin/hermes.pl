#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
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
		
		# 1. Hermes do not require bi.exe, it uses main-n.exe,
		# now out.raw combines code (with function indirections) and jump table
		&excmd("perl ./genhex.pl $dir1 >../benchmarks/genhex-$no-old.log");
		&excmd("perl ./genhex.pl $dir2 $dir1/build/telosb/func.txt >../benchmarks/genhex-$no-new.log");
		
		# 2. convert to out.raw and diff
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/out-h.ihex $dir1/build/telosb/out-h.raw > $dir1/build/telosb/hex2raw-h.log");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/out-h.ihex $dir2/build/telosb/out-h.raw > $dir2/build/telosb/hex2raw-h.log");
		
		# 3. diff
		&excmd("$diff $dir1/build/telosb/out-h.raw $dir2/build/telosb/out-h.raw ../benchmarks/delta-$no.raw > ../benchmarks/hermes-$no.log");
		$deltasize = -s "../benchmarks/delta-$no.raw";
		print "<<< $rs[1] $rs[2] $deltasize\n";
		
	}
}
close cc;

exit;
