#!/usr/bin/perl

use Socket;

sub login_mail
{
    my $resp = shift;
    if ( $resp = ) {
    } elseif () {
    } else {
    }
    
}

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
login_mail $line[0];

#while(defined($line = <SOCK>)) {
    print "@line1\n";
#}

close (SOCK) || die "close: $!";
exit;
