#!/usr/bin/perl

sub excmd() {
	my ($cmd) = @_;
	print "$cmd\n";
	$info = `$cmd`;
}

$dir = "../benchmarks/dmt";

open (dt, ">$dir/delta.tbl") or die "cannot open delta.tbl\n";
open (tc, ">$dir/time.tbl") or die "cannot open time.tbl\n";
open (mc, ">$dir/mem.tbl") or die "cannot open mem.tbl\n";

print dt "r3\trmtd\n";
print tc "r3\trmtd\n";
print mc "r3\trmtd\n";

$no = 1;
for($n0=1;$no<=10;$no++)
{
  open diff, "<$dir/native_diff-$no.log" or die"cannot open native_diff-$no.log";
  open rmtd, "<$dir/native_rmtd-$no.log" or die"cannot open native_rmtd-$no.log";
  $diffdelta =0;
  $rmtddelta =0;
  $difftime =0;
  $rmtdtime =0;
  $diffmem =0;
  $rmtdmem =0;
  while(<diff>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];
      if($type eq "delta")
      {
        $diffdelta = $rs[1];
      }
      if($type eq "time")
      {
        $difftime = $rs[1];
      }
      if($type eq "memory")
      {
        $diffmem = $rs[1];
      }
    }
  }
  while(<rmtd>)
  {
    chomp;
    
    if($_)
    {
      @rs = split;
      $type = $rs[0];
      if($type eq "delta")
      {
        $rmtddelta = $rs[1];
      }
      if($type eq "time")
      {
        $rmtdtime = $rs[1];
      }
      if($type eq "memory")
      {
        $rmtdmem = $rs[1];
      }
    }
  }
  print dt "$diffdelta\t$rmtddelta\n";
  print tc "$difftime\t$rmtdtime\n";
  print mc "$diffmem\t$rmtdmem\n";
  close diff;
  close rmtd;
}
close dt;
close tc;
close mc;
exit;

