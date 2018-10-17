#!/usr/bin/perl -w
use strict;
die "perl $0 <protein.exon.coverage> <fraction>" unless @ARGV == 2;
my ($cov,$frac) = @ARGV;
my (%total_len,%cov_len);
open COV,"$cov" or die;
open OUT,">$frac" or die;
while(<COV>)
{
	chomp;
	my ($id,$len,$total) = (split /\t/,$_)[3,13,14];
	my $trid = (split /:/,$id)[0];
	if (exists $total_len{$trid}) 
	{
		$total_len{$trid} += $total;
		$cov_len{$trid} += $len;
	}else{
		$total_len{$trid} = $total;
		$cov_len{$trid} = $len;
	}
}
foreach my $key (keys %total_len)
{
#	print "$key\t$cov_len{$key}\t$total_len{$key}\n";
	my $frc = $cov_len{$key}/$total_len{$key};
	print OUT "$key\t$cov_len{$key}\t$total_len{$key}\t$frc\n";
}
close COV;
close OUT;
