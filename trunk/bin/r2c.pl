#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $xdiff = $diff;
  $bi   = "..\\bi\\win32\\bi.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
	$xdiff = $diff;
	$bi   = "../bi/linux/bi.exe";
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
		
		# 1. generate main.exe and main.raw required by bi.exe
		&excmd("cp -f $dir1/build/telosb/main-r2.exe $dir1/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/main-r2.ihex $dir1/build/telosb/main.raw");
		
		&excmd("cp -f $dir2/build/telosb/main-r2.exe $dir2/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/main-r2.ihex $dir2/build/telosb/main.raw");
		
		# 2. exec bi.exe.  generate out.exe with reference inflated with 0s
    # and also generate a relocation table in rela.raw file
    &excmd("$bi 1 $dir1 >$dir1/build/telosb/bi0c.txt");
    &excmd("$bi 1 $dir2 >$dir2/build/telosb/bi0c.txt");
    
    # 3. generate out.ihex and copy to out-bi1.exe for psi
    &excmd("msp430-objcopy --output-target=ihex $dir1/build/telosb/out.exe $dir1/build/telosb/out.ihex");
    &excmd("msp430-objcopy --output-target=ihex $dir2/build/telosb/out.exe $dir2/build/telosb/out.ihex");
    &excmd("cp $dir1/build/telosb/out.exe $dir1/build/telosb/out-bi1.exe");
    &excmd("cp $dir2/build/telosb/out.exe $dir2/build/telosb/out-bi1.exe");
    
    # 4. generate out.raw
    &excmd("perl ./hex2raw.pl $dir1/build/telosb/out.ihex $dir1/build/telosb/out.raw > $dir1/hex2raw-r2.log");
    &excmd("perl ./hex2raw.pl $dir2/build/telosb/out.ihex $dir2/build/telosb/out.raw > $dir2/hex2raw-r2.log");
    
    # 5. diff for the code
    &excmd("$diff $dir1/build/telosb/out.raw $dir2/build/telosb/out.raw ../benchmarks/delta-$no.raw > r2-$no.log");
        
    # 6. diff for the rela entries
    &excmd("$xdiff $dir1/build/telosb/crela.raw $dir2/build/telosb/crela.raw ../benchmarks/xdelta-$no.raw >r2x-$no.log");
		
		$deltasize = $ds1 + $ds2;
		print "<<< $rs[1] $rs[2] $deltasize\n";
		
	}
}
close cc;

exit;
