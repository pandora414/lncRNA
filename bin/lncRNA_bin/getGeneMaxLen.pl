#!/usr/bin/perl -w
use strict;
die "perl $0 <length file> <gene2tr or tr2gene file> <out put>" unless @ARGV == 3;
my ($len,$tr2gene,$out) = @ARGV;
my (%hash,%name);
open TR2GENE,"$tr2gene" or die;
while(<TR2GENE>)
{
	chomp;
	my ($gene,$tr) = split /\t/,$_;
	$name{$tr} = $gene;
}
open IN,"$len" or die;
open OUT,">$out" or die;
while(<IN>)
{
        chomp;
        next if(/Transcript/ || /length/);
        my ($trID,$len) = split /\t/,$_;
        if (exists $hash{$name{$trID}})
        {
             if ($hash{$name{$trID}} < $len)
             {
                  $hash{$name{$trID}} = $len;
             }else {
                    next;
              }
        }else{
		 $hash{$name{$trID}} = $len;                                                                                                                                            }
}
foreach my $gene (keys %hash)
{
	print OUT "$gene\t$hash{$gene}\n";
}
close IN;
close OUT;
                                                                                                                                                                                     
