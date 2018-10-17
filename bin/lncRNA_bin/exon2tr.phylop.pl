#!/usr/bin/perl -w
use strict;
die "perl $0 <exon.phylop.txt> <transcript phylop file>" unless @ARGV == 2;
my ($phylop,$out) = @ARGV;
my (%total,%len);
open PHY,"$phylop" or die;
open OUT,">$out" or die;
while(<PHY>)
{
	chomp;
	my ($id,$len,$total) = (split /\t/,$_)[3,12,-1];
	my $trid = (split /:/,$id)[0];
	next if($total eq "NA");
	if (exists $total{$trid})
	{
		$total{$trid} += $total;
		$len{$trid} += $len;
	}else{
		$total{$trid} = $total;
		$len{$trid} = $len;
	}
}
foreach my $key (keys %total)
{
	#print "$key\t$len{$key}\t$total{$key}\n";
	my $mean = $total{$key} / $len{$key};
	print OUT "$key\t$len{$key}\t$total{$key}\t$mean\n";
}
close PHY;
close OUT;
