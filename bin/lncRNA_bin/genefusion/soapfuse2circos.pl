#!/usr/bin/perl -w
use strict;
die "perl $0 <soapfuse result> <file used by circos> <gene list used by circos>" unless @ARGV == 3;
my ($in,$out,$list) = @ARGV;
my %hash;
open IN,"$in" or die;
open OUT1,">$out" or die;
open OUT2,">$list" or die;
while(<IN>)
{
	chomp;
	next if(/^up_gene/ || /^$/);
	my ($upgene,$upchr,$upstrand,$uppos,$downgene,$downchr,$downstrand,$downpos,$sreads,$jreads) = (split /\t/,$_)[0,1,2,3,5,6,7,8,10,11];
	$upchr =~ s/chr/hs/;
	$downchr =~ s/chr/hs/;
	my $reads = $sreads + $jreads;
	my($upend,$downend,$thickness);
	if($reads >= 20)
	{
		$thickness = 5;
	}elsif($reads >= 10 && $reads <20)
	{
		$thickness = 3;
	}else{
		$thickness = 1;
	}
	if($upstrand eq "+")
	{
		$upend = $uppos - 300;
		#print OUT "$upchr\t$upend\t$uppos";
	}else{
		$upend = $uppos + 300;
		#print OUT "$upchr\t$upend\t$uppos";
	}
	if($downstrand eq "+")
	{
		$downend = $downpos + 300;
	}else{
		$downend = $downpos - 300;
	}
	print OUT1 "$upchr\t$upend\t$uppos\t$downchr\t$downpos\t$downend\tthickness=$thickness\n";
	my $up = "$upchr\t$upend\t$uppos";
	$hash{$up} = $upgene;
	my $down = "$downchr\t$downpos\t$downend";
	$hash{$down} = $downgene;
	
}
close OUT1;
foreach  my $pos (keys %hash)
{
	print OUT2 "$pos\t$hash{$pos}\n";
}
close OUT2;
