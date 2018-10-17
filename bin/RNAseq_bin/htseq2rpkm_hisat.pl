#!/usr/bin/perl -w
use strict;
die "\nperl $0 <Hisat summary file> <length file> <htseq file> <sample name> <rpkm file>\n\n" unless @ARGV == 5;
my($file,$len,$htseq,$name,$rpkm) = @ARGV;
my %hash;
open HT,"$htseq" or die;
open OUT,">$rpkm" or die;
my $line = `head -n 1 $file`;
$line=~ m/(\d+) reads;/;
my $reads = $1 ;
print "Paired reads is:$reads\n";

open LEN,"$len" or die;
while(<LEN>)
{
	chomp;
	my ($id,$length) = split /\t/,$_;
	$hash{$id} = $length;
}
close LEN;
print OUT "GeneID\t$name\_readNum\tlength\t$name\_rpkm\n";
while (<HT>)
{
	chomp;
	next if (/^__/);
	my ($name,$num) = split /\t/,$_;
	my $rpkm;
	if(exists $hash{$name})
	{
		$rpkm = $num*10**9/($reads * $hash{$name});
		print OUT "$name\t$num\t$hash{$name}\t$rpkm\n";
	}else{
		$rpkm = $num*10**9/($reads * 1000);
		print OUT "$name\t$num\t1000\t$rpkm\n";
	}
	#print OUT "$name\t$num\t$hash{$name}\t$rpkm\n";
}
close HT;
close OUT; 
