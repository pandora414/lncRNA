#!/usr/bin/perl -w
## Author: Lei Sun
## Date: 20/08/2012

## Goal - To extract long(>200) multi-exon RNAs according to a BED file of transcripts
## Input - 1) RefSeq_NR.bed
## Output - 1) a ID list of lncRNAs

use strict;

open(NR, "<", $ARGV[0]) || die "Could not read from argv[0], program halting.";
my $line_count = 0;
while(my $current_line = <NR>){
	chomp($current_line);
    $line_count++;
    
    # split current line
    my @fields_line = split("\t", $current_line);
    
    # check if the exon number is at least 2
    if($fields_line[9] < 2 ){
	$fields_line[10] =~ s/,//;
	if ($fields_line[10] >= 200)
	{
		print $current_line, "\n";
	}
    	#next;
    }
    else{
    		my @length = split(/,/, $fields_line[10]);
   		my $sum = 0;
    		foreach(@length){
   			$sum = $sum + $_;
    		}
    		if($sum > 200){
    			print $current_line, "\n";
    		}
	}
}

close(NR);
