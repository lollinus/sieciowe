#!/usr/bin/perl
if (@ARGV>0) {
    @nazwa=@ARGV;
} else
{
    $nazwa[0]=".";
}

my @dir;

foreach $kat (@nazwa) {
opendir(hDir,"$kat");

@dir = readdir(hDir);

my $good = 0;

while( ! $good ) {
    $good = 1;
    for( $i=0; $i<@dir-1; $i++ ) {
	if ( $dir[$i] gt $dir[$i+1] ) {
	    ( $dir[$i], $dir[$i+1] ) = ($dir[$i+1], $dir[$i] );
	    $good = 0;
	}
    }
}
format =
@<<<<<<<<<<<<<< @<<<<<<<<<<<<<< @<<<<<<<<<<<<<<
$i,$n,$t
.

foreach $i (@dir){
    ($n,$t)=(stat $i)[2,4];
    write;
}
}
