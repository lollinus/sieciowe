#!/usr/bin/perl
#use strict;
use Socket;

$EOL = "\015\012";

$remote = shift;
$port = 110;
if ($port =~ /\D/) { $port = getservbyname($port,'tcp') }
die "No port" unless $port;
$iaddr = inet_aton($remote) || die "no host: $remote";
$paddr = sockaddr_in($port, $iaddr);

$proto = getprotobyname('tcp');
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCK, $paddr) || die "connect: $!";
$line = <SOCK>;
@line1 = split(' ',$line);

sub login_mail
{
    my $resp = shift;
#	my $resp = $line1[0];
	if ( $resp == "+OK" ) {
		print "@line1[0]\n";
#		print "OK\n";
#		print;
#		print SOCK;
#		print SOCK "USER kbarski\n";
#		$command = "USER kbarski\n";
#		syswrite $SOCK $command;
		print "@line1[0]\n";
		select(SOCK);
		$|=1;
		select(STDOUT);
		print SOCK "USER kbarski$EOL";
		print "@line1\n";
		$line = <SOCK>;
		print "@line1\n";
		@line1 = split(' ',$line);		

		print "@line1\n";
		print SOCK "PASS 3rzycycki\n";
		@line1 = split(' ',<SOCK>);		
		print "@line1\n";		
		return 1;
	} elsif  ( $resp == "-ERR" ) {
		print "ERR\n";
		return 0;
	} else {
		print "co to k... jest $resp\n";
		return 2;
	}
}

login_mail $line1[0];



#while(defined($line = <SOCK>)) {
#    print "@line1\n";
#}

close (SOCK) || die "close: $!";
exit;
