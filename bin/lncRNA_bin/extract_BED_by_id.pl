#!/usr/bin/perl -w
## Author: Tong Yu
## Date: 09/12/2015

## Goal - To extract rows according to a list of ids
## Input - 1) transcript_ids.list
##	   2) bed
## Output - 1) rows containing the id

use strict;
die "perl $0 <ID list file> <ID column> <BED file> <new bed file>" unless @ARGV == 4;
my ($idlist,$col,$bed,$out) = @ARGV;
open(LIST, $idlist) || die "Could not read from ID list file, program halting.";
my %IDS;
my $line_count=0;
while(my $current_line=<LIST>){
    chomp($current_line);
    $line_count++;
   next if($current_line =~ /^#/ || $current_line =~/GeneID/ || $current_line =~/Trancsript/); 
    my @fields_line = split(/\t/, $current_line);
    
    if(!exists $IDS{$fields_line[$col-1]})
    {
        $IDS{$fields_line[$col-1]} = 1;
    }
}
close(LIST);

open(BED, $bed) || die "Could not read from BED file, program halting.";
open OUT,">$out" or die;
$line_count=0;
while(my $current_line=<BED>){
    chomp($current_line);
    $line_count++;
    
    my @fields_line = split(/\t/, $current_line);

    if(exists $IDS{$fields_line[3]})
    {
        print OUT "$current_line\n";
    }
}
close(BED);
close OUT;
