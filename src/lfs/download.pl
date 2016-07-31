#!/usr/bin/perl
use strict;
use warnings;

require "./lib/StdLfsLib.pl";

BEGIN {
	require "./config.pl";
	$ENV{HOME} = $LfsConfig::config{GITOLITE_HOME};
	$ENV{GL_BINDIR} = $LfsConfig::config{GITOLITE_BIN};
	$ENV{GL_LIBDIR} = $LfsConfig::config{GITOLITE_LIB};
}

use lib $ENV{GL_LIBDIR};
use Gitolite::Easy;
use File::Spec;

# Getting user.
if(defined($ENV{REMOTE_USER})) {
	$ENV{GL_USER} = $ENV{REMOTE_USER};
} else {
	&StdLfsLib::error_exit("401 Unauthorized","Login require.");
}

# Getting repo name.
if($ENV{REQUEST_URI} !~ /^\/(.+)\.git\//) {
	&StdLfsLib::error_exit("400 Bad Request","Invalid repo.");
}
my $repo = ${1};

# Getting oid
my $oid = "$ENV{REQUEST_URI}";
$oid =~ s/^.+?info\/lfs\/download\///g;
if ($oid !~ /[0-9a-f]{64}/) {
	&StdLfsLib::error_exit("400 Bad Request","Invalid oid.");
}

# Permission check.
if (!Gitolite::Easy::can_read($repo)) {
	&StdLfsLib::error_exit("404 Not Found","Can not read.");
}

# File exists.
my $path = File::Spec->rel2abs("$LfsConfig::config{REPO_DIR}/${repo}.lfs/${oid}");
if(! -f $path) {
	&StdLfsLib::error_exit("404 Not Found","File not found.");
}

print "Content-Type: application/octet-stream\n";
if(defined($LfsConfig::config{X_SENDFILE})) {
	if(defined($LfsConfig::config{NGX_ACCEL_PATH})) {
		print "$LfsConfig::config{X_SENDFILE}: /$LfsConfig::config{NGX_ACCEL_PATH}/${repo}.lfs/${oid}\n\n";
	} else {
		print "$LfsConfig::config{X_SENDFILE}: ${path}\n\n";
	}
	exit(0);
}

print "Content-Length: ".(-s ${path});
print "\n\n";
# 1 = LOCK_SH
# 2 = LOCK_EX
# 5 = LOCK_SH | LOCK_NB
# 6 = LOCK_EX | LOCK_NB
# 8 = LOCK_UN
open(my $fp, ${path});
#flock($fp,1);

# Set binaly mode.
binmode($fp);
binmode(STDOUT);

my $buf;
while(read($fp, $buf, $LfsConfig::config{DOWNLOAD_BUFFER_SIZE})) {
	print $buf;
}

# unlock and close.
#flock($fp,8);
close($fp);
