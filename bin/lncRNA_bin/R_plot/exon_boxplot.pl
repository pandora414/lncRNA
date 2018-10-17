#!/usr/bin/perl -w
use FindBin qw($Bin);
use lib "$Bin";
die "perl $0 <file names (bed format)> <names eg,protein,lincRNA,novel> <outdir>" unless @ARGV == 3;
my ($file,$names,$outdir) = @ARGV;
my (%hash);
my @file = split /,/,$file;
my @names = split /,/,$names;
for(my $i = 0; $i <=$#file;$i++)
{
	open IN,"< $file[$i]" or die;
	open OUT,">$outdir/$names[$i].exon.txt" or die;
	while(<IN>)
	{
		chomp;
		next if(/^#/ || /^$/);
		my ($gene,$num)=(split /\t/,$_)[3,9];
		print OUT "$num\n";
	}
	close IN;
	close OUT;
}

print "$outdir\n";
chdir "$outdir" or die;
system("Rscript $Bin/exon_boxplot.R --argument $names");

