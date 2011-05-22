#!/usr/bin/perl

$afile = $ARGV[0]; # diff log file
$efile = $ARGV[1]; # exe

@addrs=();

open afd, "<$afile" or die "cannot open $afile\n";
while (<afd>) {
	chomp;
	## Mem[addr]
	my @rs = split /[ \[\]]+/;
	#$rs[6]\n";
	my $i=0;
	for ($i=0; $i<@rs; $i++) {
		if ($rs[$i] eq "Mem") {
			last;
		}
	}
	my $a=0xffff;
	if ($i<@rs) {
	  $a = hex("$rs[$i+1]");
  }
	push @addrs, $a;
}
close afd;

for (my $i=0; $i<@addrs; $i++) {
	if ($addrs[$i]<65536) {
	  #print "$addrs[$i] ";
  }
}
#exit;

$state=0;
$info = `msp430-objdump -zhD $efile > main.asm`;
open efd, "<main.asm" or die "cannot open asm file\n";
while (<efd>) {
  chomp;
  my @rs;
  if (/Idx/ && /Name/ && /Size/) {
  	$state=1; next;
  } elsif (/Disassembly of section/ && /text/) {
  	$state=2; next;
  } elsif (/Disassembly of section/) {
  	if (@funcnames>1) {
  		push @funcsizes, ($instaddrs[-1]+$instsizes[-1]-$funcaddrs[-2]);
  	}
  	$state=3; next;
  }
  
  if ($state==1) {
  	@rs = split;
  	if ($rs[1] =~ /bss/) {
  		$bss_start = hex("$rs[3]");
  		$bss_size  = hex("$rs[2]");
  	} elsif ($rs[1] =~ /data/) {
  		$data_start = hex("$rs[3]");
  		$data_flash_start = hex("$rs[4]");
  		$data_size = hex("$rs[2]");
  	} elsif ($rs[1] =~ /text/) {
  		$text_start = hex("$rs[3]");
  		$text_size = hex("$rs[2]");
  	} elsif ($rs[1] =~ /vectors/) {
  		$vectors_start = hex("$rs[3]");
  		$vectors_size = hex("$rs[2]");
  	}
  }
  elsif ($state==2) {
  	if (/^[\da-f]{8}/) {
  		@rs = split /[ :]+/;
  		$funcname = $rs[1];
  		
  		push @funcnames, $funcname;
  		push @funcaddrs, hex("$rs[0]");
  		if (@funcnames>1) {
  			push @funcsizes, ($instaddrs[-1]+$instsizes[-1]-$funcaddrs[-2]);
  		}
  		#print "$funcname ";
  	}
  	elsif (/[\da-f]{4}:/) {
  		# 0 empty 1: memaddr, 2 instr code ... ? instr
  		@rs = split /[:\s]+/;
  		my $i;
  		for ($i=2; $i<@rs; $i++) {
  			if ($rs[$i] =~ /^[\da-f]{2}$/) {
  				$i++;
  			} else {
  				last;
  			}
  		}
  		push @instnames, $rs[$i];
  		push @instaddrs, hex("$rs[1]");
  		push @instsizes, ($i-2);
  		#print "$_ -- ($rs[$i] $rs[1] $i)\n";
  	}
  }
}
close efd;


sub printsections {
  print "bss  ($bss_start, $bss_size)\n";
  print "data ($data_start/$data_flash_start, $data_size)\n";
  print "text ($text_start, $text_size)\n";
  print "vectors ($vectors_start, $vectors_size)\n";
}

sub printfunctions {
  for (my $i=0; $i<@funcnames; $i++) {
  	my $val = sprintf("%4X", $funcaddrs[$i]);
    print "$funcnames[$i] ($val, $funcsizes[$i])\n";	
  }
}

sub printinstructions {
	for (my $i=0; $i<@instnames; $i++) {
	  my $val = sprintf("%04X", $instaddrs[$i]);
		print "$instnames[$i] ($val, $instsizes[$i])\n";
	}
}

sub findfunc {
	my ($memaddr) = @_;
	
	# return the function index
	for (my $i=0; $i<@funcnames; $i++) {
		if ($funcaddrs[$i]<=$memaddr && $memaddr<$funcaddrs[$i]+$funcsizes[$i]) {
			return $funcnames[$i];
		}
	}
	# other cases, e.g. in data sections, or in vectors sections
	return "nofunc";
}

sub findinst {
  my ($memaddr) = @_;
  
  # return the instruction type??	
  for (my $i=0; $i<@instnames; $i++) {
  	if ($instaddrs[$i]<=$memaddr && $memaddr<$instaddrs[$i]+$instsizes[$i]) {
  		return $instnames[$i];
  	}
  }
  return "noinst";
}

#################################################

#&printfunctions();
#&printinstructions();

%fmap=();
%imap=();

for (my $i=0; $i<@addrs; $i++) {
	if ($addrs[$i]<65536) {
	  #print "$addrs[$i] ";
	  my $fn = &findfunc($addrs[$i]);
	  my $in = &findinst($addrs[$i]);
	  #print "$addrs[$i] is located in ($fn,$in)\n";
	  $fmap{$fn}++;
	  $imap{$in}++;
  }
}
#exit;

while (($k, $v) = each(%fmap)) {
	if ($v>=1) {
	  print "$k $v\n";
  }
}

while (($k, $v) = each(%imap)) {
	if ($v>=1) {
		print "$k $v\n";
	}
}
