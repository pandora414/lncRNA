#!/usr/bin/perl -w
use strict;
die "perl $0 <cpat.txt> <original merged gtf> <coding prob score cutoff> <output gtf>" unless @ARGV == 4;
my $list = shift;
my $gtf = shift;
my $cutoff =shift;
my $out = shift;
$cutoff ||= 0.363;
my (%hash,@code);

open LIST,"$list" or die ;
while(<LIST>)
{
	chomp;
	next if(/^#/ || /mRNA_size/);
	my ($trid,$score)=(split /\t/,$_)[0,5];
	$hash{$trid} = $score;
}
open GTF,"$gtf" or die;
open OUT,">$out" or die;
while (<GTF>)
{
	chomp;
	my $attr = (split /\t/,$_)[8];
	if ($attr =~ /transcript_id "(\w+.+?)"/)
	{
		my $transid = $1;
		if (exists $hash{$transid} && $hash{$transid} < $cutoff)
		{
			 print OUT "$_\n";
		}
		else {
			next;
		}
	}
	else {
		print "error: the $attr have no transcript_id,please check!\n";
	}
}
close LIST;
close GTF;
close OUT;
	
	
