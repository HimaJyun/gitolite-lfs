#!/usr/bin/perl
package LfsConfig;
use strict;
use warnings;

our %config = (
	GITOLITE_HOME => "$ENV{GIT_PROJECT_ROOT}/..",
	GITOLITE_BIN => "$ENV{GIT_PROJECT_ROOT}/../bin",
	GITOLITE_LIB => "$ENV{GIT_PROJECT_ROOT}/../bin/lib",

	REPO_DIR => "$ENV{GIT_PROJECT_ROOT}/../lfs",

	# git-lfs up/download buffer size.
	UPLOAD_BUFFER_SIZE => 1024,
	DOWNLOAD_BUFFER_SIZE => 1024,
	
	# Use X-Sendfile(or X-Accel-Redirect)
	#X_SENDFILE => "X-Sendfile",
	# Nginx only.
	#NGX_ACCEL_PATH => "lfsdownload",
);

1;