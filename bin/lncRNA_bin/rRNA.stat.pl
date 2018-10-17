#!/usr/bin/perl -w
use strict;
die "perl $0 <filter stat>  <rRNA dir> <output table>" unless @ARGV == 3;
my ($filter,$dir,$table) = @ARGV;
my %hash;
open FILE, "$filter" or die;
while(<FILE>)
{
	chomp $_; 
	if(/Sample/)
	{
		next;
	}
	my @raw = split /\t/,$_;
	my $samplename = $raw[0];
	$hash{$samplename} = $raw[2];
}
close FILE;
my @files = glob("$dir/*.bam.rRNA.stat.txt");

open OUT,">$table" or die;
print OUT "Sample\trRNA_readsCount\tRatio\n";
foreach my $samp (@files)
{
        my $name0 = (split /\./,$samp)[0];
	my $name = (split /\//,$name0)[-1];
        my $line = `head -n 1 $samp`;
        $line =~ m/(\d+)\s+\+.*/;
        my $rRNA = $1;
	my $ratio = $1*100/$hash{$name};
	my $ratio2 = sprintf("%.4f",$ratio);
	print OUT "$name\t$rRNA\t$ratio2%\n";
}
close OUT;


