#!/usr/bin/perl

## we assume compile is already done
## we shall know the start of bss

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

sub get_bss_start() {
	my ($dir) = @_;
	my $bss_start = 0;
	my $bss_size  = 0;
	open asm, "<$dir/build/telosb/main-n.asm" or die "cannot open $dir/build/telosb/main-n.asm\n";
	while (<asm>) {
		if (/^\s*\d+\s*\.bss\s+\S+/) {
			my @rs = split;
			$bss_start = hex("$rs[3]");
  		$bss_size  = hex("$rs[2]");
		}
	}
	close asm;
	return $bss_start;
}

sub domake() {
	my ($no, $dir, $bss) = @_;
	
	my $mfh = sprintf("mfh-$no-0x%x", $bss);
	
	
	&excmd("echo CFLAGS += -Wl,-section-start=.text=0x4a00 > $dir/$mfh");
	
	&excmd("echo CFLAGS += -Wl,-q >> $dir/$mfh"); ## note: otherwise we cannot compute the psi. This should not affect the delta size of Hermes
	
	
	$cmd = sprintf("echo CFLAGS+=-Wl,--section-start=.bss=0x%x >> $dir/$mfh", $bss);
	&excmd($cmd);
	
	&excmd("cat $dir/Makefile >> $dir/$mfh");
	&excmd("cd $dir; make telosb -f $mfh");
	
	&excmd("mv $dir/build/telosb/main.exe $dir/build/telosb/main-$no.exe");
	&excmd("mv $dir/build/telosb/main.ihex $dir/build/telosb/main-$no.ihex");
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
		
		$bss1 = &get_bss_start($dir1);
		$bss2 = &get_bss_start($dir2);
		
		# negotiate a larger value
		$bss = $bss1>$bss2 ? $bss1 : $bss2;
		
		&domake($no, $dir1, $bss);
		&domake($no, $dir2, $bss);
	}
}
close cc;

exit;
