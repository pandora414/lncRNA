#! /usr/bin/perl -w
#
use strict;
die "usage:perl $0 rawCount.txt control treat samplenumber outdir" unless @ARGV==5;
my($input,$con,$tre,$reptime,$out) = @ARGV;

system("Rscript /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/RUVg-spike.R --args -o $input,$con,$tre,$reptime,$out/RUVg-spike-pca.pdf,$out/RUVg-spike-pca.png,$out/RUVg-spike-rle.pdf,$out/RUVg-spike-rle.png")
