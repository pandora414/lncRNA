#!usr/bin/perl -w
use strict;
use File::Basename;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <miso directory> <AS stat out dir>" unless @ARGV == 2;
my($miso,$outdir) = @ARGV;
my @type = qw(SE A3SS A5SS RI MXE);
my %hash;
foreach my $type (@type)
{
	my @files = glob("$miso/cmp_$type/*_vs_*/bayes-factors/*_vs_*.miso_bf");
	my @sig = glob("$miso/cmp_$type/*_vs_*.miso_bf.filtered");
	for (my $i = 0; $i <= $#files;$i ++)
	{
		my $name = basename $files[$i];
		$name =~ s/\.miso_bf//;
		my ($count,$sigcount) = (0,0);
		open IN,"$files[$i]" or die;
		open SIG,"$sig[$i]" or die;
		while(<IN>)
		{
			next if(/event_name/ || /^#/);
			$count ++;
		}
		while(<SIG>)
		{
			next if(/event_name/ || /^#/);
			$sigcount ++
		}
		$hash{$name}{$type}{"all"} = $count;
		$hash{$name}{$type}{"sig"} = $sigcount;
		close IN;
		close SIG;
	}
}
open OUT,">$outdir/AS.stat.plot.txt" or die;
print OUT "Group\tEvent\tSig\tCount\n";
foreach my $group (keys %hash)
{
#	print OUT "$group\t";
	foreach my $t(@type)
	{
		print OUT "$group\t$t\tAll\t$hash{$group}{$t}{\"all\"}\n";
		print OUT "$group\t$t\tSignificant\t$hash{$group}{$t}{\"sig\"}\n";
	}
}
close OUT;
#my $head = join "\t",@type;
open TABLE,">$outdir/AS.stat.xls"  or die;
print TABLE "Group";
foreach my $h (@type)
{
	print TABLE "\t$h\t$h\_sig";
}
print TABLE "\n";
foreach my $g(keys %hash)
{
	print TABLE "$g";
	foreach my $tp (@type)
	{
		print TABLE "\t$hash{$g}{$tp}{\"all\"}\t$hash{$g}{$tp}{\"sig\"}";
	}
	print TABLE "\n";
}
close TABLE;

system("Rscript $Bin/AS.stat.R -argument $outdir/AS.stat.plot.txt,$outdir/AS");
