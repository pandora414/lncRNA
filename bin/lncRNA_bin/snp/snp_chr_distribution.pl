#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
use Text::CSV;
die "perl $0 <dir contain the snp annot file> <out dir> " unless @ARGV == 2;
my ($dir,$outdir) = @ARGV;
#my $csv = Text::CSV->new();
#my $status;
my (%chr,%chrname);

my @name;
my @files = glob("$dir/*_multianno.csv");
my @chr=qw(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY chrM other);
open OUT,">$outdir/snp_dis.plot.txt" or die;
print OUT "Chr\tSample\tcount\n";
foreach my $file(@files)
{
	my $name = (split /\//,$file)[-1];
	$name =~ s/\.\w+_multianno\.csv//;
	push @name,$name;
	my $csv = Text::CSV->new();
	my $status;
	open IN,"$file" or die;
	while(<IN>)
	{
		chomp;
		next if(/Chr/ || /^#/ || /^$/);
		$status = $csv->parse($_);
		my @line = $csv->fields();
		#$chrname{$line[0]} = 1;
		if($line[0] ~~ @chr)
		{
			$chr{$line[0]}{$name} ++;
			$chrname{$line[0]} = 1;
		}else{
			$chr{"other"}{$name} ++;
			$chrname{"other"}=1;
		}
	}
	close IN;
	foreach my $chr(@chr)
	{
		if(exists $chrname{$chr})
		{
			print OUT "$chr\t$name\t$chr{$chr}{$name}\n";
		}
	}
}
open DIS,">$outdir/snp_dis.xls" or die;
my $sample = join "\t",@name;
print DIS "Chr\t$sample\n";
foreach my $chrom (@chr)
{
	if(exists $chrname{$chrom})
	{
		print DIS "$chrom";
		foreach my $samp (@name)
		{
			print DIS "\t$chr{$chrom}{$samp}";
		}
		print DIS "\n";
	}
}
close OUT;
close DIS;
system("Rscript $Bin/snp_dis.R --argument $outdir/snp_dis.plot.txt,$outdir/snp_dis");
