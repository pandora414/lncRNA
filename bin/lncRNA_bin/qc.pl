#! /usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib "$Bin";

die "This script to generate the fq filter picture\n
usage: perl $0 <Basic_Statistics_of_Sequencing_Quality.txt> <Statistics_of_Filtered_Reads.txt> <samplename> <out dir>" unless @ARGV==4;
my($basicstat,$filtstat,$samplename,$out) = @ARGV;
open OUT ,">$out/$samplename.qc.txt" or die;
my $line1 =  `grep 'Total number of reads' $basicstat`;
my $rawreads = (split /\t+/,$line1)[1];
my $rawreads1 = (split /\s+/,$rawreads)[0];

$rawreads1 = 2*$rawreads1;
my $cleanreads = (split /\t+/,$line1)[2];
my $cleanreads1 = (split /\s+/,$cleanreads)[0];
$cleanreads1 = 2*$cleanreads1;

my $cleanp = ($cleanreads1/$rawreads1)*100;
my $a = sprintf "%0.2f%%",$cleanp;
my $a1 = "Clean Reads($cleanreads1,$a)";
print OUT "$a1\t$cleanreads1\n";

	
my $line2 = `grep 'Reads with adapter' $filtstat`;
my $adapter = (split /\t+/,$line2)[1];
$adapter =~ s/\s+//;
my $line3 = `grep 'Reads with low quality' $filtstat`;
my $lowreads = (split /\t+/,$line3)[1];
$lowreads =~ s/\s+//;
my $line4 = `grep 'Read with n rate exceed' $filtstat`;
my $nreads = (split /\t+/,$line4)[1];
$nreads =~ s/\s+//;
my $adapterp = ($adapter/$rawreads1)*100;
my $lowp = ($lowreads/$rawreads1)*100;
my $np = ($nreads/$rawreads1)*100;
my $b = sprintf "%0.2f%%",$adapterp;
my $b1 = "Adapter($adapter,$b)";
my $c = sprintf "%0.2f%%",$lowp;
my $c1 = "Low Quality($lowreads,$c)";
my $d = sprintf "%0.2f%%",$np;
my $d1 = "Containing N($nreads,$d)";

print OUT "$b1\t$adapter\n";
print OUT "$c1\t$lowreads\n";
print OUT "$d1\t$nreads\n";

close OUT;
system("Rscript $Bin/qc.Rscript --args -o $out/$samplename.qc.txt,$samplename,$out/$samplename.qc.pdf,$out/$samplename.qc.png")
