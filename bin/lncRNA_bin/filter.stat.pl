#!/usr/bin/perl -w
use strict;
die "perl $0 <filter dir> <output table>" unless @ARGV == 2;
my ($dir,$table) = @ARGV;
my %hash;
my @files = glob("$dir/*/Basic_Statistics_of_Sequencing_Quality.txt");
my @adp = glob("$dir/*/Statistics_of_Filtered_Reads.txt");
foreach my $adapter (@adp)
{
	my $sample = (split /\//,$adapter)[-2];
	my $line = `grep 'Reads with adapter' $adapter`;
	$line =~ m/\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%/;
	$hash{$sample} = $1;
}
open OUT,">$table" or die;
print OUT "Sample\tReadLen\tRawReads\tCleanReads\tCleanBase(G)\tRawQ20(%)\tCleanQ20(%)\tRawQ30(%)\tCleanQ30(%)\tRawGC(%)\tCleanGC(%)\tAdapter(%)\n";
foreach my $samp (@files)
{
	my $name = (split /\//,$samp)[-2];
	my $readlen = `grep 'Read length' $samp`;
	$readlen =~ m/\s+(\d+)\s+/;
	my $len = $1;
	my $raw = `grep 'Total number of reads' $samp`;
	$raw =~ m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $rawreads1 = $1; my $rawreads=$rawreads1 * 2;
	my $cleanreads1 = $3; my $cleanreads = $cleanreads1 * 2;
	my $base = `grep 'Total number of bases' $samp`;
	$base =~ m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $cleanbase = $3 * 2;
	my $rawbase = $1 + $5;
	my $CBase = `grep 'Number of base C' $samp`;
	$CBase=~ m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $c1 = $3; my $c2 = $7; my $c = $c1 + $c2;
	my $rawC = $1 + $5;
	my $GBase = `grep 'Number of base G' $samp`;
	$GBase =~ m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $g1 = $3; my $g2 = $7; my $g = $g1 +$g2;
	my $rawG = $1 + $5;
	my $Q20 = `grep 'quality value of 20 or higher' $samp`;
	$Q20 =~ m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $q20 = $3 + $7; my $q20_ratio = $q20*100/$cleanbase; my $q20_p = sprintf("%.2f",$q20_ratio);
	my $raw_q20 = $1 + $5; my $raw_q20_ratio = $raw_q20*100/$rawbase; my $raw_q20_p = sprintf("%.2f",$raw_q20_ratio);
	my $Q30 = `grep ' quality value of 30 or higher' $samp`;
	$Q30 =~  m/\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)\s+(\d+)\s+\((.*)%\)/;
	my $q30 = $3 + $7; my $q30_ratio = $q30*100/$cleanbase; my $q30_p = sprintf("%.2f",$q30_ratio);
	my $raw_q30 = $1 + $5;my $raw_q30_ratio = $raw_q30*100/$rawbase; my $raw_q30_p = sprintf("%.2f",$raw_q30_ratio);
	my $gc = ($g+$c)*100/$cleanbase;
	my $cleanbaseG = $cleanbase/(10**9);
	my $rawGC = ($rawC + $rawG)*100/$rawbase;
	my $rawGC_p = sprintf("%.2f",$rawGC);
	my $cleanbase_p = sprintf("%.2f",$cleanbaseG);
	my $gc_p = sprintf("%.2f",$gc);
	my $adpter_ratio = $hash{$name}*100/$rawreads; my $adpter_p = sprintf("%.2f",$adpter_ratio);
	print OUT "$name\t$len\t$rawreads\t$cleanreads\t$cleanbase_p\t$raw_q20_p\t$q20_p\t$raw_q30_p\t$q30_p\t$rawGC_p\t$gc_p\t$adpter_p\n";
}
close OUT;
	
