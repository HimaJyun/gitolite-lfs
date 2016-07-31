#!/bin/bash
export GITOLITE_HTTP_HOME="/var/git"
export GIT_PROJECT_ROOT="${GITOLITE_HTTP_HOME}/repositories"
export GIT_HTTP_EXPORT_ALL=1

cd lfs/
if [[ "${REQUEST_URI}" =~ ^/(.+)\.git/info/lfs/objects/batch$ && "${REQUEST_METHOD}" = "POST" ]];then
	exec ./info.pl
elif [[ "${REQUEST_URI}" =~ ^/(.+)\.git/info/lfs/download/ && "${REQUEST_METHOD}" = "GET" ]];then
	exec ./download.pl
elif [[ "${REQUEST_URI}" =~ ^/(.+)\.git/info/lfs/upload/ && "${REQUEST_METHOD}" = "PUT" ]];then
	exec ./upload.pl
else
	cd ../
	exec ${GITOLITE_HTTP_HOME}/bin/gitolite-shell
fi