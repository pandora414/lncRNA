#! /usr/bin/perl -w
use strict;
use warnings;
use File::Basename qw(dirname basename);

die "usage:perl $0 <indir> <control names> <case names> <gtf> <outdir> <outname prefix> <output>" unless @ARGV==7;

my ($indir,$control,$case,$gtf,$outdir,$outname,$out) = @ARGV;
my @controltmp;
my @casetmp;
open OUT, ">$out" or die;
print OUT "python \/DG\/home\/wangy\/software\/rMATS.3.0.9\/RNASeq-MATS.py -b1 ";

if($control =~ /,/ )
{
	my @control = split /,/,$control;
	foreach my $name(@control)
	{
		my $controltmp = $indir."\/".$name."\/".$name.".bam";
		push (@controltmp, $controltmp);
	}
	my $controltmp2 = join ",",@controltmp;
	print OUT "$controltmp2";
}
else{
	my $controltmp3 = $indir."\/".$control."\/".$control.".bam";
	print OUT "$controltmp3";
}
print OUT " -b2 ";
if($case =~ /,/ )
{
        my @case = split /,/,$case;
        foreach my $name(@case)
        {
                my $casetmp = $indir."\/".$name."\/".$name.".bam";
        	push (@casetmp, $casetmp);
	}
	my $casetmp2 = join ",",@casetmp;
	print OUT "$casetmp2";
}
else{
	my $casetmp3 = $indir."\/".$case."\/".$case.".bam";
	print OUT "$casetmp3";
}
print OUT " -gtf $gtf -o $outdir\/$outname -t paired -len 150 -a 8 -c 0.0001 -analysis U";
close OUT;

