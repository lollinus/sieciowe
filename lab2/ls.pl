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
@<<<<<<<<<< @##### @<<<<<<<<<<<<<<<<<<<<
$rights,$size,$file
.

foreach $file (@dir){
    ($mode,$size)=(stat $file)[2,7];
#	printf "%s %04o\n", $file, $mode & 07777;
#	print "$file";
	$rights = ($mode & 00400 ? "r" : "-").
		($mode & 00200 ? "w" : "-").($mode & 00100 ? "x" : "-").
		($mode & 00040 ? "r" : "-").($mode & 00020 ? "w" : "-").
		($mode & 00010 ? "x" : "-").($mode & 00004 ? "r" : "-").
		($mode & 00002 ? "w" : "-").($mode & 00001 ? "x" : "-");

    write;
}
}
