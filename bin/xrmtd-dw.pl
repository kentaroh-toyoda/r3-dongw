#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $xdiff = "..\\rmtd_r2\\win32\\xrmtd_dw.exe";
  $bi   = "..\\bi\\win32\\bi.exe";
  $si   = "..\\bi\\win32\\si.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
	$xdiff = "../rmtd_r2/linux/xrmtd_dw.exe";
	$bi   = "../bi/linux/bi.exe";
	$si   = "../bi/linux/si.exe";
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

sub getsize() {
	my ($file) = @_;
	my $totalbytes;
	my $fixedbytes;
	
	open fd, "<$file" or die "cannot open $file\n";
	while (<fd>) {
		chomp;
		if (/^\[([\d]+)\]/) {
			$totalbytes = $1;
		}
	}
	close fd;
		
	&excmd("perl ../rmtd_r2/opx.pl $file > ../benchmarks/xrmtd-fixed.log");
	open fd, "<../benchmarks/xrmtd-fixed.log";
	while (<fd>) {
		if (/reducedbytes:/) {
			my @rs = split;
			$rb = $rs[1];
		}
			
	}
	close fd;
		
	$fixedbytes = $totalbytes - $rb;
	return ($totalbytes,$fixedbytes);
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
    
		my ($tb,$fb) = &getsize("../benchmarks/xrmtd-rela-$no.log");
		
		print "<<< $bmk1 $bmk2 $tb $fb\n";
		
		
	}
}
close cc;
exit;
