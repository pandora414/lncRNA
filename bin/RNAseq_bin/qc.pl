#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Getopt::Long;

my $usage="Program Description\n".
        "qc.pl\n".
        "This program is used to generate the qc results from SOAPnuke output files.\n".

"Options:\n".
"       -help           help info;\n".
"       -indir          input dir,contain the SOAPunke output files of each sample,default ".";\n".
#"       -samples        SOAPnuke samples,one or more samples,use comma(,) delimited.eg: sampA,sampB,sampC;\n".
#"       -outdir         output dir,can be same as indir,default: ".";\n".
"Usage:\n".
"       perl qc.pl -indir .\n";

#my ($help,$indir,$samples,$outdir);
my ($help,$indir);

GetOptions(
        "help!" => \$help,
        "indir=s" => \$indir,
#        "samples=s" => \$samples,
#        "outdir=s" => \$outdir,
);
die $usage if(defined $help || ! defined $indir);
$indir ||=".";
#$outdir ||= ".";
#my @samp=split /,/,$samples;

unless (glob "$indir/*/Basic_Statistics_of_Sequencing_Quality.txt")
{
	print "\nERROR: the file 'Basic_Statistics_of_Sequencing_Quality.txt' was absent, please check!\n\n";exit;
}

unless (glob "$indir/*/Statistics_of_Filtered_Reads.txt")
{
	print "\nERROR: the file 'Statistics_of_Filtered_Reads.txt' was absent, please check!\n\n";exit;
}


my @files = glob("$indir/*/Basic_Statistics_of_Sequencing_Quality.txt");
my @adp = glob("$indir/*/Statistics_of_Filtered_Reads.txt");
my (%adapt,%lowQ,%N);

foreach my $adapter (@adp)
{
	my $sample = (split /\//,$adapter)[-2];
	my $read_adp = `grep 'Reads with adapter' $adapter`;
	$read_adp =~ m/\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%/;
	$adapt{$sample} = $1;
	my $read_low = `grep 'Reads with low quality' $adapter`;
	$read_low =~ m/\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%/;
	$lowQ{$sample} = $1;
	my $read_N = `grep 'Read with n rate exceed' $adapter`;
	$read_N =~ m/\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%\s+(\d+)\s+(.*)%/;
	$N{$sample} = $1;
}

open OUT,">$indir/all.filter.stat.xls" or die;
print OUT "Sample\tReadLen\tRawReads\tCleanReads\tRawBase(G)\tCleanBase(G)\tRawQ20(%)\tCleanQ20(%)\tRawQ30(%)\tCleanQ30(%)\tRawGC(%)\tCleanGC(%)\tAdapter(%)\n"; #edited by qkun 20170227
foreach my $samp (@files)
{
	my $name = (split /\//,$samp)[-2];
	open OA, ">$indir/$name/$name.qc.txt" or die;

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
	my $rawbaseG = $rawbase/(10**9); #edited by qkun 20170227
	my $rawGC = ($rawC + $rawG)*100/$rawbase;
	my $rawGC_p = sprintf("%.2f",$rawGC);
	my $cleanbase_p = sprintf("%.2f",$cleanbaseG);
	my $rawbase_p = sprintf("%.2f",$rawbaseG); #edited by qkun 20170227
	my $gc_p = sprintf("%.2f",$gc);
	my $adpter_ratio = $adapt{$name}*100/$rawreads; my $adpter_p = sprintf("%.2f",$adpter_ratio);
	print OUT "$name\t$len\t$rawreads\t$cleanreads\t$rawbase_p\t$cleanbase_p\t$raw_q20_p\t$q20_p\t$raw_q30_p\t$q30_p\t$rawGC_p\t$gc_p\t$adpter_p\n"; #edited by qkun 20170227

	my $cleanp = ($cleanreads/$rawreads)*100;
	my $A = sprintf "%0.2f%%",$cleanp;
	my $A1 = "Clean Reads($cleanreads,$A)";
	print OA "$A1\t$cleanreads\n";
	my $adapterp = ($adapt{$name}/$rawreads)*100;
	my $B = sprintf "%0.2f%%",$adapterp;
	my $B1 = "Adapter($adapt{$name},$B)";
	print OA "$B1\t$adapt{$name}\n";
	my $lowp = ($lowQ{$name}/$rawreads)*100;
	my $C = sprintf "%0.2f%%",$lowp;
	my $C1 = "Low Quality($lowQ{$name},$C)";
	print OA "$C1\t$lowQ{$name}\n";
	my $np = ($N{$name}/$rawreads)*100;
	my $D = sprintf "%0.2f%%",$np;
	my $D1 = "Containing N($N{$name},$D)";
	print OA "$D1\t$N{$name}\n";
	close OA;

	system("Rscript $Bin/qc.Rscript --args -o $indir/$name/$name.qc.txt,$name,$indir/$name/$name.qc.pdf,$indir/$name/$name.qc.png")
}
close OUT;

__END__