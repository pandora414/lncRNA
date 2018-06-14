#!/usr/bin/perl -w
use strict;
die "perl $0 <bam or sam file> <fq1.gz> <fq2.gz> <unmap fq1 prefix> <unmap fq2 prefix>" unless @ARGV == 5;
my ($in,$fq1,$fq2,$out1,$out2) = @ARGV;
my %hash;
if($in =~ /bam/)
{
	open IN,"samtools view $in |" or die;
}else{
	open IN,"$in" or die;
}
while(<IN>)
{
	next if(/^@/);
	my $id = (split /\t/,$_)[0];
	$id = "@"."$id";
	$hash{$id} =1;
}
close IN;
open OUT1,"| gzip >$out1.gz" or die;
if($fq1 =~ /gz$/)
{
	open FQ1,"gzip -dc $fq1 |" or die;
}else {
	open FQ1,"$fq1" or die;
}
while (<FQ1>)
{
	my $id = $_;
	my $name = (split /\s+/,$id)[0];
	my $seq = <FQ1>;
	my $line3 = <FQ1>;
	my $qual = <FQ1>;
	if (exists $hash{$name})
	{
		next;
	}else{
		print OUT1 "$id$seq$line3$qual";
	}
}
open OUT2,"| gzip >$out2.gz" or die;
if($fq2 =~ /gz$/)
{
        open FQ2,"gzip -dc $fq2 |" or die;
}else {
        open FQ2,"$fq2" or die;
}
while (<FQ2>)
{
        my $id = $_;
        my $name = (split /\s+/,$id)[0];
        my $seq = <FQ2>;
        my $line3 = <FQ2>;
        my $qual = <FQ2>;
        if (exists $hash{$name})
        {
		next;
	}else{
                print OUT2 "$id$seq$line3$qual";
        }
}
close FQ1;
close FQ2;
close OUT1;
close OUT2;
