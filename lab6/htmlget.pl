#!/usr/bin/perl -w
use Socket;

sub get_host {
	print "HTML server[http://www.wi.ps.pl/]: ";
	chop(my $host = <STDIN>);
	if ($host eq "") {
		# domy¶lny adres
		$host = "http://www.wi.ps.pl/index.php";
	}

	return $host;
}

sub html_get {
	$addr = shift;
	$command  = shift;
	$port = getservbyname( "http", "tcp" );
    die "No port for http" unless $port;
	$ip_addr = inet_aton($addr);
	$proto = getprotobyname('tcp');
	socket(SERV,PF_INET,SOCK_STREAM,$proto);
	$service = sockaddr_in($port, $ip_addr);
	connect(SERV,$service) or die "Can't connect to $addr";

	syswrite(SERV,$command."\n");
	my $resp;

	while($line = <SERV>) { 
#		print $line;
		$resp.=$line;
	}
	close SERV;
	return $resp;
}

sub get_file {
    $url = shift;
    if ( $url =~ /(http:\/\/)?([^\/]+)(.*)/i ) {
        $server = $2;
        $path = ( length($3) == 0 )? "/" : $3;
        return (html_get $server, "GET $path");
    } else {
        die "¼le sformu³owany adres ($url)";
    }
}

sub parse_html {
	$html = shift;
	$file = shift;

	$kopia = $html;
	open(WY,">orig") or die "problem z otwarciem pliku wyjsciowego $file\n";
	syswrite(WY, $html);
	close(WY);

	$kopia =~ s/<(img\s+[^>]*src\s*=)\"(http:\/\/)?([^\/]+)?(.*\/)?([^\/]+)\">/<$1\"$5\">/ig;

	if ( $file eq "" ) {
		$file = "index.html";
	}
	
	open(WY,">$file") or die "problem z otwarciem pliku wyjsciowego $file\n";
	syswrite(WY, $kopia);
	close(WY);

	@links = ($html =~ m/<a\s+[^>]*href\s*=[^>]*>/ig);
	my %links1;
	foreach $link ( @links ) {
        if ( $link =~ /<a\s+[^>]*href\s*=[\s\"]?([^\" ]*)[\s\"]?[^>]*>/i ) {
            $links1{ $1 } += 1;
        }
	}

	foreach $key ( keys %links1 ) {    
		printf "HREF: ".$key;
		printf " (". $links1{ $key }."x)" if $links1{ $key } > 1;
		print "\n";
	}


	@images = ($html =~ m/<img\s+[^>]*src\s*=[^>]*>/ig);
	my %images1;
	foreach $link ( @images ) {
        if ( $link =~ /<img\s+[^>]*src\s*=[\s\"]?([^\" ]*)[\s\"]?[^>]*>/i ) {
            $images1{ $1 } += 1;
        }
	}

	foreach $key ( keys %images1 ) {
		printf "IMG: ".$key."\n";
		if ( $key =~ /^http:\/\/(.*)\/(.*)$/i ) {
			$basename = $2;
			$url = $key;
		} elsif ( $key =~ /([^\/]+\/)*([^\/]+)/ ) {
			$basename = $2;
			$url = $url_server.$url_path.$key;
		} elsif ( $key =~ /\/(.*\/)?([^\/]+)/ ) {
			$basename = $2;
			$url = $url_server.$key;
		}
		print "Zapisywanie $url do $basename\n";
		$lfname = $basename;
#		$suffix = 1;
#		while( -e $lfname ) {
#			$suffix++;
#			$lfname = $2.".$suffix"
#			}
		open(DESC,">$lfname");
		syswrite(DESC, get_file($url));
		close(DESC);
		printf "Written $key as $lfname\n";
	}

	open(WY,">orig") or die "problem z otwarciem pliku wyjsciowego $file\n";
	syswrite(WY, $html);
	close(WY);

	$html =~ s/<(img\s+[^>]*src\s*=)\"(http:\/\/)?([^\/]+)?(.*\/)?([^\/]+)\">/<$1\"$5\">/ig;

	if ( $file eq "" ) {
		$file = "index.html";
	}
	
	open(WY,">$file") or die "problem z otwarciem pliku wyjsciowego $file\n";
	syswrite(WY, $html);
	close(WY);
}


my $host = get_host();

print "$host\n";

if ( $host =~ m/(http:\/\/[^\/]+)(.*\/)?([^\/]+)?/i ) {
    ($url_server, $url_path, $url_file) = ($1, $2, $3);
    if ( length($url_path) == 0 ) {
        $url_path = "/";
    }
}


#print get_file($host);

parse_html(get_file($host),$url_file);
#save_file($host);
#my $url = url_get();
