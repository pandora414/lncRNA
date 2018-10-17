#!usr/bin/perl -w
use strict;
use File::Basename;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <species><miso directory> <AS type (eg:SE or A3SS)> <mapped reads(Tophat dir)> <sashimi out dir>" unless @ARGV == 5;
my($species,$miso,$type,$tophat,$outdir) = @ARGV;
$type ||= "SE";
$tophat ||= "$miso/../tophat";
my %hash;
my $miso_database = "/DG/home/yut/soft/misopy-0.5.2/annot/$species/SE";
#my @files = glob("$miso/cmp_$type/*_vs_*/bayes-factors/*_vs_*.miso_bf");
my @sig = glob("$miso/cmp_$type/*_vs_*.miso_bf.filtered");
my $event;
my $name = basename $sig[0];
$name=~ s/\.miso_bf\.filtered//;
my ($samp1,$samp2) = split /_vs_/,$name;
open IN,"$sig[0]" or die;
while(<IN>)
{
	chomp;
	next if (/event_name/ || /^$/);
	$event = (split /\t/,$_)[0];
	last;
}
my $samp1_read1 = `grep 'Mapped' $tophat/$samp1/align_summary.txt |head -1`;
$samp1_read1 =~ /(\d+) \(/; my $samp1_r1 = $1;
my $samp1_read2 = `grep 'Mapped' $tophat/$samp1/align_summary.txt |tail -1`;
$samp1_read2 =~ /(\d+) \(/; my $samp1_r2 = $1;
my $samp1_read = $samp1_r1 + $samp1_r2;
my $samp2_read1 = `grep 'Mapped' $tophat/$samp2/align_summary.txt |head -1`;
$samp2_read1  =~ /(\d+) \(/; my $samp2_r1 = $1;
my $samp2_read2 = `grep 'Mapped' $tophat/$samp2/align_summary.txt |tail -1`;
$samp2_read2 =~ /(\d+) \(/; my $samp2_r2 = $1;
my $samp2_read = $samp2_r1 + $samp2_r2;

system("ln -s $tophat/$samp1/accepted_hits.bam $outdir/$samp1.bam");
system("ln -s $tophat/$samp1/accepted_hits.bam.bai $outdir/$samp1.bam.bai");
system("ln -s $tophat/$samp2/accepted_hits.bam $outdir/$samp2.bam");
system("ln -s $tophat/$samp2/accepted_hits.bam.bai $outdir/$samp2.bam.bai");

open SET,">$outdir/sashimi_plot_settings.txt" or die;
print SET "[data]
# directory where BAM files are
bam_prefix = $outdir
# directory where MISO output is
miso_prefix =$miso

bam_files = [
     \"$samp1.bam\",
     \"$samp2.bam\"]

miso_files = [
      \"$samp1\",
      \"$samp2\"]

[plotting]
# Dimensions of figure to be plotted (in inches)
fig_width = 7
fig_height = 5
# Factor to scale down introns and exons by
intron_scale = 30
exon_scale = 4
# Whether to use a log scale or not when plotting
logged = False
font_size = 6

bar_posteriors = False

# Max y-axis
ymax = 150

# Axis tick marks
nyticks = 3
nxticks = 4

# Whether to show axis labels
show_ylabel = True
show_xlabel = True

# Whether to plot posterior distributions inferred by MISO
show_posteriors = True

# Whether to plot the number of reads in each junction
number_junctions = True

resolution = .5
posterior_bins = 40
gene_posterior_ratio = 5

# List of colors for read denisites of each sample
colors = [
    \"#CC0011\",
    \"#FF8800\"]

# Number of mapped reads in each sample
# (Used to normalize the read density for RPKM calculation)
coverages = [
     $samp1_read,
     $samp2_read]

# Bar color for Bayes factor distribution
# plots (--plot-bf-dist)
# Paint them blue
bar_color = \"b\"

# Bayes factors thresholds to use for --plot-bf-dist
bf_thresholds = [0, 1, 2, 5, 10, 20]

##
## Names of colors for plotting
##
# \"b\" for blue
# \"k\" for black
# \"r\" for red
# \"g\" for green
#
# Hex colors are accepted too.
";

system("python /DG/home/yut/soft/misopy-0.5.2/misopy/sashimi_plot/sashimi_plot.py --plot-event \"$event\" $miso_database $outdir/sashimi_plot_settings.txt --output-dir $outdir ");
system("cp $outdir/$event.pdf $outdir/$samp1\_$samp2.SE.sashimiPlot.pdf");
system("convert -density 400 $outdir/$samp1\_$samp2.SE.sashimiPlot.pdf -resize 80% $outdir/$samp1\_$samp2.SE.sashimiPlot.png");
