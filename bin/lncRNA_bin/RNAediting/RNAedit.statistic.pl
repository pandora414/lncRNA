#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <RNA edit filter results> <out dir> <sample name>" unless @ARGV == 3;
my ($in,$outdir,$name) = @ARGV;
my($total,$known);
my (%type,%pos,%rep);
my @type = ("AG","AC","AT","CA","CG","CT","GA","GC","GT","TA","TC","TG");
my @pos_type = ("CDS","intergenic","intronic","ncRNA","UTR3","UTR5");
my @rep_type = ("Alu","RepNonAlu","NonRep");
open IN,"$in" or die;
open OUT,">$outdir/$name.edit.xls" or die;
while(<IN>)
{
	chomp;
	if(/Chr/)
	{
		my @head = split /\t/,$_;
		pop @head;
		my $head1 = join "\t",@head[0..4];
		my $head2 = join "\t",@head[5..$#head];
		print OUT "$head1\tStrand\tCoverage-q25\tMeanQ\tBaseCount[A,C,G,T]\tAllSubs\tFrequency\tPvalue\tRepMask_feat\tRepMask_gid\tRepMask_tid\trefSeq_feat\trefSeq_gid\tRADAR_feat\t$head2\n";
		next;
	}
	my @line = split /\t/,$_;
	my $line1 = join "\t",@line[0..4];
	my $line2 = join "\t",@line[5..14];
	my $line3 = join "\t",@line[15..$#line];
	print OUT "$line1\t$line3\t$line2\n";
	$total ++;
	if($line[-1] =~ /RADAR/)
	{
		$known ++;
	}
#	my $type = "$line[3]" . "$line[4]";
	my $type = $line[19];
	$type{$type} ++;
	
	if($line[5] =~ /intronic/)
	{
		$pos{"intronic"} ++;
	}elsif($line[5] =~ /ncRNA/)
	{
		$pos{"ncRNA"} ++;
	}elsif($line[5] =~ /UTR3/)
	{
		$pos{"UTR3"} ++;
	}elsif($line[5] =~ /UTR5/)
	{
		$pos{"UTR5"} ++;
	}elsif($line[5] =~ /exonic/ || $line[5] =~ /splicing/)
	{
		$pos{"CDS"} ++;
	}elsif($line[5] =~ /intergenic/ || $line[5] =~ /downstream/ || $line[5] =~ /upstream/)
	{
		$pos{"intergenic"} ++;
	}else{
		print "warnings: there have other postion type in you file,please check!\n";
	}
	if($line[24] eq "-")
	{
		$rep{"NonRep"} ++;
	}elsif($line[25] =~ /Alu/)
	{
		$rep{"Alu"} ++;
	}else{
		$rep{"RepNonAlu"} ++;
	}
}
open TYPE,">$outdir/$name.edit.type.txt" or die;
open POS,">$outdir/$name.edit.pos.txt" or die;
open REP,">$outdir/$name.edit.rep.txt" or die;
my $known_ratio = sprintf("%.2f",$known*100/$total);
print TYPE "Iterm\tCount\tPercent\nTotal\t$total\t100\nKnown\t$known\t$known_ratio\n";
print POS "Iterm\tCount\tPercent(%)\n";
print REP "Iterm\tCount\tPercent(%)\n";
foreach my $key (@type)
{
	my $ratio = sprintf("%.2f",$type{$key}*100/$total);
	print TYPE "$key\t$type{$key}\t$ratio\n";
}
foreach my $p (@pos_type)
{
	my $ratio = sprintf("%.2f",$pos{$p}*100/$total);
	print POS "$p\t$pos{$p}\t$ratio\n";
}
foreach my $r (@rep_type)
{
	my $ratio = sprintf("%.2f",$rep{$r}*100/$total);
	print REP "$r\t$rep{$r}\t$ratio\n";
}
close OUT;
close TYPE;
close POS;
close REP;
system("Rscript $Bin/RNAedit.region.R -argument $outdir/$name.edit.pos.txt,$outdir/$name");
system("Rscript $Bin/RNAedit.type.R -argument $outdir/$name.edit.type.txt,$outdir/$name");
system("Rscript $Bin/RNAedit.repeat.R -argument $outdir/$name.edit.rep.txt,$outdir/$name");
