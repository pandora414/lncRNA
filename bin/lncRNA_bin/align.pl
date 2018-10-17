#! /usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib "$Bin";

die "usage: perl align.pl read_distribution.out samplename ./" unless @ARGV==3;
my($read_distribution,$samplename,$out)= @ARGV;
open OUT ,">$out/$samplename.align.txt" or die;

my $line1 = `grep 'Total Tags' $read_distribution`;
my $line2 = `grep 'CDS_Exons' $read_distribution`;
my $line3 = `grep "5'UTR_Exons" $read_distribution`;
my $line4 = `grep "3'UTR_Exons" $read_distribution`;
my $line5 = `grep 'Introns' $read_distribution`;
my $line6 = `grep 'TSS_up_1kb' $read_distribution`;
my $line7 = `grep 'TSS_up_5kb' $read_distribution`;
my $line8 = `grep 'TSS_up_10kb' $read_distribution`;
my $line9 = `grep 'TES_down_1kb' $read_distribution`;
my $line10 = `grep 'TES_down_5kb' $read_distribution`;
my $line11 = `grep 'TES_down_10kb' $read_distribution`;

my $alltags = (split /\s+/,$line1)[2];
my $cdsexon = (split /\s+/,$line2)[2];
my $exon5 = (split /\s+/,$line3)[2];
my $exon3 = (split /\s+/,$line4)[2];
my $intron = (split /\s+/,$line5)[2];
my $up1 = (split /\s+/,$line6)[2];
my $up5 = (split /\s+/,$line7)[2];
my $up10 = (split /\s+/,$line8)[2];
my $down1 = (split /\s+/,$line9)[2];
my $down5 = (split /\s+/,$line10)[2];
my $down10 = (split /\s+/,$line11)[2];

my $utr = $exon5 + $exon3;
my $intergenic = $alltags - $cdsexon - $utr - $intron;

print OUT "CDS\t$cdsexon\n";
print OUT "UTR\t$utr\n";
print OUT "Intron\t$intron\n";
print OUT "Intergenic\t$intergenic\n";

close OUT;
#system("Rscript $Bin/align.Rscript --args -o $out/$samplename.align.txt,$samplename,$out/$samplename.readDistribution.pdf,$out/$samplename.readDistribution.png")
system(" R --slave <$Bin/align.Rscript --args -o $out/$samplename.align.txt,$samplename,$out/$samplename.readDistribution.pdf,$out/$samplename.readDistribution.png")
