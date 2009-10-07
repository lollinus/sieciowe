#!/usr/bin/perl -w

use Socket;

sub check_resp {
	$sock = shift;
	$resp = <$sock>;
#	print("status $resp\n");
	
	$resp =~ m/^(\d{3})(.*)/;	
	$respkod = $1;
	$respmess = $2;
	if ( $respkod =~ m/^2/ ) {
#		print("status OK $respmess\n");
	} 
	elsif ( $respkod =~ m/^354/ ) {
		print("status OK $respmess\n");
		print("wysy³anie wiadomo¶ci\n");
	} 
	else {
		die("staus not OK $respmess");
	}
}

sub send_smtp {
	my $from = shift;
	my $to = shift;
	my $message = shift;
	($rcpt, $server) = split('@', $to);
	my $port = getservbyname( "smtp", "tcp" );
	die "No port" unless $port;
	my $iaddr = inet_aton($server) || die "no host: $server";
	my $paddr = sockaddr_in($port, $iaddr);
	my $proto = getprotobyname("tcp");
	socket(SOCKET, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";

	connect(SOCKET, $paddr) || die "connect: $!";
	check_resp( SOCKET );

	syswrite(SOCKET, "HELO localhost\n");
	check_resp( SOCKET );

	syswrite(SOCKET, "mail from: $from\n");
	check_resp( SOCKET );

	syswrite(SOCKET, "rcpt to: $to\n");
	check_resp( SOCKET );

	syswrite(SOCKET, "data\n");
	check_resp( SOCKET );


	syswrite(SOCKET, "From: $from\nTo: $to\n$message\n.\n");
	check_resp( SOCKET );

	syswrite(SOCKET, "quit\n");
	check_resp( SOCKET );

	close(SOCKET);
#	return SOCKET;
}

sub readfile {
	my $name = shift;
	open(WE,$name) or die "problem z otwarciem pliku wejsciowego $name\n";
#	open( WE, $name);
	@file = <WE>;
	my $data = "";
	foreach $line ( @file ) {
		$data.=$line;
	}
	close(WE);
	return $data;
}

sub attach {
	my $message = shift;
#	print("message:\n $message\n");
#	my @files = shift;
	my $file = shift;

	$message.="\n";
	$message.=readfile("uuencode $file $file|");
	
#	foreach $file ( @files ) {
#		print("Attaching: $file\n");
#		$message.=readfile("uuencode $file $file|");
#	}
	return $message;
}
	
sub get_email {
	my $type = shift;
	print "podaj adres $type\n";
	my $def_user = getpwuid $<;
	print "$type [lollinus\@o2.pl]: ";
	chop(my $host = <STDIN>);
	if ( $host =~ m/^\s*$/ )
	{
		# domy¶lny adres
		$host = "lollinus\@mail.o2.pl";
	}

	return $host;
}

my $mess = readfile(shift @ARGV);
my $from = get_email("nadawca");
my $to = get_email("odbiorca");

foreach $file ( @ARGV ) {
	print("Do³±czanie: $file\n");
	$mess = attach($mess, $file);
}
#attach($mess, @ARGV);

send_smtp($from,$to,$mess);
