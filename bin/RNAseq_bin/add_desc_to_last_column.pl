#!/usr/bin/perl
use strict;
use warnings;

if(@ARGV!=3)
{
	print "\n perl $0 <raw file> <NR desc> <out file>\n";
	exit;
}

open OUT,">$ARGV[2]";
my (%raw,%annot);
open G,"$ARGV[1]"|| die "Cannot open the file '$ARGV[1]'.\n";
while (<G>)
{
	chomp;
	if ($_ ne "")
	{
		my $line=$_;
		my @sp=split(/\t/,$line);
		$annot{$sp[0]}.="$sp[-1];";
	}
}
close G;

open F,"$ARGV[0]" || die "Cannot open the file '$ARGV[0]'.\n";
while (<F>) 
{
	chomp;
	my $line=$_;
	my @sp=split(/\t/,$line);
	$raw{$sp[0]}=$line if($line ne "");
	if((! defined $annot{$sp[0]}) && $sp[0] ne "GeneID")
	{
		$annot{$sp[0]}="NA";
	}
	print OUT "$raw{$sp[0]}\tDescription\n" if($sp[0] eq "GeneID");
	print OUT "$raw{$sp[0]}\t$annot{$sp[0]}\n" if($sp[0] ne "GeneID");
}
close F;

close OUT;
__END__
