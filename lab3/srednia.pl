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
my %suma;
my %ilosc;
my %srednia;

@plik=<WE>;
my $linia;
foreach $linia (@plik) {
    @student=split(' ',$linia);
    $nazwa=$student[0]." ".$student[1];
    for ($i=2; $i<@student ; $i++) {
		$suma{$nazwa} += $student[$i];
		$ilosc{$nazwa}++;
    }
    print "$nazwa ";
    print "$suma{$nazwa} ";
	print "$ilosc{$nazwa}\n";
    print "$linia";
    
    $srednia{$nazwa} = $suma{$nazwa} / $ilosc{$nazwa};

format =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @#.##
$nazwa,$srednia{$nazwa},
.
#	write;
print "\n";
}

#foreach $n (sortsrednia) {
#     write;
#    print "$n\t"
#}

