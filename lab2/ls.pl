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
@<<<<<<<<<< @##### @<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<
$rights,$size,$atime1,$file
.

foreach $file (@dir){
    ($mode,$size,$atime,$stime)=(lstat $kat.'/'.$file)[2,7,8,9];
#	printf "%s %04o\n", $file, $mode & 07777;
#	print "$file";
    $rights = (-d _ ? "d" : "");# -d  File is a directory.
    $rights = (-l _ ? "l" : $rights);# -l  File is a symbolic link.
    $rights = (-p _ ? "p" : $rights);# -p  File is a named pipe (FIFO), or Filehandle is a pipe.
    $rights = (-S _ ? "S" : $rights);# -S  File is a socket.
    $rights = (-b _ ? "b" : $rights);# -b  File is a block special file.
    $rights = (-c _ ? "c" : $rights);# -c  File is a character special file.
	$rights = (-f _ ? "-" : $rights);

	$rights = $rights.($mode & 00400 ? "r" : "-").
		($mode & 00200 ? "w" : "-").($mode & 00100 ? "x" : "-").
		($mode & 00040 ? "r" : "-").($mode & 00020 ? "w" : "-").
		($mode & 00010 ? "x" : "-").($mode & 00004 ? "r" : "-").
		($mode & 00002 ? "w" : "-").($mode & 00001 ? "x" : "-");
	$atime1 = gmtime($atime);
    write;
}
}
