#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <dir contain the editing level file> <output dir>" unless @ARGV == 2;
my($dir,$outdir) = @ARGV;
my @files = glob("$dir/*/editing_level.txt");
open OUT, ">$outdir/editing_level.txt" or die;
foreach my $file(@files)
{
	open IN,"$file" or die;
	while(<IN>)
	{
		chomp;
		print OUT "$_\n";
	}
	close IN;
}
system("Rscript $Bin/editing_level.R -argument $outdir/editing_level.txt,$outdir/editing_level");
