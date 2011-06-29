#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {        
        $xrmtd = "..\\rmtd_r2\\win32\\xrmtd.exe";
}
elsif ($os =~ /linux/) {
        $xrmtd = "../rmtd_r2/linux/xrmtd.exe";
        &excmd("gcc ../rmtd_r2/xrmtd.c -o ../rmtd_r2/linux/xrmtd.exe");
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
        $bmk1 = $rs[1]; $bmk2 = $rs[2];
		
		print ">>>processing case\#$no: $dir1 -> $dir2\n";
		
		# old file, new file, delta file
	
		&excmd("$xrmtd $dir1/build/telosb/rela.raw $dir2/build/telosb/rela.raw 8 > ../benchmarks/rela/xrmtd-$no.log");
		
	}
}
&excmd("perl ./relastat.pl");
close cc;
exit;

