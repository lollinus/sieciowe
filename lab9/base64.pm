#!/usr/bin/perl -w

sub bin2base64 
{
	$filein = shift;
	$fileout = shift;
	open(IN,"<$filein") or die "problem z otwarciem pliku wejsciowego $filein\n";
	open(OUT,">$fileout") or die "problem z otwarciem pliku wyjsciowego $fileout\n";
	print "bin2base64 $filein -> $fileout\n";

	my @code  = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');
#	syswrite(OUT,"begin-base64 644 $filein\n");

	my $linelen = 0;

	while ( ($len = sysread(IN,$pack1,3)) ) {
		$abc[0] = substr($pack1,0,1);
		$len >= 2 ? ($abc[1] = substr($pack1,1,1)) : ($abc[1] = "\000" );
		$len >= 3 ? ($abc[2] = substr($pack1,2,1)) : ($abc[2] = "\000" );

		for( $i=0; $i<3; $i++ ) {
			$triple[$i] = unpack("C",$abc[$i]);
		}
 		$quard[0] = (($triple[0] >> 2) & 0x3f);
 		$quard[1] = (($triple[0] << 4)& 0x30) + (($triple[1] >> 4) & 0x0f);
 		$quard[2] = (($triple[1] << 2) & 0x3c) + (($triple[2] >> 6) & 0x03);
 		$quard[3] = $triple[2] & 0x3f;
#		print("$abc[0] $abc[1] $abc[2] triple @triple quard @quard\n");
 		syswrite(OUT,$code[$quard[0]]);
 		syswrite(OUT,$code[$quard[1]]);
		$len >= 2 ? (syswrite(OUT,$code[$quard[2]])) : (syswrite(OUT,'='));
		$len >= 3 ? (syswrite(OUT,$code[$quard[3]])) : (syswrite(OUT,'='));
		$linelen++;
		if ($linelen == 18) { 
			$linelen=0;
			syswrite(OUT,"\n") };
	}
	syswrite(OUT,"\n");

	close (OUT);
	close (IN);
}

sub base642bin
{
 	$filein = shift;
 	$fileout = shift;
 	open(IN,"<$filein") or die "problem z otwarciem pliku wejsciowego $filein\n";
 	open(OUT,">$fileout") or die "problem z otwarciem pliku wyjsciowego $fileout\n";
 	print "base642bin $filein -> $fileout\n";

  LINE: foreach $line ( <IN> ) {
# 	  if ( $line =~ m/^begin-base64\s\d{3}\s(.*)$/ ) {
# 		  $decode = 1;
# 		  open (OUT, ">$2");
# 	  } elsif ( $line =~ m/^$/) { 
# 		  $decode = 0;
# 		  close(OUT);
# 	  } elsif ( $decode == 1 ) {

	  while( ($line ne "\n") ) {
		  $enc = substr($line,0,4);
		  $line = substr($line,4);
		  @enc = unpack("c4",$enc);
		  for( $i=0; $i<4; $i++ ) {
			  if ( $enc[$i] > 64 and  $enc[$i] < 91 ) { $enc[$i]-=65 }
			  elsif( $enc[$i] > 96 and  $enc[$i] < 123 ) { $enc[$i]-=71 }
			  elsif( $enc[$i] > 47 and  $enc[$i] < 58 ) { $enc[$i]+=4 }
			  elsif( $enc[$i] == 43 ) { $enc[$i]=62 }
			  elsif( $enc[$i] == 47 ) { $enc[$i]=63 }
			  elsif( $enc[$i] == 61 ) { $enc[$i]=0}
			  else { die "bad sign in base64 coded mess"};
		  }
		  
		  $dec[0] = ($enc[0] << 2) + ($enc[1] >> 4);
		  $dec[1] = ($enc[2] >> 2) + ( ($enc[1] << 4) & 0xff ) ;
		  $dec[2] = $enc[3] + ( ($enc[2] << 6) & 0xff ) ;
		  
		  for ($i=0; $i<3 ; $i++ ) {
			  if ( $dec[$i] != 0) {
#				  print pack("C",$dec[$i]);
				  syswrite(OUT,pack("C",$dec[$i]))
			  };
		  }
	  }
  }
	close (OUT);
	close (IN);
}

return true;
