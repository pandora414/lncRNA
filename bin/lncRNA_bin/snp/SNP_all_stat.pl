#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl <SNP stat dir> <dir output> <region distribution file>" unless @ARGV == 3;
my ($dir,$outdir,$region) = @ARGV;
my %hash;
my (@samples,@term);
my $flag = 1;
my @files = glob("$dir/*snp.all_stat");
foreach my $file(@files)
{
	my $name = (split /\//,$file)[-1];
	$name =~ s/\.snp\.all_stat//;
	my $samp;
	$flag ++;
	open IN,"$file" or die;
	while(<IN>)
	{
		chomp;
		if(/Sample/)
		{
			$samp = (split /\t/,$_)[1];
			push @samples,$samp;
			next;
		}
		my @array = split /\t/,$_;
		$hash{$array[0]}{$samp} = $array[1];
		if($flag == 2)
		{
			push @term,$array[0];
		}
	}
	close IN;
}
open OUT,">$outdir/SNP.all.stat.xls" or die;
my $head = join "\t",@samples;
print OUT "Sample\t$head\n";
foreach my $term(@term)
{
	print OUT "$term";
	foreach my $sample (@samples)
	{
		print OUT "\t$hash{$term}{$sample}";
	}
	print OUT "\n";
}
close OUT;
my %num;
foreach my $sampname(@samples)
{
	#my ($cds,$utr5,$utr3,$up_down,$intron,$intergenic,$ncRNA);
	$num{$sampname}{"CDS"} = $hash{"Exonic"}{$sampname} + $hash{"Exonic and splicing"}{$sampname};
	$num{$sampname}{"NcRNA"} = $hash{"NcRNA"}{$sampname};
	$num{$sampname}{"UTR5"} = $hash{"UTR5"}{$sampname} + $hash{"UTR5 and UTR3"}{$sampname}; 
	$num{$sampname}{"UTR3"} = $hash{"UTR3"}{$sampname} + $hash{"UTR5 and UTR3"}{$sampname};
	$num{$sampname}{"Intronic"} = $hash{"Intronic"}{$sampname};
	$num{$sampname}{"Intergenic"} = $hash{"Intergenic"}{$sampname};
	$num{$sampname}{"Up/Down"} = $hash{"Upstream"}{$sampname} + $hash{"Downstream"}{$sampname} + $hash{"Upstream and downstream"}{$sampname};
}
my @region=("CDS","UTR5","UTR3","Intronic","NcRNA","Up/Down","Intergenic");
open OUT2,">$region" or die;
print OUT2 "Sample\tGenome_Region\tNumber\n";
foreach my $sampid (@samples)
{
#	print OUT2 "$sampid";
	foreach my $reg (@region)
	{
		print OUT2 "$sampid\t$reg\t$num{$sampid}{$reg}\n";
	}
}
close OUT2;
system ("Rscript $Bin/snp_region.plot.R --argument $region,$outdir/SNP.region");
