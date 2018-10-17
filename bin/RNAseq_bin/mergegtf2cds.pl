#!/usr/bin/perl
use strict;
use warnings;

die "\nperl $0 <merge.gtf> <geome> <out>\n\n" unless(@ARGV==3);
my ($gtf,$genome,$out)=@ARGV;

my (%loc,%seq,%strand,%cds);

open G, "$genome" or die;
$/=">";<G>;$/="\n";
while(<G>)
{
	my $id=$1 if(/(\S+)/);
	$/=">";
	$seq{$id}=<G>;
	chomp $seq{$id};
	$seq{$id}=~s/\s+//g;
	$seq{$id}=uc $seq{$id};
	$/="\n";
}
close G;

open F, "$gtf" or die;
while(<F>)
{
	chomp;
	next if(/^#/ || /^$/);
	my @sp=split(/\t/,$_);
	if($_ ne "")
	{
		if($sp[8]=~/; transcript_id "(\S+)";/)
		{
			my $trid=$1;
			$cds{$trid}.=substr($seq{$sp[0]},$sp[3]-1,$sp[4]-$sp[3]+1);
			$strand{$trid}=$sp[6];
		}
	}
}
close F;

open OUT,">$out" or die;
foreach my $id(sort keys %cds)
{
	if($strand{$id} eq "-")
	{
		$cds{$id}=~tr/ATCG/TAGC/;
		$cds{$id}=reverse $cds{$id};
	}
#	if(!($cds{$id}=~/^ATG/))
#	{
#		print "$id Not complete, without begin 'ATG' in '$id'.\n";
#	}
#	if( !($cds{$id}=~/TAA$/ || $cds{$id}=~/TAG$/ || $cds{$id}=~/TGA$/))
#	{
#		print "$id Not complete, without end 'TAA/TAG/TGA' in '$id'.\n";
#	}
	my @csp=split(//,$cds{$id});
	$cds{$id}="";
	for(my $i=0;$i<@csp;$i++)
	{
		$cds{$id}.=$csp[$i];
		$cds{$id}.="\n" if(($i+1)%60==0);##60 base be one line
	}
	$cds{$id}=~s/\n$//;
	print OUT "\>$id\n$cds{$id}\n";
}
close OUT;
