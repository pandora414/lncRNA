#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
use Text::CSV;
die "perl $0 <dir contain the snp annot file> <out dir> " unless @ARGV == 2;
my ($dir,$outdir) = @ARGV;
#my $csv = Text::CSV->new();
#my $status;
my %type;
my @name;
my @files = glob("$dir/*_multianno.csv");
my @type=qw(A/C A/G A/T C/A C/G C/T G/A G/C G/T T/A T/C T/G);
open OUT,">$outdir/snp_type.plot.txt" or die;
print OUT "Type\tSample\tCount\n";
foreach my $file(@files)
{
	my $name = (split /\//,$file)[-1];
	$name =~ s/\.\w+_multianno\.csv//;
	push @name,$name;
	my $csv = Text::CSV->new();
	my $status;
	open IN,"$file" or die;
	while(<IN>)
	{
		chomp;
		next if(/Chr/ || /^#/ || /^$/);
		$status = $csv->parse($_);
		my @line = $csv->fields();
		my $type = "$line[3]/$line[4]";
	#	print "$type\n";
		if($type ~~ @type)
		{
			$type{$type}{$name} ++;
		}else{
			next;
		}
	}
	close IN;
	foreach my $t(@type)
	{
		print OUT "$t\t$name\t$type{$t}{$name}\n";
	}
}
open DIS,">$outdir/snp_type_dis.xls" or die;
my $sample = join "\t",@name;
print DIS "Type\t$sample\n";
foreach my $ty (@type)
{
	print DIS "$ty";
	foreach my $samp (@name)
	{
		print DIS "\t$type{$ty}{$samp}";
	}
	print DIS "\n";
}
close OUT;
close DIS;
#system("Rscript $Bin/snp_type.plot.R --argument $outdir/snp_type.plot.txt,$outdir/snp_type");
system("/DG/programs/beta/rel/R-3.2.3/bin/Rscript $Bin/snp_type.plot.R --argument $outdir/snp_type.plot.txt,$outdir/snp_type");
