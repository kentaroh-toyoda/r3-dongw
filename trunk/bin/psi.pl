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

open cc, "<changecases.lst" or die "cannot open changecases.lst\n";
while (<cc>) {
	chomp;
	
  if ($_) {
  	@rs = split;
  	$no = $rs[0];
  	$dir1 = "../benchmarks/$rs[1]";
		$dir2 = "../benchmarks/$rs[2]";
		
		print ">>>processing case\#$no: $dir1 -> $dir2\n";
		
		$psi_n = &getpsi("$dir1/build/telosb/bi1.txt", "$dir2/build/telosb/bi1.txt");
		$psi_h = 0;
		
		## out.exe is transformed from main.exe inflated with 0;
		&excmd("$si $dir1/build/telosb/out-bi0.exe >$dir1/build/telosb/si-bi0.txt");
		&excmd("$si $dir2/build/telosb/out-bi0.exe >$dir1/build/telosb/si-bi0.txt");
		$psi_bi0 = &getpsi("$dir1/build/telosb/si-bi0.txt", "$dir2/build/telosb/si-bi0.txt");
		
		## out.exe is transformed from main.exe with chained reference
		&excmd("$si $dir1/build/telosb/out-bi1.exe >$dir1/build/telosb/si-bi1.txt");
		&excmd("$si $dir2/build/telosb/out-bi1.exe >$dir1/build/telosb/si-bi1.txt");
		$psi_bi1 = &getpsi("$dir1/build/telosb/si-bi1.txt", "$dir2/build/telosb/si-bi1.txt");
		
		## out.exe is transformed from main.exe with symbol table indexes
		&excmd("$si $dir1/build/telosb/out-bi2.exe >$dir1/build/telosb/si-bi2.txt");
		&excmd("$si $dir2/build/telosb/out-bi2.exe >$dir1/build/telosb/si-bi2.txt");
		$psi_bi2 = &getpsi("$dir1/build/telosb/si-bi2.txt", "$dir2/build/telosb/si-bi2.txt");
		
		## for Hermes, things will be difficult because our implementation does not produce an ELF
		## rather we produce the ihex file directly. 
		## so we start from bi1.txt from the native code, then try to fix the references according to Hermes
		## Hermes will replace references in calls to jump table entry address preserved in func.txt
		
		## Another important thing is that Hermes uses different compilation modes for differnet change cases,
		## even for the same benchmark, so we need to compute psi for each change case.
				
		print "<<< $psi_n $psi_h $psi_bi0 $psi_bi1 $psi_bi2\n";
	}
}
close cc;

exit;