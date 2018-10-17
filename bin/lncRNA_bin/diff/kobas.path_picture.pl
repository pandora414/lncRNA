#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin";

my $usage = "20151029 produces a piceture of pathway enrichment analysis results.\n\n".
	    "\nusage: perl $0 -i <pathway enrichment analysis results> -n <sample name> -o <outdir>\n".
	"-i <file name>		pathway enrichment analysis results\n".
	"-n <sample name>	sample name or group name\n".
	"-o <outdir>   out put file directory,default '.'\n\n";
my ($h,$in,$name,$outdir);
GetOptions(
		"h!" => \$h,
		"i=s" => \$in,
		"n=s" => \$name,
		"o=s" => \$outdir,
);
die $usage if (defined $h || !defined $in || !defined $name);
$outdir ||= ".";
print "$in\n";
system (`Rscript $Bin/kobas.path_picture.R --args -o $in,$outdir/$name.kegg,$name >$outdir/$name.kegg.log`); 
