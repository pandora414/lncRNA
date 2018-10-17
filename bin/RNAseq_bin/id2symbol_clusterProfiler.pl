#!/usr/bin/perl -w
use strict;
die "\nperl $0 <clusterProfiler enrich file> <colum number> <desc file> <output file>\n\n" unless @ARGV == 4;
my ($input,$col,$desc,$output) = @ARGV;
my %hash;
open IN,"$input" or die;
open DESC,"$desc" or die;
while(<DESC>)
{
	chomp;
	my ($id,$symbol,$name) =  (split /\t/,$_)[0,1,2];
	if ($symbol ne "-")
	{
		$hash{$id} = $symbol;
	}elsif ($name ne "-")
	{
		$hash{$id} = $name;
	}else{
		$hash{$id} = $id;
	}
}
close DESC;
open OUT,">$output" or die;
#print OUT "ID\tDescription\tGeneRatio\tBgRatio\tpvalue\tp.adjust\tqvalue\tgeneID\tCount\n";
while(<IN>)
{
	chomp;
	next if (/^$/ || /-------/);
	if (/^ID/ )
	{
		print OUT "$_\n";
		next;
	}
#	if(/^#Term/)
#	{
#		print OUT "#Term\tDatabase\tID\tInput number\tBackground number\tP-Value\tCorrected P-Value\tInputName\tInputID\tHyperlink\n";
#		next;
#	}
	my @names = ();
	my @arr = split /\t/,$_;
	my @ids = split /\//,$arr[$col-1];
	foreach my $id (@ids)
	{
		if (exists $hash{$id})
		{
			push (@names,$hash{$id});
		}else{
			push (@names,$id);
		}
	}
	my $names = join ",",@names;
	print OUT "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[4]\t$arr[5]\t$arr[6]\t$names\t$arr[8]\n";
}
close IN;
close OUT;
