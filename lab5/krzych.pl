#!/usr/bin/perl

sub uudecode_line
{
    $line = shift;

    $len = (unpack "c1", substr $line,0,1) - 32;
    $line = substr $line,1;

    $out = "";

    if ( $len == 64 ) {
        return "";
    }

    while( ($line !~ /^$/) && ($len!=0) ) {
        $pack4 = substr $line,0,4;
        $line = substr $line,4;
        @s = unpack "c4", $pack4;

        for( $i=0; $i<4; $i++ ) {
            @s[$i]-=32;
        }

        @b[0] = (@s[0] << 2) + (@s[1] >> 4);
        @b[1] = (@s[2] >> 2) + ( (@s[1] << 4) & 0xff ) ;
        @b[2] = @s[3] + ( (@s[2] << 6) & 0xff ) ;


        for( $i=0; ($len>0) && ($i < 3); $len--, $i++ ) {
            $out = $out . sprintf "%c", @b[$i];
        }
    }

    return $out;
}

$started = 0;

while( <STDIN> )
{
    if ( $_ =~ /^begin .*$/ ) {
        $started = 1;
        open file, ">pliczek.txt";
    } elsif ( $_ =~ /^\`/) { 
        $started = 0;
        close file;
    } elsif ( $started == 1 ) {
        $pack = uudecode_line $_;
#        print $pack;
        syswrite file, $pack;
    }
}
