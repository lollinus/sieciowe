#!/usr/bin/perl

my $EOL = "\015\012";

sub uudecode {
	$filein = shift;
	open(IN,"<$filein") or die "problem z otwarciem pliku wejsciowego $wejscie\n";
	print "$filein\n";
	print "$fileout\n";
	@file=<IN>;
	
	$decode = 0;
	
  LINE: foreach $line (@file) {

		@line1 = split(' ',$line);
 		if ( $line1[0] eq begin ) {
			$started = 1;
			open (OUT, ">$line1[2]");
		} elsif ( $line eq "`$EOL") { 
			$started = 0;
			close(OUT);
		} elsif ( $started == 1 ) {
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
#			syswrite OUT, $out;
		}
	}
	close (IN);
}

uudecode("wiadomosc.1");

exit 1;
