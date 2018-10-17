#!/usr/bin/perl -w
use strict;
die "perl $0 <le200 bed> <gtf file> <le200 stat>" unless @ARGV == 3;
my($bed,$gtf,$stat) = @ARGV;
my (%hash,%tr2gene,%gene,$trnum);
open BED,"$bed" or die;
while(<BED>)
{
	chomp;
	next if(/^#/);
	my $id = (split /\t/,$_)[3];
	$hash{$id} = 1;
	$trnum++;
}
close BED;
my ($genenum);
open GTF,"$gtf" or die;
open OUT,">$stat" or die;
while(<GTF>)
{
	chomp;
	my $attr = (split /\t/,$_)[8];
	$attr=~ /gene_id "(\w+)"; transcript_id "(\w+)";/;
	my $gene = $1;
	my $tr = $2;
	$tr2gene{$tr} = $gene;
	if(exists $hash{$tr})
	{
		$gene{$tr2gene{$tr}} = 1;
	}
}
foreach my $gene (keys %gene)
{
	$genenum ++;
}
print OUT "Iterm\tGeneNum\tTransnum\n";
print OUT "le200\t$genenum\t$trnum\n";
