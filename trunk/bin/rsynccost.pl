#!/usr/bin/perl

$file = $ARGV[0];
$alpha=3;
$beta=5;

$cost = 0;

open in, "<$file" or die "cannot open $file\n";

my $lastcopy=0;
my $lastcopyoff=0;
my $lastcopylen=0;

while (<in>) {
	chomp;
	my @rs = split;
	my $cmd = $rs[0];
	if ($cmd eq "COPY") {
		my $off = $rs[1];
		my $len = $rs[2];
		
		if ($lastcopy && $lastcopyoff+$lastcopylen==$off) {
		} else {
			$cost += $beta;	
		}
		$lastcopy=1;
		$lastcopyoff = $off;
		$lastcopylen = $len;
	}
	elsif ($cmd eq "ADD") {
		my $len = $rs[1];
		$cost += $alpha+$len;
		$lastcopy=0;
	}
}
close in;
print "cost: $cost\n";
