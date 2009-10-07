#!/usr/bin/perl

use base64;

bin2base64("test.bin","test.out");
base642bin("test.out","test.bin2");
