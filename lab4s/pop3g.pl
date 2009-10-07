#!/usr/bin/perl
use Net::POP3;

# Let's take the target POP server's name!
print "POP server[192.168.1.1]: ";
chop($popserver = <STDIN>);
if ($popserver eq "")
{
   # taking the default hosename!
   $popserver = "192.168.1.1";
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


# Shows popserver and username
print "Ok, now trying to get connected to $popserver ....\n";

# Let's call the constructor with one value!
$remoteserver = new Net::POP3($popserver);
if (! $remoteserver)  # If the connection was a failure
{
   # Let's be gentle! Not required!
   print "Sorry, dude. Couldn't connect to $popserver...\n";
   print "Check whether your popserver($popserver) is alive or not.\n";
   print "\n";
   print "        ping $popserver       \n";
   print "\n";
   print "will be a nice try.\n";
   exit 1;
}
else
{
   print "Connected successfully to $popserver\n";
}

# Now let's see how many mails are there in $remoteserver
print "Now trying to login...\n";
$total_message = $remoteserver->login($username, $password);
if ($total_message eq "")
{
   print "Sorry Bro! Login failed! Try another session\n";
}
elsif ($total_message > 0)
{
   print "You got $total_message mail(s) in $popserver\n";
}
else
{
   print "Sorry dude, you don't have any message in $popserver!\n";
}

# Ok, let's close the connection according to the rule!
print "Closing the connection from $popserver now...\n";
$remoteserver->quit();

# Ok, let's play by the book. 
#             exiting with a 0 means success,
#             exiting with a 1 means failure! 
exit 0;
