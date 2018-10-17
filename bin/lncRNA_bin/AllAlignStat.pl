#!/usr/bin/perl

=pod
description: summarize all samples' gene expression
author: Du Shuai, dushuai@genomics.cn
        Zhang Fangxian, zhangfx@genomics.cn
created date: 20110127
modified date: 20110215
=cut

use strict;
use warnings;
use File::Basename qw(dirname basename);

my $usage = << "USAGE";
description: summarize all samples' gene expression
usage: perl $0 indir outdir
USAGE

my ($indir, $outdir) = @ARGV;
die $usage if (!defined $indir or !defined $outdir);

my $header = "Iterm";
my $desc = "";
my @term;
my (@samples, %results, %descs);
my @files = glob("$indir/*.align_summary.xls");
open FILE,"$files[0]" or die;
while(<FILE>){
	chomp;
	next if(/Iterm/);
	my $iterm = (split /\t/,$_)[0];
	push @term,$iterm;
}
	
for my $file (glob("$indir/*.align_summary.xls")) {
	my $keyname = basename($file);
	$keyname =~ s/\.align_summary\.xls$//;
	push @samples, $keyname;

	&showLog("read file $file");
	open GENE, "< $file" or die $!;

	my $temp = <GENE>;
	chomp $temp;
	my @tabs = split /\t/, $temp;
	$header .= "\t$tabs[1]"; # for (2);
	$desc = "\t$tabs[5]" if (@tabs == 6);

	while (<GENE>) {
		chomp;
		@tabs = split /\t/, $_;
		@{$results{$tabs[0]}{$keyname}} = $tabs[1];
		$descs{$tabs[0]} = $tabs[5] if (@tabs == 6);
	}
	close GENE;
}

for my $gene (keys %results) {
	if (!exists $results{$gene}{$samples[0]}) {
		$results{$gene}{$samples[0]}->[0] = 0;
	}
}

&showLog("output");
open OUT, "> $outdir/all.align.stat.xls" or die $!;
print OUT "$header$desc\n";
my @descCol = split /\t/, $desc;
foreach my $gene (@term) {
	print OUT $gene;
	for (@samples) {
		if (exists $results{$gene}{$_} && @{$results{$gene}{$_}} == 1) {
			print OUT join("\t", "", @{$results{$gene}{$_}});
		} else {
			print OUT "\t-" ;
		}
	}
	if (exists $descs{$gene}) {
		print OUT "\t$descs{$gene}\n";
	} else {
		print OUT "\t-" x $#descCol . "\n";
	}
}

&showLog("done");

exit 0;

sub showLog {
	my ($info) = @_;
	my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
