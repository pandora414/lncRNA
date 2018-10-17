#!/usr/bin/perl -w
use strict;
use File::Basename;
use FindBin qw($Bin);
die "perl $0 <gene2tr file> <eFPKM file> <sampleName> <gene number file>" unless @ARGV ==    4;
my $id = shift;
my $in = shift;
my $samp = shift;
my $out = shift;
my (%num,%hash);
my @binname;
open ID,"$id" or die;
open IN,"$in" or die;
open OUT,">$out" or die;
while(<ID>)
{
	next if (/^#/ || /^$/);
	my ($gene,$tr) = split /\t/,$_;
	$gene =~ s/\s//;
	$tr =~ s/\s//;
	$hash{$tr} = $gene;
	
}
while(<IN>)
{
	chomp;
	if (/^#/)
	{
		chomp;
		$_ =~ s/%//g;
		@binname = (split /\t/,$_)[6..55];
		
		next;
	}
	my $name = (split /\t/,$_)[3];
	my $gene = $hash{$name};
	#print "$gene\n";
	my @fpkm = (split /\t/,$_)[6..55];
	for(my $i = 0;$i <= $#binname;$i++)
	{
		if (exists $num{$binname[$i]}{$hash{$name}})
		{
			$num{$binname[$i]}{$hash{$name}} = $num{$binname[$i]}{$hash{$name}} + $fpkm[$i];
		}
		else {
			$num{$binname[$i]}{$hash{$name}} = $fpkm[$i];
		}
	}
}
foreach my $step (sort {$a <=> $b} keys %num)
{
	my $genenum=0;
	foreach my $trid (keys %{$num{$step}})
	{
		if ($num{$step}{$trid} > 0)
		{
			$genenum ++;
		}
	}
	print OUT "$step\t$genenum\n";
}
close IN;
close OUT;
my $dir = dirname($out);
my $pdf = "$dir". "/" . "$samp.saturation.pdf";
system ("R --slave --vanilla --args \"$out\" $samp $pdf < $Bin/saturationAnalysis.R");	
