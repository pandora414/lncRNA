#!/usr/bin/perl -w
use strict;
die "perl $0 <merged gtf> <merged gtf stat>" unless @ARGV == 2;
my ($gtf,$stat) = @ARGV;
my (%gene,%trans);
open GTF,"$gtf" or die;
open STAT,">$stat" or die;
while(<GTF>)
{
	chomp;
	next if(/^#/ || /^$/);
	$_ =~/gene_id "(\S+)"; transcript_id "(\S+)";/;
	$gene{$1} = 1;
	$trans{$2} = 1;
}
close GTF;
my($genenum,$transnum);
foreach my $gene(keys %gene)
{
	$genenum ++;
}
foreach my $tran(keys %trans)
{
	$transnum ++;
}
print STAT "Iterm\tgeneNum\tTransNum\n";
print STAT "Merge\t$genenum\t$transnum\n";
close STAT;
