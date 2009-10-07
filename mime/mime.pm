#!/usr/bin/perl -w

use base64;

sub encode_quoted_printable
{
    my $text = shift;
    $text =~ s/([\200-\377=])/sprintf( "=%02x", ord($&) )/eg;
    $text =~ s/([\t' '](\n))/sprintf( "=%02x", ord($&) ).$2/eg;
    return $text;;
}

sub decode_quoted_printable
{
    my $text = shift;
    $text =~ s/=([0-9a-fA-F]{2})/chr(hex $1)/eg;
    $text =~ s/=\n//eg;
    return $text;
}

sub encode
{
    my ($encoding, $text) = @_[0..1];

    if ($encoding =~ /^base64$/i ) {
        return bin2base64( $text );
    } elsif ($encoding =~ /quoted-printable/i) {
        return encode_quoted_printable( $text );
    } else {
        return $text;
    }
}

sub decode
{
    my ($encoding, $text) = @_[0..1];

    if ($encoding =~ /^base64$/i ) {
        return base642bin( $text );
    } elsif ($encoding =~ /^quoted-printable$/i) {
        return decode_quoted_printable( $text );
    } else {
        return $text;
    }
}

sub MIME_encode_part
{
    my ($type_major,$type_minor,$type_options,
        $encoding, $body, @disposition) = @_[0..6];

    my $encbody = encode( $encoding, $body );

    my $displine = "";

    if ( $disposition[0] == "attachment" ) {
        $displine = 
            "Content-Disposition: attachment;" .
            " filename=\"$disposition[1]\"\n"
    }

    my $str = 
        "Content-Type: $type_major/$type_minor; $type_options\n" .
        "Content-Transfer-Encoding: $encoding\n" .
        $displine . "\n" . $encbody . "\n";

    return $str;
}

sub MIME_encode
{
    my ($type, @parts) = @_;
    my $boundary = sprintf( "-----=_=_%x_=_%x=_=_------", 
                            int(rand(99999999)), 
                            time);

    my $headers = 
        "MIME-Version: 1.0\n" .
        "Content-Type: $type; boundary=\"$boundary\"\n";


    my $str = "This is a multi-part message in MIME format.\n";

    for $part (@parts) {
        $str .= "\n--$boundary\n" . $part;
    }

    $str .= "\n--$boundary--\n";

    return ($headers,$str);
}

sub MIME_decode_part
{
    my $mime = shift;
    my @result;
	my $decoded;
	my $fileout;
#	print("$mime\n");
    if ( $mime =~ /Content-Type:\s*(\w+)\/([\w-]+);\s*\n?\s*((.*\n?)*)/i ) {
        my ($type_major,$type_minor,$rest)=($1, $2, $3);
#		print("type_major,type_minor,rest $type_major,$type_minor,$rest\n");
		$mime =~ /Content-Transfer-Encoding:\s*(.*)/i;
		$encoding = $1;
#		print("encoding $encoding\n");
		
		if ( $mime =~ /Content-Disposition:\s*([^;]*)(;\n?\s+(.+))*(\n{2})((.*\n?)*$)/i ) {
			my ($disposition,$disposition_options,$text)=($1, $3, $5);
#			print("disposition_options $disposition_options\n");
			$disposition_options =~ /filename=\"(.*)\"/i;
			$fileout = $1;
			$decoded = decode( $encoding, $text );
		} elsif ( $mime =~ /Content-Type:\s*(\w+)\/(\w+);(\n?.+)*(\n{2})((.*\n?)*$)/i ) {
			my $text = $5;
			$fileout = "message.txt";
			$decoded = decode( $encoding, $text );
		};
        @result = ($fileout,$decoded);
    } else {
        @result = ("Bad MIME part",$mime,"","","","");
    }
    return @result;
}

sub MIME_decode
{
	my $message = shift;
    my @result;

    if ( $message =~ m/MIME-Version:\s*([0-9])+\.([0-9]+)\s*(\(.*\))?/i ) {
        my ($vmin,$vmaj,$comment) = ($1,$2,$3);
		print("vmin,vmaj,comment $vmin,$vmaj,$comment\n");
		
		if ($message =~ m/Content-Type:\s*(multipart)\/(mixed);\s*boundary=\"(.*)\"/i) {
			my ($type,$subtype,$boundary) = ($1,$2,$3);
			print("type,subtype,boundary $type,$subtype,$boundary\n");

			my ($body,@rest) = split( "--$boundary--", $message);

			my @parts = split( "--$boundary", $body );
			shift @parts;

			foreach $part( @parts ) {
				print("part\n $part\npart\n");
				push @result, MIME_decode_part( $part );
			}
		} elsif ($message =~ s/Content-Type:\s*(.*)\/(.*);\s*(.*)/$&/i) {
			push @result, MIME_decode_part( $message );
		} else { 
			print("Bad MIME headers");
			return "Bad MIME headers";
		}
    } else {
		print("No MIME headers");
        return "No MIME headers";
    }

    return @result;
}

return true;
