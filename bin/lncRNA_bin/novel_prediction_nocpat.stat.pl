#!/usr/bin/perl -w
use strict;
die "perl $0 <stat file> <stat table> <cutoff value> <novel lncRNA file>" unless @ARGV == 3;
my($stat,$table,$out) = @ARGV;
my(%cat);
my ($total,$nc_t,$nr_t,$pfam_t,$cpc_t);
my @cat = ("j","i","o","u","x");
my @term= ("le200","ncRNA","Nr","Pfam","cpc");
foreach my $c(@cat)
{
	foreach my $col (@term)
	{
		$cat{$c}{$col} = 0;
	}
}

open STAT,"$stat" or die;
open TAB,">$table" or die;
open OUT,">$out" or die;
while(<STAT>)
{
	chomp;
	if(/Transcript/){
		print OUT "$_\n";
		next;
	}
	my ($trans,$gene,$cat,$chr,$nc,$nr,$pfam,$cpc) = (split /\t/,$_)[0,1,2,3,8,9,10,11];
	$cat{$cat}{"le200"} ++; $total++;
	if($nc ne "no") { $cat{$cat}{"ncRNA"} ++; $nc_t ++;} 
	if($nr ne "no") { $cat{$cat}{"Nr"} ++;$nr_t ++; }
	if($pfam ne "no") {$cat{$cat}{"Pfam"} ++;$pfam_t++;}
#	if($orf <= 300) {$cat{$cat}{"ORF"} ++;$orf_t ++;}
#	if($cpat < $cpat_cutoff) {$cat{$cat}{"cpat"} ++;$cpat_t++;}
	if($cpc eq "noncoding") {$cat{$cat}{"cpc"} ++;$cpc_t++;}
	if(($nr eq "no") && ($pfam eq "no") && ($cpc eq "noncoding"))
	{
		print OUT "$_\n";
	}
}
close STAT;
#my @cat = ("j","i","o","u","x");
#my @term= ("le200","ncRNA","ORF","Nr","Pfam","cpat","cpc");
my $head = join "\t",@term;
print TAB "Catergory\t$head\n";
foreach my $c(@cat)
{
	print TAB "$c";
	foreach my $col (@term)
	{
		if (exists $cat{$c}{$col})
		{
			print TAB "\t$cat{$c}{$col}";
		}else{
			print "ERROR:the $cat{$c}{$col} not exists,please check!\n";
		}
	}
	print TAB "\n";
}
print TAB "Total\t$total\t$nc_t\t$nr_t\t$pfam_t\t$cpc_t\n";
close TAB;
close OUT;
