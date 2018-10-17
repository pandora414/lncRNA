#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $usage="Program Description\n".
        "inner_distance_peak_statistic.pl\n".
        "This program is used to generate the inner distance results from inner_distance.py output files.\n".

"Options:\n".
"       -help           help info;\n".
"       -indir          input dir,contain the SOAPunke output files of each sample,default ".";\n".
"       -len			pair end length.eg: 150;\n".
"       -outdir         output dir,can be same as indir,default: ".";\n".
"Usage:\n".
"       perl qc.pl -indir . -outdir . -len 150 \n";

my ($help,$indir,$len,$outdir);

GetOptions(
        "help!" => \$help,
        "indir=s" => \$indir,
        "len=s" => \$len,
        "outdir=s" => \$outdir,
);
die $usage if(defined $help || ! defined $indir || ! defined $len || ! defined $outdir);
$indir ||=".";
$outdir ||= ".";

unless (glob "$indir/*/*.inner_distance.stat")
{
	print "\nERROR: the file 'inner_distance.stat' was absent, please check!\n\n";exit;
}

my @files = glob("$indir/*/*.inner_distance.stat");

&showLog("output");
open OUT,">$outdir/all.insert.peak.xls" or die;
print OUT "Sample name\tPeak_InsertSize(bp)\n";
foreach my $samp (@files)
{
	&showLog("read file $samp");
	my $name = (split /\//,$samp)[-2];
	my $stat = `grep -v '^Name' $samp`;
	$stat =~ m/\s+(\S+)\s+(\S+)\s+(\S+)/;
	my $res=sprintf ("%.0f",$1+$len*2);
	print OUT "$name\t$res\n";
}
close OUT;

&showLog("done");

exit 0;

sub showLog 
	{
        my ($info) = @_;
        my @times = localtime; # sec, min, hour, day, month, year
        print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
	}

