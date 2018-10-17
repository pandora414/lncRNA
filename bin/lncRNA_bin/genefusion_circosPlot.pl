#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib $Bin;

die "perl $0 <gene list> <circos.txt> <sample name> <out dir>" unless @ARGV == 4;
my ($list,$circos,$name,$outdir) = @ARGV;
my $cir = "/DG/home/zhum/programm/circos-0.64";

open CONFIG,">$outdir/circos.conf" or die;
print CONFIG "<colors>
white     = 255,255,255
black     = 0,0,0
blue      = 0,0,255
<<include $cir/etc/colors.ucsc.conf>>
</colors>

<fonts>
<<include $cir/etc/fonts.conf>>
</fonts>

<<include $Bin/genefusion/ideogram.conf>>
<<include $Bin/genefusion/ticks.conf>>


<image>
<<include $cir/etc/image.conf>>
</image>

# specify the karyotype file here
 karyotype = $Bin/genefusion/karyotype.human.hg19.txt
 chromosomes_units           = 1000000
 chromosomes_display_default = yes

 <plots>

 type       = text
 color      = black
 label_font = condensed

 <plot>
 file = $list
 r1   = 0.975r
 r0   = 0.7r

 label_size = 25p

 show_links     = yes
 link_dims      = 2p,2p,4p,2p,2p
 link_thickness = 2p
 link_color     = red

 label_snuggle         = yes
 max_snuggle_distance  = 1r
 snuggle_tolerance     = 0.25r
 snuggle_sampling      = 2

 </plot>
 </plots>

 <links>

 radius = 0.7r
 crest  = 1
 color  = black
 bezier_radius        = 0r
 bezier_radius_purity = 0.5
 thickness    = 2

 <link>

 file =$circos
 color=red

 <rules>


 <rule>
 condition  = (var(thickness) == 1)&& var(rev1)&&var(rev2)
 thickness  = 5
 z          = 15
 color      = green
 </rule>


 <rule>
 condition  = var(thickness) == 1
 thickness  = 5
 z          = 15
 </rule>

 <rule>
 condition  = (var(thickness) == 5)&&var(rev1)&&var(rev2)
 thickness  = 20
 z          = 15
 color      = green
 </rule>
 <rule>
 condition  = (var(thickness) == 5)
 thickness  = 20
 z          = 15
 </rule>




 <rule>
 condition  = (var(thickness) == 3)&&var(rev1)&&var(rev2)
 thickness  = 15
 z          = 15
 color      = green
 </rule>

 <rule>
 condition  = (var(thickness) == 3)
 thickness  = 15
 z          = 15
 </rule>




 </rules>
 </link>
 </links>

 <<include $cir/etc/housekeeping.conf>>
 ";
system ("$cir/bin/circos -conf $outdir/circos.conf -outputdir $outdir -outputfile $name.circos");

