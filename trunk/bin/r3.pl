#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $bi   = "..\\bi\\win32\\bi.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
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
		
		if (0) {
		# 1. generate main.exe and main.raw required by 1st run of bi.exe
		&excmd("cp -f $dir1/build/telosb/main-r2.exe $dir1/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/main-r2.ihex $dir1/build/telosb/main.raw");
		
		&excmd("cp -f $dir2/build/telosb/main-r2.exe $dir2/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/main-r2.ihex $dir2/build/telosb/main.raw");
		
		# 2. 1st run of bi.exe
		&excmd("$bi 2 $dir1 >$dir1/build/telosb/bi1.txt");
		&excmd("$bi 2 $dir2 >$dir2/build/telosb/bi1.txt");
		
		# 3. generate sym.txt for 2nd run of bi.exe
		&excmd("perl ./gensym.pl $dir1/build/telosb/bi1.txt >$dir1/build/telosb/sym.txt");
		&excmd("perl ./gensym.pl $dir2/build/telosb/bi1.txt $dir1/build/telosb/sym.txt >$dir2/build/telosb/sym.txt");
		
		# 4. 2nd run of bi.exe
		## re-execute bi.exe, 前一次地址填充为0, 这一次(因为有sym.txt存在)
    ## 填充为正确的jump table index
		&excmd("$bi 2 $dir1 >$dir1/build/telosb/bi2.txt");
		&excmd("$bi 2 $dir2 >$dir2/build/telosb/bi2.txt");
		
		# 5. gen out.ihex from out.exe
		&excmd("msp430-objcopy --output-target=ihex $dir1/build/telosb/out.exe $dir1/build/telosb/out.ihex");
		&excmd("msp430-objcopy --output-target=ihex $dir2/build/telosb/out.exe $dir2/build/telosb/out.ihex");
		
		# 6. out.ihex -> out.raw
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/out.ihex $dir1/build/telosb/out.raw > $dir1/hex2raw-out.log");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/out.ihex $dir2/build/telosb/out.raw > $dir2/hex2raw-out.log");
		
		# 7: encap three files
		&excmd("python ./encap.py $dir1/build/telosb/all.ext $dir1/build/telosb/bm.raw $dir1/build/telosb/sym.raw $dir1/build/telosb/out.raw");
		&excmd("python ./encap.py $dir2/build/telosb/all.ext $dir2/build/telosb/bm.raw $dir2/build/telosb/sym.raw $dir2/build/telosb/out.raw");
	  }
		# 8. diff the two out.raws. args: old file, new file, delta file
		&excmd("$diff $dir1/build/telosb/all.ext $dir2/build/telosb/all.ext ../benchmarks/delta-$no.raw > ../benchmarks/r3-$no.log");
		
		$deltasize = -s "../benchmarks/delta-$no.raw";
		$bmsize    = -s "$dir2/build/telosb/bm.raw";
		$symsize   = -s "$dir2/build/telosb/sym.raw";
		
		$tot = $deltasize;
		print "<<< $rs[1] $rs[2] $tot (newbitmap=$bmsize, newsymtab=$symsize)\n";
	}
}
close cc;

exit;
