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
print tc "r3\trmtd\trmtdSearchTableTime\trmtdMDCDTime\trmtdPrintTime\n";
print mc "r3\trmtd\trmtdTableMem\trmtdSegMem\trmtdOptMem\tRmtdMsgMem\trmtdSegCounter\n";

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
  $rmtdSearchTblTime = 0;
  $rmtdMDCDtime = 0;
  $rmtdPrintTime = 0;
  $rmtdTblmem = 0;
  $rmtdOptmem = 0;
  $rmtdMsgmem = 0;
  $rmtdSegmem = 0;
  $rmtdSegcounter = 0;
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
      if($type eq "SearchTableTime")
      {
        $rmtdSearchTblTime = $rs[1];
      }
      if($type eq "MDCDtime")
      {
        $rmtdMDCDtime = $rs[1];
      }
      if($type eq "PrintTime")
      {
        $rmtdPrintTime = $rs[1];
      }
      if($type eq "TableMemory")
      {
        $rmtdTblmem = $rs[1];
      }
      if($type eq "OptMemory")
      {
        $rmtdOptmem = $rs[1];
      }
      if($type eq "MsgMemory")
      {
        $rmtdMsgmem = $rs[1];
      }
      if($type eq "SegmentMemory")
      {
        $rmtdSegmem = $rs[1];
      }
      if($type eq "SegCounter")
      {
        $rmtdSegcounter = $rs[1];
      }
    }
  }
  print dt "$diffdelta\t$rmtddelta\n";
  print tc "$difftime\t$rmtdtime\t$rmtdSearchTblTime\t$rmtdMDCDtime\t$rmtdPrintTime\n";
  print mc "$diffmem\t$rmtdmem\t$rmtdTblmem\t$rmtdSegmem\t$rmtdOptmem\t$rmtdMsgmem\t$rmtdSegcounter\n";
  close diff;
  close rmtd;
}
close dt;
close tc;
close mc;
exit;

