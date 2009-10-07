#!/usr/bin/perl -w
# Karol Barski grupa 511A

die("za malo argumentow\n") if @ARGV < 3;

my $filein = $ARGV[0];
my $filematch = $ARGV[1];
my $fileswitch = $ARGV[2];
my $case = ' ';
if(@ARGV==4 and $argv[3]eq"-i") {
	$case = "i";
}

my %matches;

open(IN,"<$filematch") or die "problem z plikiem $filematch";
open(IN1,"<$fileswitch") or die "problem z plikiem $fileswitch";

 WORD: foreach $word ( <IN> ) {
	 $word1 = <IN1>;
	 my ($wordt,@rest) = split("\n",$word);
#    WORD1: foreach $word1 ( <IN1> ) {
#  	   if ( $word1 =~ /^$/ ) { next WORD1; }
#  	   else { last WORD2 ; };
#    }
	 my ($word1t,@rest1) = split("\n",$word1);
	 if ( $word =~ /^$/ ) { next WORD;};
	 $matches{$wordt} = $word1t;
#	 print("$wordt $word1t\n");
 }

close (IN);
close (IN1);

 open (IN,"<$filein") or die "problem z plikiem $filein"; 
 open (OUT,">$filein.new") or die "problem z plikiem $filein.new"; 

foreach $line ( <IN> ) {
 	foreach $index ( keys(%matches) ) {
 		print("$index $matches{$index}\n");
		$line =~ s/($index)/$matches{$1}/g."$case";
 	}
	syswrite(OUT,$line);
 }
