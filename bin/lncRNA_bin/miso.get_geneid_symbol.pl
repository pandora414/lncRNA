#!/usr/bin/perl -w
use strict;
die "perl $0 <annotation file(gene.gff)> <filter event file(LN_vs_LP.miso_bf.filtered)> <out put file>" unless @ARGV ==3;
my ($annot,$event,$out) = @ARGV;
my (%ref_id,%ensemble,%symbol);
open ANNOT,"$annot" or die;
while(<ANNOT>)
{
	chomp;
	next if(/^#/);
	my ($chr,$type,$attr) = (split /\t/,$_)[0,1,8];
	my ($name,$refseq_id,$ensg_id,$gsymbol)=(split /;/,$attr)[0,2,3,4];
	if($name=~/Name=(.*)/)
	{
		$name = $1;
	}
	else {
		print "Error:The Name:$name not have prefix Name=\n";
	}
	if($refseq_id =~ /refseq_id=(.*)/)
	{
		$refseq_id = $1;
	}
	else {
		print "Error:The refseq_id:$refseq_id not have prefix refseq_id=\n";
	}
	if($ensg_id=~/ensg_id=(.*)/)
	{
		$ensg_id = $1;
	}
	else {
		print "Error:The ensg_id:$ensg_id not have prefix ensg_id=\n";
	}
	if($gsymbol =~ /gsymbol=(.*)/)
	{
		$gsymbol = $1;
	}
	else {
		print "Error:The gsymbol:$gsymbol not have prefix gsymbol=\n";
	}
	$ref_id{$name} = $refseq_id;
	$ensemble{$name} = $ensg_id;
	$symbol{$name} = $gsymbol;
}
close ANNOT;
open EVENT,"$event" or die;
open OUT,">$out" or die;
while(<EVENT>)
{
	chomp;
	next if(/^#/);
	if(/event_name/)
	{
		print OUT "$_\tsymbol\tensg_id\trefseq_id\n";
		next;
	}
	my @arry = split /\t/,$_;
	if(exists $symbol{$arry[0]})
	{
		print OUT "$_\t$symbol{$arry[0]}\t$ensemble{$arry[0]}\t$ref_id{$arry[0]}\n";
	}
	else {
		print "Err:the $arry[0] not have symbol\n";
	}
}
close EVENT;
close OUT;

