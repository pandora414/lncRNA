#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <input rpkm file> <group name> <output dir>" unless @ARGV == 3;
my($rpkm,$name,$outdir) = @ARGV;
system("Rscript $Bin/heatmap.R -argument $rpkm,$outdir/$name");

