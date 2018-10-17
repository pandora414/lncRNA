#!/usr/bin/perl -w
use strict;
use Cwd qw(abs_path);
use Getopt::Long;
=head1 
Program Description:
	get_jioux_gtf.pl
	This program is used to extract j,i,o,u,x category transcript from cuffcompare results.
	
Options:
	-cmp2ref	cuffcompare to reference gtf results;

	-category	you defined category type,eg:'j,i,o,u';

	-ingtf		input gtf file,eg:your cuffmerge results;

	-outdir		output dir name,default ".";
	-name		output file name,default "extract.merge.gtf";

Usage:
	perl get_jioux_gtf.pl -cmp2ref cmp2ref.merged.gtf.tmap -category j,i,o,u,x -ingtf merged.gtf -outdir outputdir -name jioux.merge.gtf

=cut
my ($help,$cmp2ref,$code,$gtf,$out,$name);
GetOptions(
	"help!" => \$help,
	"cmp2ref=s" => \$cmp2ref,
	"category=s" => \$code,
	"ingtf=s" => \$gtf,
	"outdir=s" => \$out,
	"name=s" => \$name,
);
die `pod2text $0` if (defined $help || !defined $cmp2ref || !defined $code || !defined $gtf);
$out ||= ".";
$name ||="extract.merge.gtf";
$out = abs_path($out);
[-d $out] || mkdir $out || die "can't generate the outdir:$!";
my (%hash,%gene,@code);
if ($code =~ /,/)
{
	@code = split /,/,$code;
}
else {
	push @code,$code;
}

open TMAP,"$cmp2ref" or die $!;
open LIST,">$out/$name.cat" or die;
while(<TMAP>)
{
	chomp;
	next if(/^#/ || /ref_gene_id/);
	my ($class,$id)=(split /\t/,$_)[3,4];
	my ($geneid,$trid) = (split /\|/,$id)[0,1];
	$geneid =~ s/q1://;
	if ($class ~~ @code)
	{
		$hash{$trid}{$class}= 1;
		$gene{$geneid}{$class} = 1;
		print LIST "$trid\t$geneid\t$class\n";
	}
	else {
		next;
	}
}
my ($trnum,$genenum,%trnum,%genenum,$totaltr,$totalgene);
foreach my $id(keys %hash)
{
	foreach my $cat (@code)
	{
		if(exists $hash{$id}{$cat})
		{
			$trnum{$cat} += 1;
			$totaltr ++;
		}
	}
}
foreach my $id(keys %gene)
{
	foreach my $cat (@code)
	{
		if(exists $gene{$id}{$cat})
		{	$genenum{$cat} += 1;
			$totalgene ++;
		}
	}
}
open STAT,">$out/$name.stat" or die;
foreach my $cat (@code)
{
	print STAT "$cat\t$genenum{$cat}\t$trnum{$cat}\n";
}
print STAT "total\t$totalgene\t$totaltr\n";

open GTF,"$gtf" or die;
open OUT,">$out/$name" or die;
while (<GTF>)
{
	chomp;
	my $attr = (split /\t/,$_)[8];
	if ($attr =~ /transcript_id "(\w+)"; exon_number/)
	{
		my $transid = $1;
		if (exists $hash{$transid})
		{
			 print OUT "$_\n";
		}
		else {
			next;
		}
	}
	else {
		print "error: the $attr have no transcript_id,please check!\n";
	}
}
close TMAP;
close GTF;
close OUT;
	
	
