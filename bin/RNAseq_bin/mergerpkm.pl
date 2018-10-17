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

my $header1 = "GeneID";
my $header2 = "GeneID";
my $desc = "";
my @term;
my (@samples, %results1, %results2, %descs);
my @files = glob("$indir/*.rpkm.xls");
open FILE,"$files[0]" or die;
while(<FILE>){
	chomp;
	next if(/GeneID/);
	my $iterm = (split /\t/,$_)[0];
	push @term,$iterm;
}
	
for my $file (glob("$indir/*.rpkm.xls")) {
	my $keyname = basename($file);
	$keyname =~ s/\.rpkm\.xls$//;
	push @samples, $keyname;

	&showLog("read file $file");
	open GENE, "< $file" or die $!;

	my $temp = <GENE>;
	chomp $temp;
	my @tabs = split /\t/, $temp;
	$header1 .= "\t$tabs[3]"; # for (2);
	$header2 .= "\t$tabs[1]\t$tabs[3]"; # for (2);
	$desc = "\t$tabs[5]" if (@tabs == 6);

	while (<GENE>) {
		chomp;
		@tabs = split /\t/, $_;
		@{$results1{$tabs[0]}{$keyname}} = $tabs[3];
		@{$results2{$tabs[0]}{$keyname}} = "$tabs[1]\t$tabs[3]";
		$descs{$tabs[0]} = $tabs[5] if (@tabs == 6);
	}
	close GENE;
}

for my $gene (keys %results2) {
	if (!exists $results2{$gene}{$samples[0]}) {
		$results2{$gene}{$samples[0]}->[0] = 0;
		$results1{$gene}{$samples[0]}->[0] = 0;
	}
}

&showLog("output");
open OA, "> $outdir/all.sample.rpkm.xls" or die $!;
open OB, "> $outdir/all.sample.exp.xls" or die $!;
print OA "$header1$desc\n";
print OB "$header2$desc\n";
my @descCol = split /\t/, $desc;
foreach my $gene (@term) {
	print OA $gene;
	print OB $gene;
	for (@samples) {
		if (exists $results2{$gene}{$_} && @{$results2{$gene}{$_}} == 1) {
			print OA join("\t", "", @{$results1{$gene}{$_}});
			print OB join("\t", "", @{$results2{$gene}{$_}});
		} else {
			print OA "\t-" ;
			print OB "\t-" ;
		}
	}
	if (exists $descs{$gene}) {
		print OA "\t$descs{$gene}\n";
		print OB "\t$descs{$gene}\n";
	} else {
		print OA "\t-" x $#descCol . "\n";
		print OB "\t-" x $#descCol . "\n";
	}
}

&showLog("done");

exit 0;

sub showLog {
	my ($info) = @_;
	my @times = localtime; # sec, min, hour, day, month, year
	print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}
