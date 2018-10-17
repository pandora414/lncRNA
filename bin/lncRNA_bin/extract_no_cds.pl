#!/usr/bin/perl -w
use strict;
die "perl $0 <id file> <fa file> <output fa>" unless @ARGV == 3;
my $id = shift;
my $fa = shift;
my $out = shift;
my %hash;
open ID,"$id" or die;
while(<ID>)
{
	chomp;
	next if (/^#/ || /track name/);
	my $id = (split /\t/,$_)[0];
	$hash{$id} = 1;
}

close ID;
open FA,"$fa" or die;
open OUT,">$out" or die;
$/ = ">";
<FA>;
while(<FA>)
{
	chomp;
	my ($id,$seq)=split /\n/,$_; 
	print OUT ">$id\n$seq\n" unless (exists $hash{$id});
}
close FA;
close OUT;
