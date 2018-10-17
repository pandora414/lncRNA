#!/usr/bin/perl -w
use strict;
die "perl $0 <ID.list.txt> <original merged gtf> <id column(1-based)> <output gtf>" unless @ARGV == 4;
my $list = shift;
my $gtf = shift;
my $col =shift;
my $out = shift;
$col ||= 1;
my (%hash);

open LIST,"$list" or die ;
while(<LIST>)
{
	chomp;
	next if(/^#/ || /mRNA_size/ || /Transcript/);
	my $trid=(split /\t/,$_)[$col-1];
	$hash{$trid} = 1;
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
		if (exists $hash{$transid})
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
	
	
