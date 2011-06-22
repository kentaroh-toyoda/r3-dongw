#!/usr/bin/perl

$os = $^O;

if ($os =~ /MSWin32/) {
  $diff = "..\\diff_r3\\win32\\diff.exe";
  $bi   = "..\\bi\\win32\\bi.exe";
  $si   = "..\\bi\\win32\\si.exe";
}
elsif ($os =~ /linux/) {
	$diff = "../diff_r3/linux/diff.exe";
	$bi   = "../bi/linux/bi.exe";
	$si   = "../bi/linux/si.exe";
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

sub getpsi() {
  my ($si1, $si2) = @_;
  
  # 1. PSI for native
	## we assume the existence of bi1.txt generated by r3.pl
	## rold:  how many references in the old program?
	## rnew:  how many references in the new program?
	## match: how many references in the new program match that in the old program?
	my @oldsymname=();
	my @oldsymaddr=();
	my @newsymname=();
	my @newsymaddr=();
		
	open si, "<$si1" or die "cannot open $si1\n";
	while (<si>) {
		chomp;
		if (/^ref_sym/) {
			@rs = split;
			push @oldsymname, $rs[1];
			push @oldsymaddr, hex("$rs[2]");
		}
	}
	close si;
	open si, "<$si2" or die "cannot open $si2\n";
	while (<si>) {
		chomp;
		if (/^ref_sym/) {
			@rs = split;
			push @newsymname, $rs[1];
			push @newsymaddr, hex("$rs[2]");
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

sub fix() {
	my ($t, $r) = @_;
	my @tlines=();
	my @rlines=();
	my $tcnt;
	my $rcnt;
	
	open ft, "<$t" or die "cannot open $t";
	while (<ft>) {
		chomp;
		push @tlines, $_;
	}	
	close ft;
	open fr, "<$r" or die "cannot open $r";
	while (<fr>) {
		chomp;
		push @rlines, $_;
	}
	close fr;
	
	$tcnt = @tlines;
	$rcnt = @rlines;
	if ($tcnt != $rcnt) {
		print "si file not match\n";
		exit;
	}
	open ft, ">$t" or die "cannot open $t for write";
	for (my $i=0; $i<$tcnt; $i++) {
	  my @rt = split / /, $tlines[$i];
	  my @rr = split / /, $rlines[$i];
	  $rt[1] = $rr[1];
	  my $line = join ' ', @rt;
	  print ft "$line\n";
  }
	close ft;	
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
		
		# 5. gen out.ihex from out.exe and copy out.exe to out-bi2.exe (for psi)
		&excmd("msp430-objcopy --output-target=ihex $dir1/build/telosb/out.exe $dir1/build/telosb/out.ihex");
		&excmd("msp430-objcopy --output-target=ihex $dir2/build/telosb/out.exe $dir2/build/telosb/out.ihex");
		&excmd("cp $dir1/build/telosb/out.exe $dir1/build/telosb/out-bi2.exe");
		&excmd("cp $dir2/build/telosb/out.exe $dir2/build/telosb/out-bi2.exe");
		
		
		# 6. out.ihex -> out.raw
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/out.ihex $dir1/build/telosb/out.raw > $dir1/hex2raw-out.log");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/out.ihex $dir2/build/telosb/out.raw > $dir2/hex2raw-out.log");
		
		# 7: encap three files
		&excmd("python ./encap.py $dir1/build/telosb/all.ext $dir1/build/telosb/bm.raw $dir1/build/telosb/sym.raw $dir1/build/telosb/out.raw");
		&excmd("python ./encap.py $dir2/build/telosb/all.ext $dir2/build/telosb/bm.raw $dir2/build/telosb/sym.raw $dir2/build/telosb/out.raw");
	  
		# 8. diff the two out.raws. args: old file, new file, delta file
		# diff all seems have problems
		&excmd("$diff $dir1/build/telosb/all.ext $dir2/build/telosb/all.ext ../benchmarks/delta-$no.raw > ../benchmarks/r3-$no.log");
		# also diff separate files
		&excmd("$diff $dir1/build/telosb/out.raw $dir2/build/telosb/out.raw ../benchmarks/delta-out-$no.raw > ../benchmarks/r3-out-$no.log");
		&excmd("$diff $dir1/build/telosb/bm.raw $dir2/build/telosb/bm.raw ../benchmarks/delta-bm-$no.raw > ../benchmarks/r3-bm-$no.log");
		&excmd("$diff $dir1/build/telosb/sym.raw $dir2/build/telosb/sym.raw ../benchmarks/delta-sym-$no.raw > ../benchmarks/r3-sym-$no.log");
		
		# 9. psi
		&excmd("$si $dir1/build/telosb/out-bi2.exe >$dir1/build/telosb/si-bi2.txt");
		&excmd("$si $dir2/build/telosb/out-bi2.exe >$dir2/build/telosb/si-bi2.txt");
		&fix("$dir1/build/telosb/si-bi2.txt", "$dir1/build/telosb/si-n.txt");
		&fix("$dir2/build/telosb/si-bi2.txt", "$dir2/build/telosb/si-n.txt");
		
		$psi_bi2 = &getpsi("$dir1/build/telosb/si-bi2.txt", "$dir2/build/telosb/si-bi2.txt");
		
		$outsize = -s "../benchmarks/delta-out-$no.raw";
		$bmsize    = -s "../benchmarks/delta-bm-$no.raw";
		$symsize   = -s "../benchmarks/delta-sym-$no.raw";
		$allsize  = -s "../benchmarks/delta-$no.raw";
		
		$tot = $outsize+$bmsize+$symsize;
		print "<<< $bmk1 $bmk2 $tot $psi_bi2 $bmsize $symsize $outsize $allsize\n";
	}
}
close cc;

exit;
