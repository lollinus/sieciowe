#!/usr/bin/perl
@ARGV>0 or die "podaj plik wejsciowy\n";

my $wejscie=$ARGV[0];
my $wyjscie;
if (@ARGV>1) {
    $wyjscie=$ARGV[1];
} else
{
    $wyjscie="wy.txt";
}

open(WE,"<$wejscie") or die "problem z otwarciem pliku wejsciowego $wejscie\n";
open(WY,">$wyjscie") or die "problem z otwarciem pliku wyjsciowego $wyjscie\n";
my %studenci;

@plik=<WE>;
my $linia;
foreach $linia (@plik) {
    @student=split(' ',$linia);
    $nazwa=$student[0]." ".$student[1];
    for ($i=2; $i<@student ; $i++) {
	$studenci{$nazwa} += $student[$i];
    }
    print "$nazwa\n";
    print "$studenci{$nazwa}\n";
    print "@linia\n";
    
#    $studenci{$nazwa} /= @linia;

format =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @#.##
$nazwa,$studenci{$nazwa}
.
    write;
    }

#foreach $n (@studenci) {
#     write WY;
#    print "$n\t$
#}

