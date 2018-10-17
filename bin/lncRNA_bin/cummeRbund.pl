#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib "$Bin";

use Getopt::Long;

my ($help,$indir,$fdr,$control,$case,$outdir);
GetOptions (
	"help" => \$help,
	"indir=s" => \$indir,
	"fdr=s" => \$fdr,
	"control=s" => \$control,
	"case=s" => \$case,
	"outdir=s" => \$outdir,
);
my $usage =<<INFO;
Usage:
	perl $0 [Options]

OPtions:
	-help		help info;
	-indir		input directory,contained you cuffdiff results.
	-fdr		the significant level you want used.
	-control	the control sample name;
	-case		the case sample name;
	-outdir		the output directory;
eg:
	perl cummeRbund.pl -indir cuffdiff -control sampA -case sampB -outdir ./outdir
INFO

die $usage if (defined $help || !defined $indir || !defined $control || !defined $case);
$fdr = 0.05 if (!defined $fdr);
print "$fdr\n";
$outdir ||= ".";

system("R --slave --vanilla --args $indir $fdr $control $case $outdir < $Bin/cummeRbund.R");
