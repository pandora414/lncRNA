#!/usr/bin/perl -w
use strict;
die "perl $0 <genome.fa> <site list> <fa used for logo>" unless @ARGV == 3;
my ($all,$list,$fa) = @ARGV;
my %hash;
open GENOME,"$all" or die;
open LIST,"$list" or die;
open FA,">$fa" or die;
$/=">"; <GENOME>;
while(<GENOME>)
{
     chomp;
     my @arr = split /\n/,$_;
     my $chr = shift @arr;
     my $seq = join "",@arr;

     $hash{$chr} = $seq;
}
close GENOME;
$/ = "\n";
while(<LIST>)
{
	chomp;
	next if(/Chr/ || /^#/);
	my($ch,$p,$strand,$type) = (split /\t/,$_)[0,1,5,9];
	my $start = $p - 5 - 1;
	my $end = $p + 5;
#	print "$ch\n";
	if($type =~ /AG/)
	{
		my $seq = substr($hash{$ch},$start,11);
		if($strand == 0)
		{
			$seq = &complement($seq);
		}
	print FA ">$ch:$start\-$end:$strand\n$seq\n";
	}
}
close LIST;
close FA;

sub complement{
	my $seq=shift;
	$seq =~ tr/ATCGatcg/TAGCtagc/;
	$seq = reverse $seq;
	return $seq;
}
