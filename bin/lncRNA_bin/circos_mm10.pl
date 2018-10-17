#! usr/bin/perl
use strict;
use warnings;
use Text::CSV;
use Getopt::Long;
my ($infile,$dir,$sample,$help);
GetOptions(
      "i=s"=>\$infile,
      "dir=s"=>\$dir,
      "o=s"=>\$sample,
      "h"=>\$help
      );

my $usage=<<INFO;
Usage:
       perl $0 [options]
Options:
       -i <file>       :input file is the result of annotation by ANNOVAR
       -dir <string>   :out dir
       -o <string>    :the sample name
       -h              :get the usage
INFO

die $usage if (!$infile && !$sample && $help);

my $csv = Text::CSV->new();
my $status;
open IN, "$infile";
open OUT,  ">$dir/$sample.snp.exome.txt";
open OUT1,  ">$dir/$sample.snp.nonymous.exome.txt";
while(<IN>)
{
	    chomp;
            $status = $csv->parse($_);
	    my @line = $csv->fields();
            next if($line[0] eq 'Chr');
	    my ($chr,$start,$end)=@line[0,1,2];
	    $chr=~s/chr/mm/g;
           
	    my ($func,$type)=@line[5,7];
            if( $func eq "exonic" ||$func eq "exonic;splicing")
	       {  
	       	print OUT $chr,"\t",$start,"\t",$end,"\t","fill_color=redexom,r0=0.8r,r1=0.95r","\n";
	       	  if ( $type ne 'synonymous SNV')
	       	     { print OUT1 $chr,"\t",$start,"\t",$end,"\t","fill_color=blueexom,r0=0.65r,r1=0.8r","\n";
	       	     }
	       }
	    else
	       {
	       	print OUT $chr,"\t",$start,"\t",$end,"\t","fill_color=green,r0=1.075r,r1=1.125r","\n";
	       }           	    
} 
close IN;
close OUT;
close OUT1;

#build highlight.conf
open Highlight, ">$dir/$sample.highlight.conf" or die $!;
my $str;
$str=<<EOF;
<highlights>
z = 0
fill_color = green
<highlight>
file       = {file1}
</highlight>
<highlight>
file       = {file2}
</highlight>
</highlights>
EOF
$str=~s#{file1}#$dir/$sample.snp.exome.txt#g;
$str=~s#{file2}#$dir/$sample.snp.nonymous.exome.txt#g;
print Highlight  $str;
close(Highlight);

#build circos.conf
open Circos, ">$dir/$sample.circos.conf" or die $!;
my $circos;
$circos=<<EOE;
<colors>
<<include /DG/home/zhum/programm/circos-0.64/etc/colors.conf>>
</colors>

<fonts>
<<include /DG/home/zhum/programm/circos-0.64/etc/fonts.conf>>
</fonts>

<<include /DG/home/zhum/programm/circos-0.64/cancer_1/ideogram.conf>>
<<include /DG/home/zhum/programm/circos-0.64/cancer_1/ticks.conf>>
<<include {file1}.highlight.conf>>

<image>
<<include /DG/home/zhum/programm/circos-0.64/etc/image.conf>>
</image>

karyotype =/DG/home/zhum/programm/circos-0.64/data/karyotype/karyotype.mouse.mm10.txt
chromosomes_units           = 1000000
chromosomes_display_default = yes
<<include /DG/home/zhum/programm/circos-0.64/etc/housekeeping.conf>>
EOE
$circos=~s#{file1}#$dir/$sample#g;
print Circos  $circos;
close(Circos);

system("/DG/home/zhum/programm/circos-0.64/bin/circos -conf $dir/$sample.circos.conf -outputdir $dir -outputfile $sample.circos");
