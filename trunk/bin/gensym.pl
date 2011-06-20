#!/usr/bin/perl

## generate symbol.txt for r3 oldsym.txt

$bitxt = $ARGV[0];
$oldsymtxt = $ARGV[1];
#handle the output of bi.exe

@symname=();
@symaddr=();

@newsymname=();
@newsymaddr=();

@oldsymname=();
@oldsymaddr=();
@oldinnew=();

sub insertsym() {
	my ($name, $addr) = @_;
	my $i;
	
	if ($name eq "<>") { # actually, the symbol start with + is the empty symbol
		return; # do not insert
	}
	
	for ($i=0; $i<@symname; $i++) {
		if ($symname[$i] eq $name) { # already in
			## check if addr and symaddr equal
			if ($addr != $symaddr[$i]) {
				print "$name: inconsistent error\n";
				exit;
		  }
		  return;
		}
	}
	$symname[$i] = $name;
	$symaddr[$i] = $addr;
}

sub insertnewsym() {
	my ($name, $addr) = @_;
	my $i;
	
	if ($name eq "<>") { # actually, the symbol start with + is the empty symbol
		return; # do not insert
	}
	
	for ($i=0; $i<@newsymname; $i++) {
		if ($newsymname[$i] eq $name) { # already in
			## check if addr and symaddr equal
			if ($addr != $newsymaddr[$i]) {
				print "$name: inconsistent error\n";
				exit;
		  }
		  return;
		}
	}
	$newsymname[$i] = $name;
	$newsymaddr[$i] = $addr;
}

sub printsym() {
	## note empty line is also possible
	for (my $i=0; $i<@symname; $i++) {
		print "$symname[$i] $symaddr[$i]\n";
	}
}

sub findinoldsym() {
	my ($name) = @_;
	# if in old, return the index in old
	for (my $i=0; $i<@oldsymname; $i++) {
		if ($name eq $oldsymname[$i]) {
			return $i;
		}
	}
	return -1; #cannot find
}

sub usefree() {
	my $i;
	for ($i=0; $i<@oldinnew; $i++) {
		if (!$oldinnew[$i]) {
			return $i;
		}
	}
	return $i;
}

open bi, "<$bitxt" or die "cannot open $bitxt\n";

if (!$oldsymtxt) { # if not specifed
  # alloc for all referenced named symbols
  for (<bi>) {
  	chomp;
  	my @rs = split;
  	if (/^ref_sym/) {
  		my $name = $rs[1];
  		my $addr = $rs[2];
  		&insertsym($name, $addr); # sequentially alloc slots for each unique symbol
  	}
  }
  &printsym();
} else {
	# 1) init oldsym
	open old, "<$oldsymtxt" or die "cannot open $oldsymtxt";
	while (<old>) {
		chomp;
		my @rs = split;
		push @oldsymname, $rs[0];
		push @oldsymaddr, $rs[1];
	}
	close old;
	
	# 2) init newsym
	for (<bi>) {
  	chomp;
  	my @rs = split;
  	if (/^ref_sym/) {
  		my $name = $rs[1];
  		my $addr = $rs[2];
  		&insertnewsym($name, $addr); # sequentially alloc slots for each unique symbol
  	}
  }
	
  # 3) initialize oldinnew
  for (my $i=0; $i<@oldsymname; $i++) {
  	my $in = 0;
  	for (my $j=0; $j<@newsymname; $j++) {
  		if ($oldsymname[$i] eq $newsymname[$j]) {
  			$in=1;
  			last;
  		}
  	}
  	$oldinnew[$i] = $in;
  }	
	
	# alloc for all referenced named symbols according to old...
  for (my $i=0; $i<@newsymname; $i++) {
  	my $name = $newsymname[$i];
  	my $addr = $newsymaddr[$i];
  	# we alloc which slot to this symbol??
  	my $pin = &findinoldsym($name);
  		
  	if ($pin>=0) {
  	  # pin to the old index
  		$symname[$pin] = $name;
  		$symaddr[$pin] = $addr;
  	} else { # cannot find 
  	  # first, use free space
  		# if cannot alloc new
  		my $free = &usefree();
  		$symname[$free] = $name;
  		$symaddr[$free] = $addr;	
  	}
  }
  &printsym();
}

close bi;
