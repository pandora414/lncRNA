#!/usr/bin/perl -w
use strict;
use Cwd qw(abs_path);
use Getopt::Long;
=head1 Program Description
	gtffilter.pl
	This program is used to screen The transcripts which FPKM large than you give value.

Options:

	-gtfdir	input dir,contain the cufflinks results of each sample,default "."; 

	-outdir	output dir,default: ".";

	-fpkm	you defined FPKM value,default 0;

	-help	get help info;

Usage: 

	perl Gtffilter.pl -gtfdir . -outdir . -fpkm 0

=cut
my($gtfdir,$outdir,$fpkm,$help);
GetOptions(
	"help!" => \$help,
	"gtfdir=s" => \$gtfdir,
	"outdir=s" => \$outdir,
	"fpkm=s" => \$fpkm,
);
die `pod2text $0 ` if (defined $help || !defined $gtfdir || !defined $outdir);
$gtfdir ||= ".";
$outdir ||= ".";
$fpkm ||=0;
$gtfdir = abs_path($gtfdir);
$outdir = abs_path($outdir);
[-d $outdir] || mkdir $outdir || die "can't generate the outdir:$!";
my @files = glob ("$gtfdir/*/transcripts.gtf");

open LIST,"> $outdir/filter.gtf.list" or die $!;
open STAT,"> $outdir/gtf.filter.stat" or die;
print STAT "Name\tRawGene\tRawTranscript\tFilterGene\tFilterTranscript\tRawTransGeneRatio\tFilterTransGeneRatio\n";
foreach (@files)
{
	if (-e "$_")
	{
		
		my $name = (split /\//,$_)[-2];
		print "filter the $name.transcript.gtf ... \n";
		my %exp0=();
		my (%gene,%trans,%gene2,%trans2);
		print LIST "$outdir/$name.transcript.gtf\n";
		open GTF,"$_" or die $!;
		open OUT,"> $outdir/$name.transcript.gtf" or die $!;
 		open OUT2,"> $outdir/$name.transcript_fpkm0.gtf" or die $!;
		while (<GTF>)
		{
			chomp;
			my @array = split /\t/,$_;
			my $chrID = (split /\t/,$_)[0];
			$array[8] =~ /FPKM "(\d+\.\d+)";/;
			my $fpkm = $1;
			#print "$fpkm\n";
			$array[8] =~ /transcript_id "(\S+)";/;
			my $transid = $1;
 			my $line = join "\t",@array;
			##print "$transid\n";
			$array[8] =~/gene_id "(\S+)"; transcript_id "(\S+)";/;
			$gene{$1} = 1;
			$trans{$2} = 2;
			if($array[2] eq "transcript" && $fpkm > 0)
			{
				$array[8] =~/gene_id "(\S+)"; transcript_id "(\S+)";/;
				$gene2{$1} = 1;
				$trans2{$2} = 2;
			}
			if ($array[2] eq "transcript" && $fpkm <= 0)
			{
				$exp0{$transid} = $fpkm;
				print OUT2 "$line\n";
				next;
			}
			if ($array[2] eq "exon" && exists $exp0{$transid})
			{
				print OUT2 "$line\n";
				next;
			}
			#my $line = join "\t",@array;
			print OUT "$line\n";
		}
	   close OUT;
	   print "$name.transcript.gtf completed!\n";
	   my($genenum,$transnum,$genenum0,$transnum0) = (0,0,0,0);
                        foreach my $gene(keys %gene)
                        {
                                $genenum ++;
                        }
                        foreach my $trans (keys %trans)
                        {
                                $transnum ++;
                        }
                        foreach my $gene0(keys %gene2)
                        {
                                $genenum0 ++;
                        }
                        foreach my $trans0 (keys %trans2)
                        {
                                $transnum0 ++;
                        }
			my $rawratio = $transnum/$genenum;
			$rawratio = sprintf("%.2f",$rawratio);
			my $filRatio = $transnum0/$genenum0;
			$filRatio = sprintf("%.2f",$filRatio);
                        print STAT "$name\t$genenum\t$transnum\t$genenum0\t$transnum0\t$rawratio\t$filRatio\n";

	 }
	else {
		print "the $_ file not exists\n";
	}
}
close LIST;
close STAT;
