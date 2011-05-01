#!/usr/bin/perl

# read an ihex and transform it to memory raw
# address (4), len (4), data

$ihex = $ARGV[0];
$raw  = $ARGV[1];

if (!$raw) { $raw = "main.raw"; }

$RECTYP_DATA     = 0;
$RECTYP_EOF      = 1;
$RECTYP_EXTSEG   = 2;
$RECTYP_STARTSEG = 3;

$totalBytes = 0;
$physicalAddr = 0;
$sectionBaseAddr = 0;
$sectionCount = 0;
$imgStartOffset = 0;
$upperSegBaseAddr = 0;

@ihexdata = ();

open in, "<$ihex" or die "cannot open file\n";

while (<in>) {
	chomp;
	@chars = split //;
	# $chars[0] = :
	
	$reclen = hex("$chars[1]$chars[2]");
	$offset = hex("$chars[3]$chars[4]$chars[5]$chars[6]");
	$rectyp = hex("$chars[7]$chars[8]");
	
	if ($rectyp == $RECTYP_DATA) {
		if (($upperSegBaseAddr+$offset) != $physicalAddr) {
			my $sectionLen = $physicalAddr - $sectionBaseAddr;
			print "write previous section size=$sectionLen ($physicalAddr - $sectionBaseAddr)\n";
			for ($i=0; $i<4; $i++) {
				$ihexdata[$imgStartOffset+4+$i] = (($sectionLen >> ($i*8) ) & 0xff );
			}
		}
		if ($imageOffset == 0 || ($upperSegBaseAddr+$offset) != $physicalAddr) {
			print "start new section\n";
			$sectionCount++;
			$physicalAddr = ($upperSegBaseAddr+$offset);
			$sectionBaseAddr = ($upperSegBaseAddr+$offset);
			$imgStartOffset = $imageOffset;
			$ihexdata[$imageOffset+0] = ($physicalAddr>>0 ) & 0xff;
			$ihexdata[$imageOffset+1] = ($physicalAddr>>8 ) & 0xff;
			$imageOffset += 8;
		}
		
		for ($i=0; $i<$reclen; $i++) {
			$ihexdata[$imageOffset++] = hex("$chars[2*$i+9]$chars[2*$i+10]");
			$totalBytes++;
			$physicalAddr++;
			#print "$chars[2*$i+9]$chars[2*$i+10]";
		}
	}
	elsif ($rectyp == $RECTYP_EXTSEG) {
		print "??\n";
		$upperSegBaseAddr = hex("$chars[9]$chars[10]$chars[11]$chars[12]");
		$upperSegBaseAddr <<= 4;
	}
	elsif ($rectyp == $RECTYP_EOF) {
		print "EOF\n";
		my $sectionLen = $physicalAddr - $sectionBaseAddr;
		print "write previous section size=$sectionLen\n";
		for ($i=0; $i<4; $i++) {
			$ihexdata[$imgStartOffset+4+$i] = ($sectionLen >> ($i*8) ) & 0xff;
		}
		for ($i=0; $i<8; $i++) {
			$ihexdata[$imageOffset++] = 0x00;
		}
		print "append eight 0s\n";
	}
	elsif ($rectyp == $RECTYP_STARTSEG) {
		
	}
	else {
		printf "ERROR line: $_\n";
		exit;
	}
}

close in; 

print "sectionCount = $sectionCount\n";
print "totalBytes = $totalBytes (msp430-size main.ihex)\n";
$sz = @ihexdata;
print "rawBytes = $sz (+24 in general)\n";

open out, ">$raw" or die "cannot open output file\n";
binmode(out);
for $bb (@ihexdata) {
	my $str = sprintf("%2x", $bb);
	print out pack("H2", $str);
}
close;
