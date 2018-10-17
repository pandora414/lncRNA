#!/usr/bin/perl -w
use strict;
die "perl $0 <gtf file> <exon bed file>" unless @ARGV == 2;
my ($gtf,$bed) = @ARGV;
open GTF,"$gtf" or die;
open OUT,">$bed" or die;
while(<GTF>)
{
	chomp;
	next if(/^#/ || /^$/);
	my @arry = split /\t/,$_;
	if($arry[2] eq "exon")
	{
		$arry[8] =~ /transcript_id "(\w+)";/;
		
		my $trid = $1;
		$arry[8] =~ /exon_number "(\d+)";/;
		my $exon = $1;
		my $start = $arry[3] - 1;
		my $len = $arry[4] - $arry[3] + 1;
		print OUT "$arry[0]\t$start\t$arry[4]\t$trid:$exon\t0\t$arry[6]\t$start\t$arry[4]\t0\t1\t$len,\t0,\n";
	}else{
		next;
	}
}
close GTF;
close OUT;
