#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $usage="Program Description\n".
        "rRNA_stat.pl\n".
        "This program is used to generate the rRNA map results from FASTQC abd Bowtie-rRNA output files.\n".

"Options:\n".
"       -help           help info;\n".
"       -indir          input dir, home directory containing the fastqc and rRNA output files of each sample,default ".";\n".
"       -samples        samples,one or more samples,use comma(,) delimited.eg: sampA,sampB,sampC;\n".
"       -outdir         output dir,can be same as indir,default: ".";\n".
"Usage:\n".
"       perl rRNA_stat.pl -indir . -samples sampA,sampB -outdir .\n";

my ($help,$indir,$samples,$outdir);

GetOptions(
        "help!" => \$help,
        "indir=s" => \$indir,
        "samples=s" => \$samples,
        "outdir=s" => \$outdir,
);
die $usage if(defined $help || ! defined $indir || ! defined $samples || ! defined $outdir);
#$indir ||=".";
my @samp=split /,/,$samples;
open OUT, ">$outdir/all.rRNA.stat" or die;
print OUT "Sample\tRawReads\tMap2rRNAReads\tRatio\n";
for(my $i=0;$i<@samp;$i++)
{
#	unless (glob "$indir/fastqc/$samp[$i]/*/fastqc_data.txt")
#	{
#			print "\nERROR: the file 'fastqc_data.txt' in $samp[$i] was absent, please check!\n\n";exit;
#	}
#
#	unless (-e "$indir/rRNA/$samp[$i].bam.rRNA.stat")
#	{
#			print "\nERROR: the file '$samp[$i].bam.rRNA.stat' was absent, please check!\n\n";exit;
#	}


	my @raw = glob("$indir/fastqc/$samp[$i]/*/fastqc_data.txt");
	my @rRNA = glob("$indir/rRNA/$samp[$i].bam.rRNA.stat");
	my $readsum=undef;
	my $map=undef;
	my $ratio=undef;
	foreach my $file (@raw)
	{
		print STDERR "read file: $file\n";
        my $line = `grep 'Total Sequences' $file`;
        my $count = (split /\s+/,$line)[-1];
		if($readsum && $readsum != $count)
		{
			print STDERR "left reads does not equal to right reads\n";
		}
		$readsum +=$count;
	}
	foreach my $list (@rRNA)
	{
		print STDERR "read file: $list\n";
        my $line = `grep 'in total' $list`;
        $map = (split /\s+/,$line)[0];
		my $ratiotmp=$map/$readsum*100;
		$ratio=sprintf("%.2f",$ratiotmp);
		print OUT "$samp[$i]\t$readsum\t$map\t$ratio\n";
	}

}
close OUT;