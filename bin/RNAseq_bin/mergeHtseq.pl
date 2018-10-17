#!/usr/bin/perl

=pod
description: merge all samples' htseq results(raw dead count) to a single file;
author: Yu tong
       	yutong@decodegenomics.com
created date: 20140304
modified date: 
=cut

use strict;
use warnings;
use File::Basename qw(dirname basename);

my $usage = << "USAGE";
description: merge all samples' Htseq results (raw dead count) to a single file;

usage: perl $0 <indir> <control names> <case names> <outname prefix> <outdir>
USAGE

my ($indir,$control,$case,$outname,$outdir) = @ARGV;
die $usage if (!defined $indir or !defined $outname or !defined $control or !defined $case);

if($control =~ /,/ || $case =~ /,/)
{
        open OUT,">$outdir/$outname.samp.list" or die;
}
if($control =~ /,/)
{
        my @control = split /,/,$control;
        foreach my $name(@control)
        {
                print OUT "control\t$name\n";
               # $controlfile .= "$dir/$name/RSEM.genes.results\t";
        }
}
if($case =~ /,/)
{
        my @case= split /,/,$case;
        foreach my $name(@case)
        {
                print OUT  "case\t$name\n";
                #$casefile .="$dir/$name/RSEM.genes.results\t";
        }
}
close OUT;


my $header = "GeneID";
my $desc = "";
my (@samples, %results, %descs);
my $samples = $control . "," . $case;
@samples = split /,/,$samples;
$outname ||= join "_",@samples;
foreach my $name (@samples) {
	my $file = "$indir/$name.rawCount.txt";

	&showLog("read file $file");
	$header .= "\t$name";
	open GENE, "< $file" or die $!;
	while (<GENE>) {
		chomp;
		my ($id,$count) = split /\t/, $_;
		next if ($id =~ /^__/);
		$results{$id}{$name} = $count;
	}
	close GENE;
}

&showLog("output");
open OUT, "> $outdir/$outname.rawCount.xls" or die $!;
print OUT "$header\n";
for my $gene (keys %results) {
	print OUT $gene;
	for (@samples) {
		if (exists $results{$gene}{$_}) {
			print OUT "\t$results{$gene}{$_}";
		} else {
			print "wrong: the $_ not have the $gene,please check!!\n";
		}
	}
	print OUT "\n";
}

&showLog("done");

exit 0;

sub showLog {
	my ($info) = @_;
	my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
