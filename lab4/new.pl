#!/usr/bin/perl
#use strict;
use Socket;

# Let's take the target POP server's name!
print "POP server[mail.o2.pl]: ";
chop($popserver = <STDIN>);
if ($popserver eq "")
{
   # taking the default hosename!
   $popserver = "mail.o2.pl";
}

# Ok, let's take the username! Default is current username
$default_username = getpwuid $<;
print "username at $popserver [$default_username]: ";
chop($username = <STDIN>);
if ($username eq "")
{
   # Ok, taking the default user ID
   $username = $default_username;
}

# Ok, now let's take the passwd!
# getting the password by turning the echo off
system "stty -echo";
print "Enter password for $username\@$popserver: ";
chop($password = <STDIN>);
print "\n";
system "stty echo";

$port = 110;
if ($port =~ /\D/) { $port = getservbyname($port,'tcp') } die "No port" unless $port;

$iaddr = inet_aton($popserver) || die "no host: $remote";
$paddr = sockaddr_in($port, $iaddr);

$proto = getprotobyname('tcp');
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCK, $paddr) || die "connect: $!";
@line = split(' ',<SOCK>);

select(SOCK);
$|=1;
select(STDOUT);

#my $resp = $line[0];
if ( $line[0] == "+OK" ) {
	print "@line[0]\n";
	print "OK\n";
	
	print SOCK "USER $username\n";
	@line = split(' ',<SOCK>);
	if 
	print "@line\n";
	print SOCK "PASS $password\n";
	@line = split(' ',<SOCK>);		
	print "@line\n";
	print SOCK "STAT\n";
	@line = split(' ',<SOCK>);		
	print "$line[0] $line[1] $line[2] \n";
} elsif  ( $resp == "-ERR" ) {
	print "ERR\n";
} else {
	print "co to k... jest $resp\n";
}

close (SOCK) || die "close: $!";
exit;
