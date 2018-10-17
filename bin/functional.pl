#!/usr/bin/perl -w

=pod
description: functional analysis, including Cluster, GO, Pathway, Network
author: Zhang Fangxian, zhangfx@genomics.cn
created date: 20090807
modified date: 20110119, 20101127, 20100430, 20100401, 20100222, 20091211, 20091205, 20090923, 20090914, 20090907, 20090906, 20090903, 20090823, 20090821, 20090820, 20090814, 20090813, 20090811, 20090810
=cut

use strict;
use Getopt::Long;
use FindBin '$Bin';
use File::Basename qw(dirname basename);
use File::Path 'mkpath';
use Cwd 'abs_path';

my ($clusterFlag, $indir, $condition, $fdr, $log2, $inter, $union, $g, $e, $m);
my ($goFlag, $glist, $gldir, $sdir, $species);
my ($pathwayFlag, $input, $type, $blast_out, $blast, $evalue, $rank, $komap, $bg, $diff);
my ($networkFlag, $taxid);
my ($outdir, $help);

GetOptions(
	"cluster"     => \$clusterFlag,
	"indir:s"     => \$indir,
	"condition:s" => \$condition,
	"fdr:f"       => \$fdr,
	"log2:f"      => \$log2,
	"inter"       => \$inter,
	"union"       => \$union,
	"g:i"         => \$g,
	"e:i"         => \$e,
	"m:s"         => \$m,

	"go"          => \$goFlag,
	"glist:s"     => \$glist,
	"gldir:s"     => \$gldir,
	"sdir:s"      => \$sdir,
	"species:s"   => \$species,

	"pathway"     => \$pathwayFlag,
	"input:s"     => \$input,
	"type:s"      => \$type,
	"blastout:s"  => \$blast_out,
	"blast:s"     => \$blast,
	"evalue:f"    => \$evalue,
	"rank:i"      => \$rank,
	"komap:s"     => \$komap,
	"bg:s"        => \$bg,
	"diff:s"      =>\$diff,

	"network"     => \$networkFlag,
	"taxid:s"     => \$taxid,

	"outdir:s"    => \$outdir,
	"help|?"      => \$help,
);
$indir ||= ".";
$fdr = 0.001 if (!defined $fdr);
$log2 = 1 if (!defined $log2);
$log2 = abs($log2);
$g = 7 if (!defined $g);
$e = 7 if (!defined $e);
$m ||= 'a';
$evalue = 1e-5 if (!defined $evalue);
$rank = 5 if (!defined $rank);
$outdir ||= ".";

$indir = abs_path($indir);
$outdir = abs_path($outdir);

# tools
my $cluster = "perl $Bin/cluster.pl";
my $go = "perl $Bin/go.pl";
my $pathway = "perl $Bin/kobas_pl_noFt.pl";
my $network = "perl $Bin/network.pl";

sub usage {
	die << "USAGE";
description: functional analysis, including Cluster, GO, Pathway, Network
usage: perl $0 [options]
options:
	-cluster            flag for Cluster
	-indir <path>       input directory, containing results of solexa-mRNAtag_pipeline.pl, default is current directory "."
	-condition <str> *  compare condition, prefix of *.DiffGeneExp.xls files, separated by comma ","
	-fdr <float>        ignore if fdr greater than this, default is 0.001
	-log2 <float>       ignore if abs(log2) belongs to partition (-abs(this), abs(this)), default is 1
	-inter              flag for intersect
	-union              flag for union
	-g [0 .. 8]: Specifies the distance measure for gene clustering
		0: No gene clustering
		1: Uncentered correlation
		2: Pearson correlation
		3: Uncentered correlation, absolute value
		4: Pearson correlation, absolute value
		5: Spearman's rank correlation
		6: Kendall's tau
		7: Euclidean distance
		8: City-block distance
		(default: 7)
	-e [0 .. 8]: Specifies the distance measure for microarray clustering
		0: No clustering
		1: Uncentered correlation
		2: Pearson correlation
		3: Uncentered correlation, absolute value
		4: Pearson correlation, absolute value
		5: Spearman's rank correlation
		6: Kendall's tau
		7: Euclidean distance
		8: City-block distance
		(default: 7)
	-m [msca]: Specifies which hierarchical clustering method to use
		m: Pairwise complete-linkage
		s: Pairwise single-linkage
		c: Pairwise centroid-linkage
		a: Pairwise average-linkage
		(default: a)

	-go                 flag for GO
	-glist <str>        glist files, separated by comma ",", with higher priority than -gldir
	-gldir <path>       directory, containging .glist files, processing all glist files in the directory, with lower priority than -glist
	-sdir <path>        species directory, parent path of .F, .C, .P and .conf files
	-species <str> *    species, prefix of .[FCP] files

	-pathway            flag for Pathway
	-input <file> *     id list file or FASTA file
	-type <str> *       input type (fasta, blastout, seqids), can specify db by the format of 'seqids:db' from (ncbigene, ncbigi, uniprot) when using seqids option
	-blastout <file>    output of blast in format -m 8
	-blast <str>        blastall program
	-evalue <float>     expectation value, default is 1e-5
	-rank <int>         rank cutoff for valid hit from blastall, default is 5
	-komap <file>       ko_map.tab file
	-bg <str>           background KO file, or 3 small-caption letters for species
	-diff <file> *      *.DiffGeneExpFilter.xls, result of solexa-mRNAtag_pipeline.pl

	-network            flag for Network
	-indir <path>       input directory, containing results of solexa-mRNAtag_pipeline.pl, default is current directory "."
	-taxid <int> *      NCBI Taxonomy ID

	-outdir <path>      output directory, default is current directory "."

	-help|?             help information

e.g.:
	perl $0 -cluster -indir ./ -condition AvsB,AvsC -fdr 0.001 -log2 1 -inter -outdir ./
	perl $0 -go -glist AvsB.glist,AvsC.glist -species human -outdir ./
	perl $0 -go -gldir ./ -species human -outdir ./
	perl $0 -go -gldir ./ -sdir dir -species species -outdir ./
	perl $0 -pathway -input idFile -type seqids:ncbigene -bg hsa -diff diffFile -outdir ./
	pelr $0 -network -indir ./ -taxid 9606 -outdir ./
	combination of the above
USAGE
}

if ((!defined $clusterFlag && !defined $goFlag && !defined $pathwayFlag && !defined $networkFlag) || defined $help) {
	&usage();
}
if (defined $clusterFlag && (!defined $condition || (!defined $inter && !defined $union))) {
	&usage();
}
if (defined $goFlag && ((!defined $glist && !defined $gldir) || !defined $species)) {
	&usage();
}
if (defined $pathwayFlag && (!defined $input || !defined $type || (defined $type && $type eq "blastout" && !defined $blast_out) || !defined $diff)) {
	&usage();
}

if (defined $pathwayFlag) {
# check type
	if (index("fasta, blastout, seqids:ncbigene, seqids:ncbigi, seqids:uniprot,", $type . ",") == -1) {
		die "option -type must be one of the following: fasta, blastout, seqids:ncbigene, seqids:ncbigi, seqids:uniprot\n";
	}

# check blast
	if (defined $blast && index("blastn, blastp, blastx, tblastn, tblastx,", $blast . ",") == -1) {
		die "option -blast must be one of the following: blastn, blastp, blastx, tblastn, tblastx\n";
	}
}

if (defined $clusterFlag) {
	my $cmd = "$cluster -diffdir $indir -condition $condition -fdr $fdr -log2 $log2 -g $g -e $e -m $m";
	$cmd .= " -inter" if (defined $inter);
	$cmd .= " -union" if (defined $union);
	$cmd .= " -outdir $outdir/pattern" if (defined $outdir);
	print "Cluster...\n";
	system($cmd);
}

if (defined $goFlag) {
	if (!-d "$outdir/GO") {
		mkpath "$outdir/GO" or die $!;
	}
	if (defined $glist) {
		my @files = split /,/, $glist;
		my $exit = 0;
		for (@files) {
			if (!-f $_) {
				warn "file $_ not exists\n";
				$exit = 1;
			}
		}
		if ($exit == 1) {
			exit 1;
		}
		$gldir = "$outdir/gltmp_$$";
		mkpath $gldir or die $!;
		for (@files) {
			symlink $_, "$gldir/" . basename($_);
		}
	}
	my $cmd = "$go -gldir $gldir";
	$cmd .= " -sdir $sdir" if (defined $sdir);
	$cmd .= " -species $species -outdir $outdir/GO";
	print "GO...\n";
	system($cmd);
	if (defined $glist) {
		unlink glob "$gldir/*";
		rmdir $gldir;
	}
}

if (defined $pathwayFlag) {
	if (!-d "$outdir/pathway") {
		mkpath "$outdir/pathway" or die $!;
	}
	my $cmd = "$pathway -input $input -type $type -outdir $outdir/pathway -diff $diff";
	$cmd .= " -komap $komap" if (defined $komap);
	$cmd .= " -bg $bg" if (defined $bg);
	$cmd .= " -evalue $evalue -rank $rank" if ($type eq "fasta");
	$cmd .= " -blast $blast" if (defined $blast);
	$cmd .= " -blastout $blast_out -evalue $evalue -rank $rank" if ($type eq "blstout");
	print "Pathway...\n";
	system($cmd);
}

if (defined $networkFlag) {
	if (!-d "$outdir/network") {
		mkpath "$outdir/network" or die $!;
	}
	print "Network...\n";
	system("$network -indir $indir -taxid $taxid -outdir $outdir/network");
}

exit 0;
