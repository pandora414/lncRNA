#!/usr/bin/perl -w
use FindBin qw($Bin);
use lib "$Bin";
die "perl $0 <file names (gtf format)> <names eg,protein,lincRNA,novel> <expression file> <outdir>" unless @ARGV == 4;
my ($file,$names,$fpkm,$outdir) = @ARGV;
my (%hash);
my @file = split /,/,$file;
my @names = split /,/,$names;
for(my $i = 0; $i <=$#file;$i++)
{
	open IN,"< $file[$i]" or die;
	while(<IN>)
	{
		chomp;
		next if(/^#/ || /^$/);
		my $attr=(split /\t/,$_)[8];
		my $gene = (split /\s+/,$attr)[1];
		$gene =~ s/"//g;
		$gene =~ s/;//;
		$hash{$gene} = $names[$i];
	}
	close IN;
}

foreach my $name (@names)
{
	open FPKM,"$fpkm" or die;
	open OUT,">$outdir/$name.fpkm.txt" or die;
	while(<FPKM>)
	{
		chomp;
		next if(/^#/ || /ID/|| /tracking_id/);
		my ($id,$fpkm) = (split /\t/,$_)[0,1];
		next if ($fpkm <0.01);
		#$fpkm = 0.01 if ($fpkm == 0);
		if($hash{$id} eq $name)
		{
			print OUT "$fpkm\n"; 
		}
	}
	close FPKM;
	close OUT;
}
print "$outdir\n";
system("cd $outdir");
system("Rscript $Bin/exp_plot.R --argument $names");

