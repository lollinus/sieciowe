#!/usr/bin/perl
use Socket;
my $EOL = "\015\012";

sub check_resp {
	my $sock = shift;
	@line = split(' ', <$sock>);
	if ( $line[0] == "+OK" )
	{
#		print "odpowie¼ poprawna $line[0]\n";
		return 0;		
	}
	elsif ( $line[0] == "-ERR" )
	{
#		print "odpowie¼ poprawna $line[0]\n";
		return 1;		
	}
	else
	{
		die "niepoprawna odpowie¼ serwera @line\n";
	}
}

sub get_host {
	print "POP server[mail.o2.pl]: ";
	chop(my $host = <STDIN>);
	if ($host eq "")
	{
		# domy¶lny adres
		$host = "mail.o2.pl";
	}
	
	return $host;
}

#user
sub get_user {
	my $popserver = shift;
	my $default_username = getpwuid $<;
	print "username at $popserver [$default_username]: ";
	chop(my $username = <STDIN>);
	if ($username eq "")
	{
		# Ok, taking the default user ID
		$username = $default_username;
	}
	
	return $username;
}

#passe³ko
sub get_pass {
	my $username = shift;
	my $server = shift;
	system "stty -echo";
	print "Enter password for $username\@$server: ";
	chop(my $password = <STDIN>);
	print "\n";
	system "stty echo";

	return $password;
}

sub make_connect {
	my $server = shift;
	my $port = shift;
	if ($port =~ /\D/) { $port = getservbyname( $port ,'tcp') }
	die "No port" unless $port;
	my $iaddr = inet_aton($server) || die "no host: $server";
	my $paddr = sockaddr_in($port, $iaddr);
	my $proto = getprotobyname("tcp");
	socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
	connect(SOCKET, $paddr) || die "connect: $!";

	check_resp(SOCKET);

	return SOCKET;
}

#login
sub make_login {
	print "login\n";
	my $sock = shift;
	my $server = shift;
	my $user = get_user($server);
	my $pass = get_pass($user, $server);

	do {
		print $sock "USER $user\n";
		check_resp($sock);
		print $sock "PASS $pass\n";
	} while check_resp($sock) == 1;

	return 0;
}

sub get_messages {
	my $sock1 = shift;
	print $sock1 "STAT\n";
	my @line;
	@line = split(' ',<$sock1>);		
#	print "$line[0] $line[1] $line[2]\n";

	print "masz $line[1] wiadomo¶ci zajmuj± one $line[2] bajtów \n";
	for (my $i=1; $i <= $line[1]; $i++)
	{
		print $sock1 "RETR $i\n";
		check_resp($sock1);
		open(WY,">wiadomosc.$i") or die "problem z otwarciem pliku wyjsciowego wiadomosc.$i\n";
		while ( ($message = <$sock1>) ne ".$EOL" ) {
			if ( $message =~ /^[Ss][Uu][Bb][Jj][Ee][Cc][Tt]/ ) {
				$subject = $message;
			}
			print WY "$message";
		}
		close(WY);
		print "czy usun±æ wiadomo¶æ $i? ";
		print "$subject";
		command $sock, "DELE $i" if <STDIN>=~ /^[Yy][Ee][Ss]$/;
	}
}


# begin pop retrieve
my $popserver = get_host();
my $socket = make_connect($popserver, "pop3");

select($socket);
$|=1;
select(STDOUT);

make_login($socket, $popserver);

get_messages($socket);

close ($socket) || die "close: $!";
exit;
