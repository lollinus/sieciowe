#!/usr/bin/perl
my @table;

for( $i=0; $i<100; $i++ ) {
    @table[$i]=rand;
}

my $good = 0;

while( ! $good ) {
    $good = 1;
    for( $i=0; $i<@table; $i++ ) {
	if ( @table[$i] < @table[$i+1] ) {
	    ( @table[$i], @table[$i+1] ) = (@table[$i+1], @table[$i] );
	    $good = 0;
	}
    }
}

foreach $f (@table) {
	print "$f\n";
}
