#!/usr/bin/perl
use utf8;
use strict;
use warnings;

use CGI;
use JSON;

require "./lib/StdLfsLib.pl";

my $cgi = CGI->new;
my $data = $cgi->param("POSTDATA");
my $json;
eval {
	$json = decode_json( $data );
} or do {
	&StdLfsLib::error_exit("400 Bad Request","Invalid json.");
};

# Geting page url.
my $url = "$ENV{REQUEST_SCHEME}://$ENV{SERVER_NAME}";
if ($ENV{SERVER_PORT} != (defined($ENV{HTTPS}) ? 443 : 80)) {
	$url .= ":$ENV{SERVER_PORT}"
}
$url .= "$ENV{REQUEST_URI}";
# https://example.com/hoge.git/info/lfs/objects/batch -> https://example.com/hoge.git/info/lfs
$url =~ s/\/objects\/batch(?:.+)?//g;

my @objects = ();
foreach my $obj (@{$json->{objects}}) {
	my $oid = (defined($obj->{oid}) ? $obj->{oid} : -1 );
	my $size = (defined($obj->{size}) ? $obj->{size} : -1 );

	if ($oid !~ /[0-9a-f]{64}/) {
		push(@objects, {
			oid => $oid,
			size => $size,
			error => {
				code => 400,
				message => "Invalid oid.",
			},
		});
		next;
	}

	if(0 > $size) {
		push(@objects, {
			oid => $oid,
			size => -1,
			error => {
				code => 400,
				message => "Invalid object size.",
			},
		});
		next;
	}

	my %actions = (
		upload => {
			href => "${url}/upload/$oid",
		},
		download => {
			href => "${url}/download/$oid",
		},
	);
	if(defined($ENV{HTTP_AUTHORIZATION})) {
		# SetEnvIf Authorization .+ HTTP_AUTHORIZATION=$0
		$actions{upload}{header} = {
			Authorization => $ENV{HTTP_AUTHORIZATION},
		};
		$actions{download}{header} = {
			Authorization => $ENV{HTTP_AUTHORIZATION},
		};
	}

	push(@objects, {
		oid => $oid,
		size => $size,
		actions => {
			%actions,
		},
	});
}
print "Content-Type: application/vnd.git-lfs+json\n\n";
print encode_json({
	objects=> \@objects,
});
