#!/usr/bin/perl
use strict;
use warnings;

use File::Path "mkpath";
use File::Copy "move";

require "./lib/StdLfsLib.pl";

BEGIN {
	require "./config.pl";
	$ENV{HOME} = $LfsConfig::config{GITOLITE_HOME};
	$ENV{GL_BINDIR} = $LfsConfig::config{GITOLITE_BIN};
	$ENV{GL_LIBDIR} = $LfsConfig::config{GITOLITE_LIB};
}

use lib $ENV{GL_LIBDIR};
use Gitolite::Easy;
use Gitolite::Rc;

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
$oid =~ s/^.+?info\/lfs\/upload\///g;
if ($oid !~ /[0-9a-f]{64}/) {
	&StdLfsLib::error_exit("400 Bad Request","Invalid oid.");
}

# Permission check.
if (!Gitolite::Easy::can_write($repo)) {
	&StdLfsLib::error_exit("403 Forbidden","Your account is read only.");
}

if(!defined($rc{UMASK})) {
	print STDERR ".gitolite.rc could not be read.\n";
	&StdLfsLib::error_exit("501 Not Implemented","Server error,Check the log file.");
}

# Setting umask.
umask($rc{UMASK});

eval {
  mkpath("$LfsConfig::config{REPO_DIR}/${repo}.lfs");
};
if ($@) {
	print STDERR "Could not be create the directory.";
	&StdLfsLib::error_exit("501 Not Implemented","Server error,Check the log file.");
}

my $path = "$LfsConfig::config{REPO_DIR}/${repo}.lfs/${oid}";
# 1 = LOCK_SH
# 2 = LOCK_EX
# 5 = LOCK_SH | LOCK_NB
# 6 = LOCK_EX | LOCK_NB
# 8 = LOCK_UN
open(my $fp,">", "${path}.tmp");
flock($fp,2);

# Set binaly mode.
binmode($fp);
binmode(STDIN);

my $buf;
while(read(STDIN, $buf, $LfsConfig::config{UPLOAD_BUFFER_SIZE})) {
	print $fp $buf;
}

# unlock and close.
flock($fp,8);
close($fp);

# rename file.
move("${path}.tmp",${path});

print "Status: 200 OK\n\n";
exit(0);