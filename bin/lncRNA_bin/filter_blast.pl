#!/usr/bin/perl
use strict;
use File::Basename;
use Getopt::Long;
my $usage=<<INFO;
Description:
	the $0 is used to filt the blast result with identity and query coverage.
the input file should be the result of blast_parser.pl.
the output is the *.ID  ,filter file,multialignment file if exists.
Usage:
        perl $0 [options]

        options:
	-s <string>*  the fasta file of the sample
	-l <int>      the percentage of the aligment length,default 0.8
        -n <int>      the identity of blast for filter,default 0.9
	-i <string>*  the input file 
	-o <sting>*   the output prefix.
	-f <int>*     0 or 1, default 1, 1 output both aligned seqences and unaligned sequences, 0 output only unaligned sequences.
        -h|help       output help information to screen

e.g
	perl $0 -i sample_name.tab -o sample_name -s sequence.fa -f 0


INFO
my $indentity = 0.9;
my $length_coverage = 0.8;
my ($in,$out,$help,$seq,$outflag);
GetOptions(
	"s=s"=>\$seq,
	"i=s"=>\$in,
	"o=s"=>\$out,
        "n:i"=>\$indentity,
	"l:i"=>\$length_coverage,
	"f:i"=>\$outflag,
        "h|help"=>\$help,

);
die "$usage" if($help || !$in);
open IN,"$in" || die "can't open the file:$!";
my $output = $out."_filter.xls";
open OUTPUT,">$output" || die "can't open the file:$!";
my ($content,$multialign,$flag);
my %ncRNA;
while($content=<IN>)
{
	unless($content =~ /Identity/i)
	{
		chomp($content);
		my @query = split(/\t/,$content);
		my $query_coverage = $query[11]/($query[1]>$query[5]?$query[5]:$query[1]);
		if($query_coverage >$length_coverage && $query[8]> $indentity)
		{
			if(exists $ncRNA{$query[0]})
			{
				my @tem = split(/\t/,$ncRNA{$query[0]});
				if($query[13] < $tem[13])
				{$ncRNA{$query[0]} = $content;}
				elsif($query[13] > $tem[13])
				{next;}
				else
				{
					if($query[12] > $tem[12])
					{$ncRNA{$query[0]} = $content;}
					elsif($query[12] < $tem[12])
					{next;}
					else
					{
						if($flag =~ /$query[0]/)
						{
							$multialign.="$content\n";
						}
						else 
						{
							$multialign.= ($ncRNA{$query[0]}."\n$content\n");
							$flag=$query[0];
						}
					} 
				}
			} 
			else
			{$ncRNA{$query[0]} = $content;}
		}			
	}
}
                         
my $id = $out.".ID";
open NCID,">$id" || die "can't open the file:$!";
my $count = scalar(keys%ncRNA);
foreach my $i (sort{$a cmp $b} keys %ncRNA)
{
	print NCID "$i\n";
	print OUTPUT "$ncRNA{$i}\n";
}
print STDERR "$count\n";
close NCID;
close OUTPUT;

if($multialign =~ /CUFF/)
{
	my $muti=$out."_multialigment.xls";
	open MULT,">$muti" || die "can't open the file:$!";
	print MULT $multialign;
	close MULT;
}
open SEQ, "$seq" || die "can't open the fasta file:$!";
my $unalignedRNA=$out."_unaligned.fa";
my $alignedRNA=$out."_aligned.fa";
open URNA, ">$unalignedRNA";
open ARNA, ">$alignedRNA";
$/= ">";
my $content_seq;
$outflag ||= 1;
while($content_seq = <SEQ>)
{
        $content_seq =~ s/>//;
#        if($content_seq =~ /(.+?)\s.+?\n([\d\D]+)/)
	if($content_seq =~ /(.+?)\n([\d\D]+)/) 		# yuanyongxian for ncRNA
       {
               	if(!exists $ncRNA{$1} && $outflag == 1)
                {
			print URNA ">",$1,"\n","$2";
                }elsif(exists $ncRNA{$1})
		{
			print ARNA ">",$1,"\n","$2";
		}
	
        }
}
close URNA;
close ARNA;
