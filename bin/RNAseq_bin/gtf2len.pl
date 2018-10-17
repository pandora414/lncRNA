#!/usr/bin/perl
use strict;
use warnings;

die "perl $0 <gtf file> <transcript length>" unless @ARGV == 2;
my ($gtf,$len) = @ARGV;
open BED,"$gtf" or die;
open OUT,">$len" or die;
while(<BED>)
{
        chomp;
#        my ($trID,$block,$size) = (split /\t/,$_)[3,9,10];
        my @sp =split /\t/,$_;
        if ($sp[2]=~/gene|\_gene/)
        {
            my $attr=pop @sp;
            if($attr=~/gene_id "(\S+)";/)
            {
                    my $gid=$1;
                    my $length=$sp[4]-$sp[3]+1;
                    print OUT "$gid\t$length\n";
            }
            else
            {
	            print "the gtf file is not complete";exit;
            }
        }
}
close BED;
close OUT;
