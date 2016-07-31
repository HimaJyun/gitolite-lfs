#!/usr/bin/perl
package StdLfsLib;

use strict;
use warnings;

use JSON;

sub error_exit {
	my $code = defined($_[0]) ? $_[0] : "200 OK";
	my $message = defined($_[1]) ? $_[1] : "Unknown error!!" ;

	print "Status: ${code}\n";
	print "Content-Type: application/vnd.git-lfs+json\n";
	print "\n";
	print encode_json({
		message => $message,
	});

	exit(0);
}

1;