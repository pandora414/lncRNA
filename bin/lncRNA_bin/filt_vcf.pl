use Getopt::Long;

my ($vcf,$out,$minq,$dist,$extend,$juncf,$pslf,$per,$altd);
GetOptions
(
	"i=s"=>\$vcf,
	"j=s"=>\$juncf,
	"p=s"=>\$pslf,
	"q=i"=>\$minq,
	"d=i"=>\$dist,
	"fre=f"=>\$per,
	"ald=i"=>\$altd,
	"e=i"=>\$extend,
	"o=s"=>\$out,
);

my $usage=<<INFO;
Usage:
	perl $0 [options]
Options:
	-i <file>	:input vcf_file
	-j <file>	:junction.bed
	-p <file>	:psl file
	-q <int>	:filt the quality blow INT,default 20
	-d <int>	:filt the SNPs whose distance blow INT bp,default 5
	-fre <float>	:the Min_alt_fre(%), default 0
	-ald <int>	:the Min_alt_reads, default 4
	-e <int>	:filt the extend INT bp intron near junction_pos, default 3 (force -j/-p)
	-o <filr>	:output the filter vcf_file
INFO

die $usage if(!$vcf || !$out);
$minq ||= 20;
$dist ||= 5;
$per ||=0;
$altd ||=4;
$extend ||= 3;

my %juncs=();
if(defined $juncf)
{
	if($juncf =~ /\.gz$/)
	{
		open IN,"gzip -dc $juncf |" or die $!;
	}
	else
	{
		open IN,$juncf or die $!;
	}
	while(<IN>)
	{
		chomp;
		next if($_ =~ /^track/);
		my ($chr,$ss,$ee,$lens)=(split /\t/,$_)[0,1,2,10];
		my ($la, $ra) = split("\,", $lens);
		my $start = $ss+$la;
		my $end = $ee-$ra+1;
#		$juncs{$chr}{$start} = 1;
#		$juncs{$chr}{$end} = 1;
		foreach my $i (1..$extend)
		{
#			my $tmpS1 = $start - $i;
			my $tmpS2 = $start + $i;
			my $tmpE1 = $end - $i;
#			my $tmpE2 = $end + $i;
#			$juncs{$chr}{$tmpS1} = 1;
			$juncs{$chr}{$tmpS2} = 1 unless(exists $juncs{$chr}{$tmpS2});
			$juncs{$chr}{$tmpE1} = 1 unless(exists $juncs{$chr}{$tmpE1});
#			$juncs{$chr}{$tmpE2} = 1;
		}
	}
	close IN;
}

if(defined $pslf)
{
	if($pslf =~ /\.gz$/)
	{
		open IN,"gzip -dc $pslf |" or die $!;
	}
	else
	{
		open IN,$pslf or die $!;
	}
	while(<IN>)
	{
		chomp;
		my ($chr,$size,$lens,$starts)=(split /\t/,$_)[13,17,18,20];
		next if($size == 1);
		$lens =~ s/,$//;
		$starts =~ s/,$//;
		my @arr1=split /,/,$lens;
		my @arr2=split /,/,$starts;
		next if(@arr1 != @arr2);
		foreach my $i (0..($#arr1-1))
		{
			my $j=$i+1;
			my $start=$arr2[$i]+$arr1[$i];
			my $end=$arr2[$j]+1;
			foreach my $k (1..$extend)
			{
				my $tmpS=$start+$k;
				my $tmpE=$end-$k;
				$juncs{$chr}{$tmpS} = 1 unless(exists $juncs{$chr}{$tmpS});
				$juncs{$chr}{$tmpE} = 1 unless(exists $juncs{$chr}{$tmpE});
			}
		}
	}
	close IN;
}

open OUT,">$out" or die $!;
open IN,$vcf or die $!;
my $prepos4SNP = 0;
my $buff='null';
my $chr4 = 0;
while(<IN>)
{
	chomp;
	if($_ =~ /^#/)
	{
		print OUT "$_\n";
		next;
	}
	my ($chr,$p,$b,$q)=(split /\t/,$_)[0,1,4,5];
	$chr4=$chr if($chr4 == 0);
	if(($prepos4SNP != 0) && ($p - $prepos4SNP <= $dist) && ($p != $prepos4SNP) && ($chr4 eq $chr))
	{
		$buff='null';
		$prepos4SNP = $p;
		next;
	}
	$chr4=$chr;
	$prepos4SNP = $p;
	if($q < $minq)
	{
		print OUT "$buff\n" if($buff ne 'null');
		$buff='null';
		next;
	}
	if($_ =~ /DP4=([^;]+)/)
	{
		my @da=split /,/,$1;
		my $altr=$da[2]+$da[3];
		my $perc=100*$altr/($altr+$da[0]+$da[1]);
		if(($altr < $altd) || ($perc < $per))
		{
			print OUT "$buff\n" if($buff ne 'null');
			$buff='null';
			next;
		}
	}
	if(defined $juncf)
	{
		if(exists $juncs{$chr}{$p})
		{
			print OUT "$buff\n" if($buff ne 'null');
			$buff='null';
			next;
		}
	}
	if(defined $pslf)
	{
		if(exists $juncs{$chr}{$p})
		{
			print OUT "$buff\n" if($buff ne 'null');
			$buff='null';
			next;
		}
	}
	if($buff ne 'null')
	{
		print OUT "$buff\n";
	}
	$buff=$_;
}
close IN;
close OUT;
