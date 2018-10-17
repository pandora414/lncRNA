#!/usr/bin/perl -w
use strict;
die "usage: perl $0  hg19.genome.fa  transcript.bed  OutFile\n" if(@ARGV != 3);
my %hash = ();
open my $in,"$ARGV[0]";
$/=">"; <$in>; $/="\n";
while(<$in>)
{
     chomp;
     my $chr = $_;
	$chr =~ s/\s.*//;
     $/=">";
     my $seq = <$in>;
     chomp($seq);
     $/="\n";
     $seq =~ s/\s*//g;
     $seq =~ s/\n//g;
     $hash{$chr} = $seq;
}
close($in);

open  $in,"$ARGV[1]";
open OUT,">$ARGV[2]";
while(<$in>)
{
     chomp; next if(/^\s*$/ || /^#/);
     my @t = split;
     my ($transcript,$chr,$start,$strand,$blocks) = ($t[3],$t[0],$t[1],$t[5],$t[9]);
	chop ($t[10]);
	chop ($t[11]);
     my $seq;
     if ($blocks > 1)
       {
           my @len = split (/,/,$t[10]);
           my @start = split (/,/,$t[11]);
           for (0..$#len)
             {
                 my $string = substr($hash{$chr},($start+$start[$_]),$len[$_]);
                 $seq .= $string;
             }
           if ($strand eq "-") 
             {
                $seq = &reverse_seq($seq);
             }
          print OUT ">$transcript\n$seq\n";
        }
      else {
             my $string = substr($hash{$chr},$t[1],$t[10]);
             if ($strand eq "-")
               {
                  $string = &reverse_seq($string);
                }
             print OUT ">$transcript\n$string\n";
       }
}
close ($in);
close OUT;
sub reverse_seq 
  {
        my $str = shift;
        $str = reverse ($str);
        $str =~ tr/ATCGatcg/TAGCtagc/;
        return $str;
  }

             
