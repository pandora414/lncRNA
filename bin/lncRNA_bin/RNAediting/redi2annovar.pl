#!/usr/bin/perl -w
use strict;
die "perl $0 <reditools resulst> <annovar input file>"  unless @ARGV == 2;
my ($in,$out) = @ARGV;
open IN,"$in" or die;
open OUT,">$out" or die;
while(<IN>)
{
	chomp;
	next if(/^$/ || /^#/ || /Region/);
	my @line = split /\t/,$_;
	my $alt = (split //,$line[7])[1];
	my $other = join "\t",@line[4..$#line];
	if($line[3]==0)
	{
		$line[2] = &subti($line[2]);
		$alt = &subti($alt);
	}
	#print OUT "$line[0]\t$line[1]\t$line[1]\t$line[2]\t$alt\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]\t$line[9]\n";
	print OUT "$line[0]\t$line[1]\t$line[1]\t$line[2]\t$alt\t$line[3]\t$other\n";
}
close IN;
close OUT;

sub subti{
	my $string = shift;
	$string =~ tr/ATCG/TAGC/;
	return $string;
}
