#! /usr/bin/perl -w

use strict;
die "usage:perl $0 rawCount.txt control treat samplenumber outdir" unless @ARGV==5;
my($input,$con,$tre,$reptime,$out) = @ARGV;

system("Rscript /DG/home/wangy/process_upgrading/lncRNA-human/lncRNA_bin/RUVg-empirical.R --args -o $input,$con,$tre,$reptime,$out/RUVg-empirical-pca.pdf,$out/RUVg-empirical-pca.png,$out/RUVg-empirical-rle.pdf,$out/RUVg-empirical-rle.png")
