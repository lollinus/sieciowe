#!/usr/bin/perl
use Socket;

$DEBUG = 0;

sub send_mail
{
    $addr = shift;
    $port = getservbyname( "smtp", "tcp" );
    die "No port for smtp" unless $port;
    $ip = inet_aton( $addr );
    $proto = getprotobyname('tcp');
    socket( SOCK, PF_INET, SOCK_STREAM, $proto );
    $service = sockaddr_in( $port, $ip );
    connect( SOCK, $service ) or die "Can't connect to $addr";

    $envelope = shift;

    syswrite SOCK, $envelope."QUIT\n";

    local $resp;

    while( ($line=<SOCK>) ) {
        print "DBG: recv line: $line\n" if ($DEBUG);
	$resp.=$line;
    }

    return $resp;
}

sub prepare_envelope
{
    local $sender = 'kjedruczyk@wi.ps.pl';
    local $subject = "test message";
    local $addr = shift;
    local $body = shift;

    return "HELO localhost\nMAIL FROM: $sender\nRCPT TO: $addr\n".
        "DATA\n$body\n.\n";
}

sub getfile
{
    $file = shift;

    open HANDLE, $file;

    local $data = "";

    while( ($line=<HANDLE>) ) {
	$data.=$line;
    }
    return $data;
}

($addr, $body) = @ARGV[0..1];

($user,$server) = split( "@", $addr );

$server = "localhost";
print "$user @ $server\n";

$body = getfile "$body";

for( $a = 2; $a < @ARGV; $a++ ) {
    $file = @ARGV[$a];
    printf "Attachment: $file\n";
    $body.= getfile "uuencode $file $file|";
}

print $body;

$envelope = prepare_envelope $addr, $body;
print "Connecting to $server\n";
send_mail $server, $envelope;
