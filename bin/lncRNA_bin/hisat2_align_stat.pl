#!/user/bin/perl -w
use strict;
die "perl $0 <align_summary.txt> <sample name> <output table>" unless @ARGV ==3;
my ($summary,$name,$out) = @ARGV;
my $total_reads = `head -n 1 $summary`;
$total_reads =~ /(\d+)/;
my $total_reads_num = $1 *2;
my $total_unmapped_reads = `head -n 12 $summary | tail -n 1`;
$total_unmapped_reads =~ /(\d+)/;
my $total_unmapped_reads_num = $1;
my $total_mapped_reads_num = $total_reads_num - $total_unmapped_reads_num;

my $total_mapped_rate_line = `head -n 15 $summary |tail -n 1`;
$total_mapped_rate_line =~ /(\d+\.\d+%)/;
my $total_mapped_rate = $1;

my $uniq_reads_part1 = `head -n 4 $summary | tail -n 1`;
$uniq_reads_part1 =~ /(\d+)/;
my $uniq_reads_part1_num = $1 *2;

my $uniq_reads_part2 = `head -n 13 $summary | tail -n 1`;
$uniq_reads_part2 =~ /(\d+)/;
my $uniq_reads_part2_num = $1;

my $total_uniq_reads_num = $uniq_reads_part1_num + $uniq_reads_part2_num;

my $total_uniq_reads_rate = $total_uniq_reads_num*100/$total_mapped_reads_num;

my $multiple_reads_part1 = `head -n 5 $summary | tail -n 1`;
$multiple_reads_part1 =~ /(\d+)/;
my $multiple_reads_part1_num = $1*2;
my $multiple_reads_part2 = `head -n 14 $summary | tail -n 1`;
$multiple_reads_part2 =~ /(\d+)/;
my $multiple_reads_part2_num = $1;
my $total_multiple_reads_num = $multiple_reads_part1_num + $multiple_reads_part2_num;
my $total_multiple_reads_rate = $total_multiple_reads_num*100/$total_mapped_reads_num;

open OUT,">$out" or die;
print OUT "Iterm\t$name\n";
print OUT "Total reads\t$total_reads_num\n";
print OUT "Total mapped reads\t$total_mapped_reads_num\n";
print OUT "Total mapped rate\t$total_mapped_rate\n";
print OUT "Total uniq mapped reads\t$total_uniq_reads_num\n";
printf OUT "Total uniq mapped rate\t%.2f","$total_uniq_reads_rate";
print OUT  "%\n" ;
print OUT "Total multiple mapped reads\t$total_multiple_reads_num\n";
printf OUT "Total multiple mapped rate\t%.2f","$total_multiple_reads_rate";
print OUT "%\n";

close OUT;
