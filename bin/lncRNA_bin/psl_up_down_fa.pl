#!/usr/bin/perl -w
use strict;
die "usage: perl $0  hg19.genome.fa   pslfile length UPseq downseq\n" if(@ARGV != 5);
my %hash = ();
my ($genome,$psl,$len,$up,$down) = @ARGV;
open GENOME,"$genome";
$/=">"; <GENOME>; $/="\n";
while(<GENOME>)
{
     chomp;
     my $id = $_;
	my $chr = (split /\s/,$_)[0];
	
     $/=">";
     my $seq = <GENOME>;
     chomp($seq);
     $/="\n";
     $seq =~ s/\s*//g;
     $seq =~ s/\n//g;
     $hash{$chr} = $seq;
}
close GENOME;

open  PSL,"$psl" or die ;
open UPSEQ,">$up" or die;
open DOWN,">$down" or die;
while(<PSL>)
{
     chomp; next if(/^\s*$/ || /^#/ || /version/ || /^--/ || /match/);
     my @t = split /\t/,$_;
     my ($chr,$start,$end,$strand) = ($t[13],$t[15],$t[16],$t[8]);
     my $seq;
     if ($strand eq "-")
	{	
		my $uppos = $end + $len;
		my $up = &reverse_seq(substr($hash{$chr},$end,$len));
		print UPSEQ ">$chr:$strand:$end-$uppos\n$up\n";
		my $downpos = $start-$len;
		my $down = &reverse_seq(substr($hash{$chr},$downpos,$len));
		print DOWN ">$chr:$strand:$downpos-$start\n$down\n";
	}
	else {
		my $pos = $start-$len;
		my $up = substr($hash{$chr},$pos,$len);
     		print UPSEQ ">$chr:$strand:$pos-$start\n$up\n";
		my $downpos = $end + $len;
		my $down = substr($hash{$chr},$end,$len);
		print DOWN ">$chr:$strand:$end-$downpos\n$down\n";
	}
}
close PSL;
close UPSEQ;
close DOWN;
sub reverse_seq 
  {
        my $str = shift;
        $str = reverse ($str);
        $str =~ tr/ATCGatcg/TAGCtagc/;
        return $str;
  }

             
