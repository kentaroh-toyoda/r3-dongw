#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

$dir = "../benchmarks/bm";

open (dt, ">$dir/delta.tbl") or die "cannot open delta.tbl\n";

print dt "bit\tbyte\n";

$no = 1;
for($n0=1;$no<=10;$no++)
{
  open bmbit, "<$dir/bm-$no.log" or die"cannot open bm-$no.log";
  open bmbyte, "<$dir/bm-byte-$no.log" or die"cannot open bm-byte-$no.log"; 
  $bitdelta =0;
  $bytedelta =0;
  while(<bmbit>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];

      if($type eq "delta")
      {
        $bitdelta = $rs[1];
      }

    }
  }
  while(<bmbyte>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];

      if($type eq "delta")
      {
        $bytedelta = $rs[1]/8;
      }

    }
  }
  print dt "$bitdelta\t$bytedelta\n";
  close bmbit;
  close bmbyte;
}
close dt;
exit;

