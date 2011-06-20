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
		
		# 1. inst.pl requires bi.txt and main.asm
		#    we assume bi is generated by the run of r3.pl and we generate main.asm now
		&excmd("msp430-objdump -zhD $dir/build/telosb/main-r2.exe >$dir/build/telosb/main-r2.asm");
		&excmd("perl ./inst.pl $dir/build/telosb/bi1.txt $dir/build/telosb/main-r2.asm >$dir/build/telosb/inst.log");
		
		open in, "<$dir/build/telosb/inst.log" or die "cannot find $dir/build/telosb/inst.log";
		print "<<<";
		while (<in>) {
			@rs = split;
			if (/references_in_calls:/) {
				print "$rs[2] ";
			}
			elsif (/references_in_instructions:/) {
				print "$rs[1]\n";
			}
		}
		close in;				
	}
}
close bm;

exit;
