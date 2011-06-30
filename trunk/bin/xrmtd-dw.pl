#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $xdiff = "..\\rmtd_r2\\win32\\xrmtd.exe";
  $bi   = "..\\bi\\win32\\bi.exe";
  $si   = "..\\bi\\win32\\si.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
	$xdiff = "../rmtd_r2/linux/xrmtd.exe";
	$bi   = "../bi/linux/bi.exe";
	$si   = "../bi/linux/si.exe";
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
		
		       
    # 6. diff for the rela entries
    &excmd("$xdiff $dir1/build/telosb/rela.raw $dir2/build/telosb/rela.raw 5 > ../benchmarks/xrmtd-rela-$no.log");
    
		open fd, "<../benchmarks/xrmtd-rela-$no.log" or die "cannot open ../benchmarks/xrmtd-rela-$no.log\n";
		while (<fd>) {
			chomp;
			if (/^\[([\d]+)\]/) {
				$totalbytes = $1;
			}
		}
		close fd;
		
		
		&excmd("perl ../rmtd_r2/opx.pl ../benchmarks/xrmtd-rela-$no.log > ../benchmarks/xrmtd-fixed-$no.log");
		open fd, "<../benchmarks/xrmtd-fixed-$no.log";
		while (<fd>) {
			if (/reducedbytes:/) {
				my @rs = split;
				$rb = $rs[1];
			}
			
		}
		close fd;
		
		$fixedbytes = $totalbytes - $rb;
		
		print "<<< $bmk1 $bmk2 $totalbytes $fixedbytes\n";
		
		
	}
}
close cc;
exit;
