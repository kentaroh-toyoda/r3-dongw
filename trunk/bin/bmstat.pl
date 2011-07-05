#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

$dir = "../benchmarks/bm";

open (dt, ">$dir/delta.tbl") or die "cannot open delta.tbl\n";

print dt "byte\tbit\n";

$no = 1;
for($n0=1;$no<=10;$no++)
{
  open bm, "<$dir/bm-$no.log" or die"cannot open bm-$no.log";
  open bmbit, "<$dir/bm-byte-$no.log" or die"cannot open bm-byte-$no.log"; 
  $delta =0;
  $bitdelta =0;
  while(<bm>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];

      if($type eq "delta")
      {
        $delta = $rs[1];
      }

    }
  }
  while(<bmbit>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];

      if($type eq "delta")
      {
        $bitdelta = $rs[1]/8;
      }

    }
  }
  print dt "$delta\t$bitdelta\n";
  close bm;
  close bmbit;
}
close dt;
exit;

