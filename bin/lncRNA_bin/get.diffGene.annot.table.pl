#!/usr/bin/perl -w
use strict;
die "perl $0 <sigdiff file> <blast table file> <diff gene blast table file>" unless @ARGV == 3;
my($diff,$tab,$out) = @ARGV;
my %hash;
open DIFF, "$diff" or die;
open TAB, "$tab" or die;
open OUT,">$out" or die;
while(<DIFF>)
{
	chomp;
	next if (/FDR/);
	my $id = (split /\t/,$_)[0];
	$hash{$id} = 1;
}
while(<TAB>)
{
	chomp;
	next if(/^$/);
	if(/^#/)
	{
		print OUT "$_\n";
		next;
	}
	my $name = (split /\t/,$_)[0];
	if(exists $hash{$name})
	{
		print OUT "$_\n";
	}
}
close DIFF;
close OUT;
close TAB;
