#!/usr/bin/perl

@ARGV>0 or die "ihijh";

my @dir;

opendir(hDir,"$ARGV[0]");

@dir = readdir(hDir);

print "@dir\n";

foreach $i (@dir) {
    print $i."\n";    
}



