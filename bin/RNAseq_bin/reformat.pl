#!/usr/bin/perl -w
use strict;
die "perl $0 <input file> <output file>" unless @ARGV == 2;
my ($input,$output) = @ARGV;
open IN,"$input" or die;
open OUT,">$output" or die;
while(<IN>)
{
	chomp;
	my @line = split /\t/,$_;
	my $line1 = join "\t",@line[1..4];
	my $line2 = join "\t",@line[5..$#line];
	print OUT "$line[0]\t$line2\t$line1\n";
}
close IN;
close OUT;
	
