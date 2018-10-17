#!/usr/bin/perl -w
use strict;
die "perl $0 <bed file> <transcript length>" unless @ARGV == 2;
my ($bed,$len) = @ARGV;
open BED,"$bed" or die;
open OUT,">$len" or die;
while(<BED>)
{
	chomp;
	my ($trID,$block,$size) = (split /\t/,$_)[3,9,10];
	$trID =~ s/\s//;
	my $length = 0;
	if ($block < 2)
	{
		$size =~ s/,$//;
		$length = $size;
		print OUT "$trID\t$length\n";
	}else{
		my @len = split /,/,$size;
		foreach (@len)
		{
			$length += $_;
		}
		print OUT "$trID\t$length\n";
	}
}
close BED;
close OUT;
