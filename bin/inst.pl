#!/usr/bin/perl

# inputs: bi.txt and main.exe
# we may also generate the CDF of each symbol's reference count

$afile = $ARGV[0]; # bi.txt
$efile = $ARGV[1]; # asm file

@addrs=();
%smap=();

open afd, "<$afile" or die "cannot open bi.txt: $afile\n";
while (<afd>) {
	chomp;
	## Mem[addr]
	my @rs = split /[ \[\]]+/;
	#$rs[6]\n";
	my $i=0;
	my $flag=0;
	for ($i=0; $i<@rs; $i++) {
		if ($rs[$i] eq "Mem") {
			$flag=1;
			last;
		}
	}
	my $a=0xffff;
	if ($flag && $i<@rs) {
	  $a = hex("$rs[$i+1]");
	  push @addrs, $a;
	  
	  $sn = $rs[1]; ## <symbol name>
	  $smap{$sn}++; # references to this symbol increments	  
  }
}
close afd;

for (my $i=0; $i<@addrs; $i++) {
	$val = sprintf("%4x", $addrs[$i]);
	print "$val ";
}
$cnt = @addrs;
print "total references to symbols: $cnt\n";

$state=0;
#$info = `msp430-objdump -zhD $efile > main.asm`;

open efd, "<$efile" or die "cannot open asm file: $efile\n";
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
  		#  if empty we add the instruction bytes to the previous one
  		if ($rs[$i] eq "") {
  			$instsizes[-1] += $i-2;
  			
  			$tmp = $i-2;
  			print "info: add $tmp bytes to $instnames[-1]\n";
  		} else {
  		  push @instnames, $rs[$i];
  		  push @instaddrs, hex("$rs[1]");
  		  push @instsizes, ($i-2);
  		}
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
  
  if ($data_start<=$memaddr && $memaddr<$data_start+$data_size) {
  	return "data";
  }
  if ($vectors_start<=$memaddr && $memaddr<$vectors_start+$vectors_size) {
  	return "vectors";
  }
  
  # return the instruction type??	
  for (my $i=0; $i<@instnames; $i++) {
  	if ($instaddrs[$i]<=$memaddr && $memaddr<$instaddrs[$i]+$instsizes[$i]) {
  		if ($instnames[$i] eq "") {
  			$hexaddr=sprintf("%x", $memaddr);
  			print "empty warning: $hexaddr\n";
  		}
  		return $instnames[$i];
  	}
  }
  $hexaddr=sprintf("%x", $memaddr);
  print "noinst warning: $hexaddr\n";
  return "noinst";
}

#################################################

#&printfunctions();
#&printinstructions();

%fmap=();
%imap=();

for (my $i=0; $i<@addrs; $i++) {
	#print "$addrs[$i]\n";
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

$fcnt=0;
$icnt=0;
$scnt=0;

$realfcnt=0;
print "references_in_functions\n";
while (($k, $v) = each(%fmap)) {
	$realfcnt++;
	if ($v>=1) {
	  print "$k $v\n";
	  $fcnt += $v;
  }
}
print "references in functions: $fcnt\n";

print "references_in_instructions\n";
while (($k, $v) = each(%imap)) {
	if ($v>=1) {
		if ($k eq "call") {
			print "references_in_calls: $k $v\n";
		} else {
		  print "$k $v\n";
	  }
		$icnt += $v;
	}
}
print "references_in_instructions: $icnt\n";
$icnt = @instnames;
print "total_number_instructions: $icnt\n";

print "references_for_symbols\n";
$cnt=0;
$realscnt=0;
while (($k, $v) = each(%smap)) {
	$realscnt++;
	if ($v>=1) {
		print "$k $v\n";
		$cnt++;
		$scnt += $v;
	}
}
print "references to all $cnt symbols: $scnt\n";
# additional data
print "total_number_symbols: $realscnt\n";
print "total_number_functions: $realfcnt\n";
