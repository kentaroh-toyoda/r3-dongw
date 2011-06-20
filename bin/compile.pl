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
		&excmd("cd $dir; make clean");
		
		
		# 2. make target from Makefile
		&excmd("cd $dir; make telosb");
		&excmd("mv $dir/build/telosb/main.exe $dir/build/telosb/main-n.exe");
		&excmd("mv $dir/build/telosb/main.ihex $dir/build/telosb/main-n.ihex");
		&excmd("msp430-objdump -zhD $dir/build/telosb/main-n.exe > $dir/build/telosb/main-n.asm");
		
		# 3. make target from mfr, i.e. for r2 and r3
		$info = `echo "CFLAGS += -Wl,-q" > $dir/mfr`;
    $info = `echo "CFLAGS += -Wl,-section-start=.text=0x4a00" >> $dir/mfr`;
    $info = `cat $dir/Makefile >> $dir/mfr`;
    &excmd("cd $dir; make telosb -f mfr");
    &excmd("mv $dir/build/telosb/main.exe $dir/build/telosb/main-r2.exe");
		&excmd("mv $dir/build/telosb/main.ihex $dir/build/telosb/main-r2.ihex");
	}
}
close bm;

exit;
