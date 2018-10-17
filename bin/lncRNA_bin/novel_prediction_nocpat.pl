#!/usr/bin/perl -w
use strict;
die "perl $0 <le200 BED> <cat file> <ncRNA blast> <transdecoder> <Nr blast> <CPAT> <CPC> <stat file>" unless @ARGV == 7;
my ($bed,$cat,$ncblast,$pfam,$nrblast,$cpc,$stat)= @ARGV;
my (%hash,%nc,%nr,%pfam,%cat,%cpc);
open BED,"$bed" or die;
open STAT,">$stat" or die;
print STAT "Transcript\tGene\tCat\tChr\tStart\tEnd\tExonNum\tStrand\tNcRNA\tNr\tPfam\tCPCclass\tCPCscore\n";
while(<BED>)
{
	chomp;
	next if (/^#/ || /^$/);
	my @arry = split /\t/,$_;
	my $value = join "\t",($arry[0],$arry[1],$arry[2],$arry[9],$arry[5]);
	$hash{$arry[3]} = $value;
}

open CAT,"$cat" or die;
while(<CAT>)
{
	chomp;
	next if (/^#/ || /^$/);
	my @arry = split /\t/,$_;
	$cat{$arry[0]} = "$arry[1]\t$arry[2]";
}
close CAT;
open NC,"$ncblast" or die $!;
while(<NC>)
{
	chomp;
	next if(/^#/ || /^$/);
	my @array = split /\t/,$_;
	$nc{$array[0]} = $array[4];
}
close NC;
open NR,"$nrblast" or die;
while(<NR>)
{
	chomp;
	next if (/^#/ || /^$/);
	my @arry = split /\t/,$_;
	$nr{$arry[0]} = $arry[4];
}
close NR;
open PFAM,"$pfam" or die;
while(<PFAM>)
{
	chomp;
	next if(/^#/ || /^$/);
	my @array = split /\s+/,$_;
	my $id = (split /\|/,$array[3])[0];
	$pfam{$id} = "yes";
}
close PFAM;
open CPC,"$cpc" or die;
while(<CPC>)
{
	chomp;
	next if(/^#/ || /^$/ || /mRNA_size/);
	my @array =split /\t/,$_;
	$cpc{$array[0]} = "$array[2]\t$array[3]";
}
close CPC;
foreach my $id (keys %hash)
{
	if(!exists $nc{$id})
	{
		$nc{$id} = "no";
	}
	if(!exists $nr{$id})
	{
		$nr{$id} = "no";
	}
	if(!exists $pfam{$id})
	{
		$pfam{$id} = "no";
	}
#	if(!exists $cpat{$id})
#	{	$cpat{$id} = "no\tno"; }
	if(!exists $cpc{$id}) 
	{	$cpc{$id} = "no\tno"; }
	print STAT "$id\t$cat{$id}\t$hash{$id}\t$nc{$id}\t$nr{$id}\t$pfam{$id}\t$cpc{$id}\n";
}
close STAT;
