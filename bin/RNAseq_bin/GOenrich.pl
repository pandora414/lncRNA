#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Getopt::Long;

my $usage="Program Description\n".
        "GOenrich.pl\n".
        "This program is used to generate the GOenrichment results for diff output files.\n".

"Options:\n".
"       -help           help info;\n".
"       -GOdir          input dir,contain the GO annotation files ,default ".";\n".
"       -GOprefix          the prefix of GO annotation files, eg. Trinity.fasta ;\n".
"       -glistdir        the dir of sigDiff glist file, require abs path;\n".
"       -diff	        the prefix of sigDiff glist/xls file;\n".
"       -outdir         output dir;\n".
"       -groupname         groupname;\n".
"       -go         goclass;\n".
"Usage:\n".
"       perl GOenrich.pl -GOdir . -GOprefix Trinity.fasta -glistdir . -diff diff -go goclass -groupname groupA -outdir .\n";

my ($help, $godir, $prefix, $gdir, $diff, $go, $group, $outdir);
GetOptions(
        "help!" => \$help,
        "GOdir=s" => \$godir,
        "GOprefix=s" => \$prefix,
        "groupname=s" => \$group,
        "glistdir=s" => \$gdir,
        "diff=s" => \$diff,
        "go=s" => \$go,
        "outdir=s" => \$outdir,
);
die $usage if(defined $help || ! defined $godir || ! defined $gdir);
$outdir ||=".";
$go ||="/DG/home/qkun/project/denovo/go.class";

system("Rscript $Bin/GOenrich.R --args -o $godir,$prefix,$gdir/$diff.sigDiff.glist,$group,$go\.sim,$outdir >$outdir/$group.GOenrich.log");
system("perl /DG/home/yut/pipeline/RNA-seq/pipeline_2.0/functional/drawGO.pl -indir $gdir -diff $diff -go $godir/$prefix -outdir $outdir -goclass $go");
