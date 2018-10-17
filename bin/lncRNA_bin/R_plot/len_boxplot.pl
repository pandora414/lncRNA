#!/usr/bin/perl -w
use FindBin qw($Bin);
use lib "$Bin";
die "perl $0 <file names (bed format)> <names eg,protein,lincRNA,novel> <outdir>" unless @ARGV == 3;
my ($file,$names,$outdir) = @ARGV;
my (%hash);
my @file = split /,/,$file;
my @names = split /,/,$names;
for(my $i = 0; $i <=$#file;$i++)
{
	open IN,"< $file[$i]" or die;
	open OUT,">$outdir/$names[$i].len.txt" or die;
	while(<IN>)
	{
		chomp;
		next if(/^#/ || /^$/);
		my ($gene,$num,$size)=(split /\t/,$_)[3,9,10];
		my $len = 0;
		if($num < 2)
		{
			$size =~ s/,//;
			$len = $size;
		}else{
			my @lens = split /,/,$size;
			foreach (@lens)
			{
				$len +=$_;
			}
		}
		print OUT "$len\n";
		
	}
	close IN;
	close OUT;
}

print "$outdir\n";
chdir "$outdir" or die;
system("Rscript $Bin/len_boxplot.R --argument $names");

