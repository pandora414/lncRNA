#!/usr/bin/perl
##2008-11-15

use strict;
use File::Basename qw(basename dirname);
use Getopt::Long;
use Cwd 'abs_path';

#Instructions and advisions of using this program

my $usage = <<USE;
Usage: $0 [options] 
options:
	-infile		GeneDiffExp file, default is "."
	-outdir		output directory, default is [indir]
	-FDR		FDR (default: 0.1)
	-fold		change fold (default: 1)
	-R_path		R path, default is /opt/blc/genome/bin
USE


#################-Main-Function-#################
my ($INFILE, $OUTDIR, $FDR, $FOLD, $RPATH, $HELP);

GetOptions(
	"infile:s" => \$INFILE,
	"outdir:s" => \$OUTDIR,
	"FDR:f" => \$FDR, 
	"fold:f" => \$FOLD,
	"R_path:s" => \$RPATH,
	"help!" => \$HELP
);
die $usage if (!defined $INFILE || defined $HELP);

$INFILE ||= ".";
$OUTDIR ||= $INFILE;
$RPATH ||=  "/DG/programs/beta/rel/R/bin";
my @legends = ("Gene", "DEGs");
$FDR ||= 0.1;
#$FOLD ||= 1;
#my $log2 = &log2($FOLD);
my $log2 = $FOLD;
my $head = `grep "Gene" $INFILE`;
my ($control,$case) = (split /\t/,$head)[1,2];
#$control =~ s/baseMean_//;
#$case =~ s/baseMean_//;
open IN,"$INFILE" or die;
open OUT,">$OUTDIR/$control" . "vs$case.before_diff\_Gene\_figure" or die;
while(<IN>)
{
	chomp;
	my ($id,$con_rpkm,$case_rpkm,$fc,$padj) = (split /\t/,$_)[0,1,2,3,6];
	if(/GeneID/)
	{
		print OUT "$con_rpkm\t$case_rpkm\t$fc\t$padj\n";
		next;
	}
#	if($con_rpkm == 0)
#	{
		$con_rpkm += 0.01;
#	}
#	if ($case_rpkm == 0)
#	{
		$case_rpkm += 0.01;
#	}
	

print OUT "$con_rpkm\t$case_rpkm\t$fc\t$padj\n";
}
#system("awk -F '\\t' 'OFS = \"\\t\" {print \$3, \$4, \$6, \$8}' $INFILE > $OUTDIR/$control" . "vs$case.before_diff\_Gene\_figure");

	my $output = "$OUTDIR/$control-VS-$case.GeneExp.pdf";
	my $rsh = <<RSH;
data <- read.table("$OUTDIR/$control\vs$case.before_diff\_Gene\_figure", sep = "\\t", skip = 1)
pdf(file = "$output",height=6,width=6.3,pointsize=15)
plot(log2(data\$V1[abs(data\$V3) < $log2 | data\$V4 > $FDR]), log2(data\$V2[abs(data\$V3) < $log2 | data\$V4 > $FDR]), xlab = "$control log2(RPKM+0.01)", ylab = "$case log2(RPKM+0.01)", col = "gray", main = "Gene Expression Level of $control vs $case", pch = ".", cex = 2, cex.main=.9)

x <- data\$V1[abs(data\$V3) >= $log2 & data\$V4 <= $FDR]
y <- data\$V2[abs(data\$V3) >= $log2 & data\$V4 <= $FDR]
for (i in 1 : length(x)) {
	if (y[i] > x[i])
		points(log10(x[i]), log10(y[i]), col = "red", pch = ".", cex = 2)
	else
		points(log10(x[i]), log10(y[i]), col = "blue", pch = ".", cex = 2)
}

legend("topleft",cex=0.7,c("up-regulated $legends[0]", "down-regulated $legends[0]", "Not $legends[1]"), fill = c("red", "blue", "gray"), xjust = 0, title = paste("FDR <= ", $FDR))
dev.off()
RSH

	open IN, "> $OUTDIR/$control" . "vs$case.diffGene\_figure.R" || die $0;
	print IN $rsh;
	close IN;

	system("$RPATH/Rscript $OUTDIR/$control" . "vs$case.diffGene\_figure.R");
	system("convert $OUTDIR/$control-VS-$case.GeneExp.pdf $OUTDIR/$control-VS-$case.GeneExp.png");
#	system("rm $OUTDIR/$control" . "vs$case.before_diff\_Gene\_figure");
#	system("rm $OUTDIR/$control" . "vs$case.diffGene\_figure.R");

exit 0;

sub log2 {
	my $n = shift;
	return log($n)/log(2);
}
