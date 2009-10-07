#!/usr/bin/perl -w
use Socket;

my %months;
$months{Jan}=0;
$months{Feb}=1;
$months{Mar}=2;
$months{Apr}=3;
$months{May}=4;
$months{Jun}=5;
$months{Jul}=6;
$months{Aug}=7;
$months{Sep}=8;
$months{Oct}=9;
$months{Nov}=10;
$months{Dec}=11;

sub get_host {
	print "FTP server[ftp.wi.ps.pl]: ";
	chop(my $host = <STDIN>);
	if ($host eq "") {
		# domy¶lny adres
		$host = "ftp.wi.ps.pl";
	}
	print "path [~] ";
	chop(my $path = <STDIN>);
	if ($path eq "") {
		# domy¶lny adres
		$path = "~";
	}
	return ($host,$path);
}

#user
sub get_user {
	my $ftpserver = shift;
	my $default_username = getpwuid $<;
	print "username at $ftpserver [$default_username]: ";
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

sub check_resp {
#	print("check_resp\n");
	my $line = <SOCK>;
	my $resp = $line;
	if ( $line =~ /(^\d{3})(.)/ ) {
		$resp.=read_rest($1) if $2 eq "-";
		print("$resp\n");
		return $resp;
	} elsif ( $line !~ /(^\d{3})/ ) {
		die("z³a odpowied¼ serwera $line\n");
	}
}

sub read_rest {
#	print ("read rest\n");
	my $code = shift;
	my $rest = "";
	while ( ($line=<SOCK>) !~ /^$code\s/ ) {
		$rest.=$line;
	}
	$rest.=$line;
	return $rest;
}

sub make_data_connect {	
#	print("make_data_connect\n");
	my $server = shift;
	my $port = shift;
#	if ($port =~ /\D/) { $port = getservbyname( $port ,'tcp') }
#	$port = getservbyname( 'ftp' ,'tcp');
	die "z³y numer portu: $port\n" unless $port;
	my $iaddr = inet_aton($server) || die "no host: $server";
	my $paddr = sockaddr_in($port, $iaddr);
	my $proto = getprotobyname("tcp");
	socket(DATA, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
	connect(DATA, $paddr) || die "connect: $!";
#	print("make_data_connect end\n");
	return DATA;
}

sub make_connect {
#	print("make_connect\n");
	my $server = shift;
	my $port = shift;
	if ($port =~ /\D/) { $port = getservbyname( $port ,'tcp') }
#	$port = getservbyname( 'ftp' ,'tcp');
	die "z³y numer portu: $port\n" unless $port;
	my $iaddr = inet_aton($server) || die "no host: $server";
	my $paddr = sockaddr_in($port, $iaddr);
	my $proto = getprotobyname("tcp");
	socket(SOCK, PF_INET, SOCK_STREAM, $proto) || die "socket: $!";
	connect(SOCK, $paddr) || die "connect: $!";
	return SOCK;
}

sub set_passive {
#	print "passive\n";
	syswrite(SOCK,"PASV\n");
	$resp = check_resp();
	if ( $resp =~ /(\d+),(\d+),(\d+),(\d+),(\d+),(\d+)/ )
    { 
		$ip = "$1.$2.$3.$4";
		$port = $5*256 + $6;
		print "ip $ip\n";
		print "port $port\n";
    } else {
		die "blad ustawienia trybu pasywnego\n $resp \n";
	}
    print "Po³±czenie danych: $ip:$port\n";
	make_data_connect($ip, $port);
#	check_resp();
#	print ("passive end\n");
}

#login
sub make_login {
#	print "login\n";
	my $server = shift;
	my $code;
	do {
		my $user = get_user($server);
		syswrite(SOCK,"USER $user\n");
		check_resp();
		my $pass = get_pass($user, $server);
		syswrite(SOCK,"PASS $pass\n");
		check_resp() =~ /(^\d{3})/;
		$code = $1;
	} while( $code eq '530' );
## zalogowalismy sie ustawiamy tryb pasywny

	return 0;
}

sub list {
#	print("list\n");
	local %files;
	set_passive();
	print "LIST\n";
	syswrite(SOCK,"LIST\n");
	foreach $line ( <DATA> ) {
		print ("$line");
		if ( $line =~ /^(.)\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
#			print ("nazwa $5 ");
			#godzina lub rok
#			print ("godz $4");
			$files{$5}[0] = $4;
			# dzieñ
#			print ("dzien $3");
			$files{$5}[1] = $3;
			# miesi±c
#			print ("mies $2");
			$files{$5}[2] = $2;
			# typ pliku
#			print ("typ $1\n");
			$files{$5}[3] = $1;			
		}
	}
	check_resp();
	close(DATA);
	check_resp();
	return %files;
}

sub get_file {
	$file = shift;
	print "Downloading file: $file\n";
	set_passive();
	syswrite(SOCK,"TYPE I\n");
	check_resp();
	
	syswrite(SOCK,"RETR $file\n");
	open(WY,">$file");
	foreach $pack ( <DATA> ) {
		syswrite(WY,$pack);
	}
	check_resp();
	close(DATA);
	check_resp();
	close(WY);
}

sub get_newer {
	print("get_newer\n");
    local %files = list();
    local @files1 = (keys %files);

FILE:foreach $file (@files1) {
        if ( $files{$file}[3] eq "d" ) {
 			print "Katalog: $file\n";
  			syswrite(SOCK, "CWD $file\n");
  			check_resp() =~ /^(\d{3})/;
  			die "blad zmiany katalogu zdalnego $file" unless $1 == 250;
			mkdir($file,0777);
			chdir($file) or die "nie mo¿na otworzyc katalogu: $file\n";
			get_newer();
			chdir "..";
  			syswrite(SOCK, "CWD ..\n");
  			check_resp();
        } else {
            ($mtime) = (stat($file))[9];
#			print ("$file (mtime) ($mtime)\n");

			($min,$hour,$mday,$mon,$year) = (gmtime($mtime))[1,2,3,4,5];
			$year+=1900;
#			print ("min,hour,mday,mon,year $min,$hour,$mday,$mon,$year\n");
			if ( $files{$file}[0] =~ /(\d{2}):(\d{2})/ ) {
				# je¶li godzina to plik by³ utworzony w przeci±gu ostatniego roku
				# je¶li miesi±c bierz±cy jest mniejszy ni¿ miesi±c pliku to zosta³ on utworzony w poprzednim roku
				($thismonth,$thisyear) = (gmtime())[4,5];
				if ( $thismonth < $months{$files{$file}[2]} ) {
					$thisyear--;
				}
				print ("czas na serwerze zawiera godzinê: $file $files{$file}[0]\n");
				$smin = $2;
				$shour = $1;
# 				print ("mies $mon $months{$files{$file}[2]}\n");
# 				print ("dzien $mday $files{$file}[1]\n");
# 				print ("godz $hour $shour\n");
# 				print ("min $min $smin\n");
				if ( $year > $thisyear ) {
					print ("rok\n");
					next FILE;
				} elsif ( $mon > $months{$files{$file}[2]}) {
					print ("mies\n");
					next FILE;
				} elsif ( $mon == $months{$files{$file}[2]} and $mday > $files{$file}[1] ) {
					print ("dzien\n");
					next FILE;
				} elsif ( $mday == $files{$file}[1] and $hour > $shour ) {
					print ("godz\n");
					next FILE;
				} elsif ( $hour == $shour and $min >= $smin ) {
					print ("min\n");
					next FILE;
				}
			} elsif ( $files{$file}[0] =~ /\d{4}/ ) {
# 				print ("czas na serwerze zawiera rok: $file $files{$file}[0]\n");
# 				print ("rok $year $files{$file}[0]\n");
# 				print ("mies $mon $months{$files{$file}[2]}\n");
# 				print ("dzien $mday $files{$file}[1]\n");
				if ( $year > $files{$file}[0] ) {
					print ("rok\n");
					next FILE;
				} elsif ( $year == $files{$file}[0] and $mon > $months{$files{$file}[2]}) {
					print ("mies\n");
					next FILE;
				} elsif ( $mon == $months{$files{$file}[2]} and $mday >= $files{$file}[1] ) {
					print ("dzien\n");
					next FILE;
				}
			} else {
				printf ("czas na serwerze zawiera: $file $files{$file}[0]\n");
				next FILE;
			}

			get_file($file);
        }
    }
}

(my $ftpserv, my $path) = get_host();
my $control = make_connect($ftpserv, 'ftp');
check_resp($control);

select(SOCK);
$|=1;
select(STDOUT);

make_login($ftpserv);
syswrite(SOCK,"CWD $path\n");
die "blad zmiany katalogu zdalnego: $path\n" unless check_resp($control) =~ /^250/ ;

get_newer();

close(SOCK);
exit;
