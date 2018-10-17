#! /usr/bin/perl -w
use strict;
use File::Basename qw(dirname basename);

die "perl $0 <dir> <output table>" unless @ARGV == 2;
my ($dir,$table) = @ARGV;

my $header = "Iterm";
my $desc = "";

my (@samples, %results, %descs);
my @files = glob("$dir/*.strand_distribution.txt");
foreach my $samp (@files)
{
	my $samplename0 = (split /\./,$samp)[0];
	my $samplename = (split /\//,$samplename0)[-1];
	push @samples, $samplename;
}

foreach my $name (@samples)
{
	my $file = "$dir/$name.strand_distribution.txt";	
	&showLog("read file $file");
	$header .= "\t$name";
	open STRAND, "< $file" or die $!;
	while (<STRAND>) 
	{
		chomp;
		next if(/^$/);
		next if(/This is PairEnd Data/);
		my ($iterm,$count) = split /:/,$_;
		$results{$iterm}{$name} = $count;
	}
	close STRAND;
}
&showLog("output");
open OUT, ">$table" or die $!;
print OUT "$header\n";
for my $gene (sort {$a cmp $b} keys %results) 
{
	print OUT $gene;
	for (@samples)
	{
		if (exists $results{$gene}{$_}) 
		{
	                print OUT "\t$results{$gene}{$_}";
       		}
		else {
			print "wrong: the $_ not have the $gene,please check!!\n";
		}
	}
	print OUT "\n";
}

&showLog("done");

exit 0;
sub showLog {
        my ($info) = @_;
        my @times = localtime; # sec, min, hour, day, month, year
        print STDERR sprintf("[%d-%02d-%02d %02d:%02d:%02d] %s\n", $times[5] + 1900, $times[4] + 1, $times[3], $times[2], $times[1], $times[0], $info);
}


