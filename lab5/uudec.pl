#!/usr/bin/perl

my $EOL = "\015\012";

sub uudecode {
	$filein = shift;
	open(IN,"<$filein") or die "problem z otwarciem pliku wejsciowego $wejscie\n";
	print "$filein\n";
	print "sprawdzanie za³±czników kodowanych UU\n";
	@file=<IN>;
	
	$decode = 0;
	
  LINE: foreach $line (@file) {

		@line = split(' ',$line);
 		if ( $line[0] eq begin ) {
			$decode = 1;
			open (OUT, ">$line[2]");
		} elsif ( $line eq "`$EOL") { 
			$decode = 0;
			close(OUT);
		} elsif ( $decode == 1 ) {
			$len = unpack("c1", substr($line,0,1)) - 32;
			$line = substr($line,1);
			
			$out = "";
			next LINE if $len == 64;

			while( ($line ne $EOL) && ($len>0) ) {
				$enc = substr($line,0,4);
				$line = substr($line,4);
				@enc = unpack("c4",$enc);
				
				for( $i=0; $i<4; $i++ ) {
					@enc[$i]-=32;
				}
				
				@dec[0] = (@enc[0] << 2) + (@enc[1] >> 4);
				@dec[1] = (@enc[2] >> 2) + ( (@enc[1] << 4) & 0xff ) ;
				@dec[2] = @enc[3] + ( (@enc[2] << 6) & 0xff ) ;

				for( $i=0; ($i < 3) && ($len > 0); $len--, $i++ ) {
					$out = $out . sprintf("%c", @dec[$i]);
				}
			}

			print OUT "$out";
		}
	}
	close (IN);
}

uudecode("uuenc");

exit 1;
