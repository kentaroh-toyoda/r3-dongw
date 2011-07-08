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
	#$xdiff = $diff;
	$xdiff = "../rmtd_r2/linux/xrmtd_AE1.exe";
	$bi   = "../bi/linux/bi.exe";
	$si   = "../bi/linux/si.exe";
}

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

# for xrmtd
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
open out, ">../gnuplot/r2.log" or die "cannot open r2.log\n";
print out "\# results for R2\n";
print out "\#\n";
print out "\# No old new all_delta compression_radio PSI code_old code_new code_delta code_cr meta_old meta_new meta_delta meta_cr\n";
while (<cc>) {
	chomp;
	
  if ($_) {
  	@rs = split;
  	$no = $rs[0];
  	$dir1 = "../benchmarks/$rs[1]";
		$dir2 = "../benchmarks/$rs[2]";
		$bmk1 = $rs[1]; $bmk2 = $rs[2];
		
		print ">>>processing case\#$no: $dir1 -> $dir2\n";
		
		# 1. generate main.exe and main.raw required by bi.exe
		&excmd("cp -f $dir1/build/telosb/main-r2.exe $dir1/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir1/build/telosb/main-r2.ihex $dir1/build/telosb/main.raw");
		
		&excmd("cp -f $dir2/build/telosb/main-r2.exe $dir2/build/telosb/main.exe");
		&excmd("perl ./hex2raw.pl $dir2/build/telosb/main-r2.ihex $dir2/build/telosb/main.raw");
		
		# 2. exec bi.exe.  generate out.exe with reference inflated with 0s
    # and also generate a relocation table in rela.raw file
    &excmd("$bi 0 $dir1 >$dir1/build/telosb/bi0.txt");
    &excmd("$bi 0 $dir2 >$dir2/build/telosb/bi0.txt");
    
    # 3. generate out.ihex and also copy to out-bi0.exe for psi
    &excmd("msp430-objcopy --output-target=ihex $dir1/build/telosb/out.exe $dir1/build/telosb/out.ihex");
    &excmd("msp430-objcopy --output-target=ihex $dir2/build/telosb/out.exe $dir2/build/telosb/out.ihex");
    &excmd("cp $dir1/build/telosb/out.exe $dir1/build/telosb/out-bi0.exe");
    &excmd("cp $dir2/build/telosb/out.exe $dir2/build/telosb/out-bi0.exe");
    
    # 4. generate out.raw
    &excmd("perl ./hex2raw.pl $dir1/build/telosb/out.ihex $dir1/build/telosb/out.raw > $dir1/hex2raw-r2.log");
    &excmd("perl ./hex2raw.pl $dir2/build/telosb/out.ihex $dir2/build/telosb/out.raw > $dir2/hex2raw-r2.log");
    
    # 5. diff for the code
    &excmd("$diff $dir1/build/telosb/out.raw $dir2/build/telosb/out.raw ../benchmarks/delta-out-$no.raw > ../benchmarks/r2-out-$no.log");
        
    # 6. diff for the rela entries
    &excmd("$xdiff $dir1/build/telosb/rela.raw $dir2/build/telosb/rela.raw 5 ../benchmarks/delta-rela-$no.raw> ../benchmarks/rela-$no.log");
    
    #($dummy,$ds2) = &getsize("../benchmarks/rela-$no.log");
    
		
		# 7. psi
		&excmd("$si $dir1/build/telosb/out-bi0.exe >$dir1/build/telosb/si-bi0.txt");
		&excmd("$si $dir2/build/telosb/out-bi0.exe >$dir2/build/telosb/si-bi0.txt");
		&fix("$dir1/build/telosb/si-bi0.txt", "$dir1/build/telosb/si-n.txt");
		&fix("$dir2/build/telosb/si-bi0.txt", "$dir2/build/telosb/si-n.txt");
		
		$psi_bi0 = &getpsi("$dir1/build/telosb/si-bi0.txt", "$dir2/build/telosb/si-bi0.txt");
		
		$ds1 = -s "../benchmarks/delta-out-$no.raw";
		$ds2 = -s "../benchmarks/delta-rela-$no.raw";
		
		# gzip
		&excmd("gzip -f -9 ../benchmarks/delta-out-$no.raw"); # gen main-n.raw.gz
		&excmd("gzip -f -9 ../benchmarks/delta-rela-$no.raw"); # gen main-n.raw.gz
		
		$gzsize_out = -s "../benchmarks/delta-out-$no.raw.gz";
		$gzsize_rela = -s "../benchmarks/delta-rela-$no.raw.gz";
		
		$gzsize = $gzsize_out + $gzsize_rela;
		
		$deltasize = $ds1 + $ds2;
		$cr = ($deltasize-$gzsize) / $deltasize;
		
		$cr_out = ($ds1-$gzsize_out) / $ds1;
		$cr_rela = ($ds2-$gzsize_rela) / $ds2;
		
		$outold = -s "$dir1/build/telosb/out.raw";
		$outnew = -s "$dir2/build/telosb/out.raw";
		$relaold = -s "$dir1/build/telosb/rela.raw";
		$relanew = -s "$dir2/build/telosb/rela.raw";
		
		print "<<< $bmk1 $bmk2 $deltasize $psi_bi0 $ds1 $ds2\n";
		
		print out "$no $bmk1 $bmk2 $deltasize $cr $psi_bi0 $outold $outnew $ds1 $cr_out $relaold $relanew $ds2 $cr_rela\n";
	}
}
close cc;
close out;
exit;
