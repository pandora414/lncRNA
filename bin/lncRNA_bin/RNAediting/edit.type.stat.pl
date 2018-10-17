#!/usr/bin/perl -w
use strict;
use File::Basename;
die "perl $0 <dir contain type stat file of each sample> <outputfile>" unless @ARGV == 2;
my($dir,$out) = @ARGV;
my %hash;
my @name;
my @files = glob("$dir/*/*.edit.type.txt");
foreach my $file(@files)
{
	my $name = basename $file;
	$name =~ s/\.edit\.type\.txt//;
	push @name,$name;
	open IN,"$file" or die;
	while(<IN>)
	{
		chomp;
		next if(/Iterm/ || /^#/ || /^$/);
		my ($term,$count,$per)=split /\t/,$_;
		$hash{$term}{$name} = "$count\t$per";
	}
	close IN;
}
open OUT,">$out" or die;
my @col = ("Total","Known","AG","AC","AT","CA","CG","CT","GA","GC","GT","TA","TC","TG");
#my $head = join "\t",@name;
print OUT "Iterm";
foreach my $samp(@name)
{
	print OUT "\t$samp\t$samp(%)";
}
print OUT "\n";

foreach my $col(@col)
{
	print OUT "$col";
	foreach my $samp(@name)
	{
		print OUT "\t$hash{$col}{$samp}";
	}
	print OUT "\n";
}
close OUT;

