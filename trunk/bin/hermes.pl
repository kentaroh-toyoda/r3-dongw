#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $si   = "..\\bi\\win32\\si.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
	$si   = "../bi/linux/si.exe";
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

sub findoldentaddr() {
	my ($brname) = @_;
	for ($i=0; $i<@oldfunname; $i++) {
		if ($brname eq "<$oldfunname[$i]>") {
			return $oldfunaddr[$i];
		}
	}
	return -1;
}

sub findnewentaddr() {
	my ($brname) = @_;
	for ($i=0; $i<@newfunname; $i++) {
		if ($brname eq "<$newfunname[$i]>") {
			return $newfunaddr[$i];
		}
	}
	return -1;
}

sub getpsi() {
  my ($si1, $fn1, $si2, $fn2) = @_;
  
  # 1. PSI for native
	## we assume the existence of bi1.txt generated by r3.pl
	## rold:  how many references in the old program?
	## rnew:  how many references in the new program?
	## match: how many references in the new program match that in the old program?
	my @oldsymname=();
	my @oldsymaddr=();
	my @newsymname=();
	my @newsymaddr=();
	
	@oldfunname=();
	@oldfunaddr=();
	@newfunname=();
	@newfunaddr=();
	
	open fn, "<$fn1" or die "cannot open $fn1\n";
	while (<fn>) {
		chomp;
		my @rs = split;
		push @oldfunname, $rs[0];
		push @oldfunaddr, hex("$rs[1]");
	}
	close fn;
	
	open fn, "<$fn2" or die "cannot open $fn2\n";
	while (<fn>) {
		chomp;
		my @rs = split;
		push @newfunname, $rs[0];
		push @newfunaddr, hex("$rs[1]");
	}
	close fn;
		
	open si, "<$si1" or die "cannot open $si1\n";
	while (<si>) {
		chomp;
		if (/^ref_sym/) {
			@rs = split;
			push @oldsymname, $rs[1];
			## call address, is rs[2] or something else?
			$entaddr = &findoldentaddr($rs[1]);
			if ($rs[-1] eq "b012" && $entaddr > 0) {
				push @oldsymaddr, $entaddr;
			} else {
				push @oldsymaddr, hex("$rs[2]");
			}
			
		}
	}
	close si;
	
	open si, "<$si2" or die "cannot open $si2\n";
	while (<si>) {
		chomp;
		if (/^ref_sym/) {
			@rs = split;
			push @newsymname, $rs[1];
			$entaddr = &findnewentaddr($rs[1]);
			if ($rs[-1] eq "b012" && $entaddr > 0) {
				push @newsymaddr, $entaddr;
			} else {
			  push @newsymaddr, hex("$rs[2]");
			}
		}
	}
	close si;
	## how many matched?
	$match=0;
	for ($i=0; $i<@newsymname; $i++) {
		for ($j=0; $j<@oldsymname; $j++) {
			if ( ($newsymname[$i] eq $oldsymname[$j]) &&
			     ($newsymaddr[$i] == $oldsymaddr[$j]) ) 
			{
			  $match++;
			  last;	
			}
		}
	}
	$oldcnt = @oldsymname;
	$newcnt = @newsymname;
	
	return $match / ($oldcnt>$newcnt ? $oldcnt : $newcnt);
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
		
		# 1. Hermes do not require bi.exe, it uses main-n.exe,
		# now out.raw combines code (with function indirections) and jump table
		&excmd("perl ./genhex.pl $dir1 >../benchmarks/genhex-$no-old.log");
		&excmd("perl ./genhex.pl $dir2 $dir1/build/telosb/func.txt >../benchmarks/genhex-$no-new.log");
		
		# 2. convert to out.raw and diff
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/out-h.ihex $dir1/build/telosb/out-h.raw > $dir1/build/telosb/hex2raw-h.log");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/out-h.ihex $dir2/build/telosb/out-h.raw > $dir2/build/telosb/hex2raw-h.log");
		
		
		#################################### 2.5: compute the psi
		&excmd("$si $dir1/build/telosb/main-$no.exe > $dir1/build/telosb/si-h.txt");
		&excmd("$si $dir2/build/telosb/main-$no.exe > $dir2/build/telosb/si-h.txt");
		
		## replace line with b012
		$psi = &getpsi("$dir1/build/telosb/si-h.txt", "$dir1/build/telosb/func.txt",
		               "$dir2/build/telosb/si-h.txt", "$dir2/build/telosb/func.txt");
		
		
		####################################
		
		# 3. diff
		&excmd("$diff $dir1/build/telosb/out-h.raw $dir2/build/telosb/out-h.raw ../benchmarks/delta-$no.raw > ../benchmarks/hermes-$no.log");
		$deltasize = -s "../benchmarks/delta-$no.raw";
		print "<<< $bmk1 $bmk2 $deltasize $psi\n";	
	}
}
close cc;

exit;
