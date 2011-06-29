#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

$dir = "../benchmarks/rela";

open (dt, ">$dir/delta.tbl") or die "cannot open delta.tbl\n";

print dt "newsize\tdelta\n";

$no = 1;
for($n0=1;$no<=10;$no++)
{
  open xrmtd, "<$dir/xrmtd-$no.log" or die"cannot open xrmtd-$no.log";
  $newsize =0;
  $delta =0;
  while(<xrmtd>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];
      if($type eq "newsize")
      {
        $newsize = $rs[1];
      }
      if($type eq "delta")
      {
        $delta = $rs[1];
      }

    }
  }

  print dt "$newsize\t$delta\n";
  close xrmtd;
}
close dt;
exit;

