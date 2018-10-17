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
description: merge all samples rpkm file to a single file;

usage: perl $0 <indir> <samplesnames> <outdir> <out file name>
USAGE

my ($indir,$samples, $outdir,$outname) = @ARGV;
die $usage if (!defined $indir or !defined $samples or !defined $outdir);

my $header = "GeneID";
my $desc = "";
my (@samples, %results, %descs);
@samples = split /,/,$samples;
$outname ||= join "_",@samples;
foreach my $name (@samples) {
	my $file = "$indir/$name.rpkm.xls";

	&showLog("read file $file");
	$header .= "\t$name";
	open GENE, "< $file" or die $!;
	while (<GENE>) {
		chomp;
		next if(/GeneID/ || /length/);
		my ($id,$rpkm) = (split /\t/, $_)[0,3];
		next if ($id =~ /^__/);
		$results{$id}{$name} = $rpkm;
	}
	close GENE;
}

&showLog("output");
open OUT, "> $outdir/$outname.rpkm.xls" or die $!;
print OUT "$header\n";
for my $gene (keys %results) {
	#print OUT $gene;
	my $total;my @rpkm;
	for (@samples) {
		if (exists $results{$gene}{$_}) {
			$total += $results{$gene}{$_};
			push @rpkm,$results{$gene}{$_};
			#print OUT "\t$results{$gene}{$_}";
		} else {
			print "wrong: the $_ not have the $gene,please check!!\n";
		}
	}
	my $value = join "\t",@rpkm;
	if($total >0){
		print OUT "$gene\t$value\n";
	}else {
		next;
	}
}

&showLog("done");

exit 0;

sub showLog {
	my ($info) = @_;
	my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
