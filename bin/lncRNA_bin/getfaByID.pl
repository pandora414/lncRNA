#!/usr/bin/perl -w
use strict;
die "perl $0 <fa file> <seq id list> <ID column> <out put file>" unless @ARGV == 4;
my ($fa,$list,$col,$out) = @ARGV;
my %hash;
open IN,"$fa" or die;
$/ = ">";
<IN>;
while(<IN>)
{
	chomp;
	my @arr = split /\n/,$_;
	my $id = shift @arr;
	my $seq = join "\n",@arr;
	$hash{$id} = $seq;
}
close IN;
$/ = "\n";

open LIST,"$list" or die;
open OUT,">$out" or die;
while(<LIST>)
{
	chomp;
	next if(/^#/ || /ID/ || /logFC/ || /geneID/ || /Transcript/);
	my $name = (split /\t/,$_)[$col-1];
	if(exists $hash{$name})
	{
		print OUT ">$name\n$hash{$name}\n";
	}
	else {
		print "error: the $name not in fasta file\n";
	}
}
close LIST;
close OUT;
