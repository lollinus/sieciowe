#/usr/local/bin/perl -w

require 5.002;

use Socket;
 
#
# configuration parameters for the service
#

# server to connect to
$server="millennium";
$passwd="passwd";
$port=6667;

# information about the service
$myname = "toto";
$mydist = "*";
$mytype = 0;
$myinfo = "Sample Service";
$admin = "name <e-mail>";

#
# set up connection
#
$iaddr = inet_aton($server) || die "no host: $server";
$paddr = sockaddr_in($port, $iaddr);
$proto = getprotobyname('tcp');
socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
connect(SOCK, $paddr) || die "connect: $!";

select SOCK; $| = 1;
select STDOUT;

#
# register
#
print SOCK "PASS $passwd\nSERVICE $myname $server $mydist $mytype 0 :$myinfo\n";

#
# proceed
#
while (<SOCK>)
{
	chop;
	if ( /^ERROR/ )
	{
		print "$_\n";
	}
	elsif ( /:(\S*) SQUERY \S* :(.*)$/ )
	{
		($nick , $query) = ($1, $2);
		print "Query from $nick: $query\n";	
		if ( $query =~ /^HELP/i )
		{
			print SOCK "NOTICE $nick :I'm a dumb service\n";
			print SOCK "NOTICE $nick :Commands: HELP, ADMIN\n";
		}
		elsif ( $query =~ /^ADMIN/i )
		{
			print SOCK "NOTICE $nick :Admin: $admin\n";
		}
		else
		{
			print SOCK "NOTICE $nick :Command not understood, try HELP\n";
		}
	}
	else
	{
		print "Unknown data: $_\n";
	}
}

close (SOCK) || die "close: $!";
exit;

