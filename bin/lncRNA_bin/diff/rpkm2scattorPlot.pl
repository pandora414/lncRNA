#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;
die "perl $0 <diff.rpkm file> <control sample name> <case name> <control group name> <case group name> <output dir for plot>" unless @ARGV == 6;
my ($in,$control,$case,$contorgroup,$casegroup,$outdir) = @ARGV;
my $tool = "diffGene_scattorPlot.pl";
my (@control,@case,@head);
my (%hash,%rpkm,%other);
if($control =~ /,/ || $case =~ /,/)
{
	@control = split /,/,$control;
	@case = split /,/,$case;
	open IN,"$in" or die;
	while(<IN>)
	{
		chomp;
		next if (/^#/ || /^$/);
		if($_ =~ /GeneID/)
		{
			@head = split /\t/,$_;
			next;
		}
		
		my @line = split /\t/,$_;
		next if($line[-4] eq "-");
		$other{$line[0]} = (join "\t",@line[-4..-1]);
		my $col_num = $#control + $#case +2;
		for (my $col= 1;$col <=$col_num  ;$col ++)
		{
			$hash{$line[0]}{$head[$col]} = $line[$col];
		}
	}
	close IN;
	foreach my $gene(keys %hash)
	{
		my $total_rpkm;
		foreach my $con(@control)
		{
			$total_rpkm += $hash{$gene}{$con};
		}
		my $mean_rpkm = $total_rpkm/($#control +1);
		$rpkm{$gene}{$contorgroup} = $mean_rpkm;
		my $case_total_rpkm;
		foreach my $ca(@case)
		{
	#		print "@case\n";
			$case_total_rpkm += $hash{$gene}{$ca};
		}
		my $ca_mean = $case_total_rpkm/($#case +1);
		$rpkm{$gene}{$casegroup} = $ca_mean;
	}
	open OUT,">$outdir/$contorgroup\_$casegroup.rpkm.plot.xls" or die;
	print OUT "GeneID\t$contorgroup\t$casegroup\tlogFC\tlogCPM\tPValue\tFDR\n";
	foreach my $gen (keys %rpkm)
	{
		print OUT "$gen\t$rpkm{$gen}{$contorgroup}\t$rpkm{$gen}{$casegroup}\t$other{$gen}\n";
	}
	close OUT;
	system("perl $Bin/$tool -infile $outdir/$contorgroup\_$casegroup.rpkm.plot.xls -outdir $outdir -FDR 0.05 -fold 0 -R_path /DG/programs/beta/rel/R/bin");	
}else{
	system("perl $Bin/$tool -infile $in -outdir $outdir -FDR 0.05 -fold 0 -R_path /DG/programs/beta/rel/R/bin");
}

		

