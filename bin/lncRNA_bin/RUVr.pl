#! /usr/bin/perl -w

use strict;
die "usage:perl $0 rawCount.txt control treat samplenumber outdir" unless @ARGV==5;
my($input,$con,$tre,$reptime,$out) = @ARGV;

system("Rscript /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/RUVr.R --args -o $input,$con,$tre,$reptime,$out/RUVr-pca.pdf,$out/RUVr-pca.png,$out/RUVr-rle.pdf,$out/RUVr-rle.png")
