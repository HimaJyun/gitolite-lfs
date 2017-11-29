# gitolite-lfs
[git-lfs](https://git-lfs.github.com/) implementation for [Gitolite](https://github.com/sitaramc/gitolite).  

I currently do not use this software and I do not update it...:cry:  
Please consider using other software if possible.([GitBucket](https://github.com/gitbucket/gitbucket)/[Gogs](https://gogs.io/)\([Gitea](https://gitea.io/en-US/)\)/[GitLab](https://about.gitlab.com/))

## Installation
Assumption
* Install to /var/www/git
* Gitolite has been installed in the /var/git
* Repository is located in /var/git/repositories
* gitolite-shell is located in /var/git/bin

1. Install the Gitolite.(This is not described here.)
1. Clone this project.  
`git clone https://github.com/HimaJyun/gitolite-lfs`
1. Add permission.  
`sudo chmod +x -R gitolite-lfs/src/`
1. Move the src/*  
`sudo mv gitolite-lfs/src/* /var/www/git/`
1. Please set.

### Settings.
gitolite-lfs.sh
```bash
# Gitolite home path.
export GITOLITE_HTTP_HOME="/var/git"
# Gitolite repository path.
export GIT_PROJECT_ROOT="${GITOLITE_HTTP_HOME}/repositories"
# Always 1;
export GIT_HTTP_EXPORT_ALL=1
```

lfs/config.pl
```perl
our %config = (
	# Gitolite home path.
	GITOLITE_HOME => "$ENV{GIT_PROJECT_ROOT}/..",
	# Gitolite bin path.
	GITOLITE_BIN => "$ENV{GIT_PROJECT_ROOT}/../bin",
	# Gitolite lib path.
	GITOLITE_LIB => "$ENV{GIT_PROJECT_ROOT}/../bin/lib",

	# lfs repo path.
	REPO_DIR => "$ENV{GIT_PROJECT_ROOT}/../lfs",

	# git-lfs up/download buffer size.
	UPLOAD_BUFFER_SIZE => 1024,
	DOWNLOAD_BUFFER_SIZE => 1024,

	# Use X-Sendfile(or X-Accel-Redirect)
	#X_SENDFILE => "X-Sendfile",
	# Nginx only.
	#NGX_ACCEL_PATH => "lfsdownload",
);
```
Configuring the Web server.   
Apache -> docs/Apache/README.md  
Nginx -> docs/Nginx/README.md

### Add the SSH command.
1. Open .gitolite.rc  
`sudo editor /var/git/.gitolite.rc`
1. Add [LFS_URL]  
`LFS_URL => "http://example.com/",`
1. Uncomment [LOCAL_CODE]  
`LOCAL_CODE => "$rc{GL_ADMIN_BASE}/local",`
1. Add the [git-lfs-authenticate] to [ENABLE]  
```perl
ENABLE => [
  'git-lfs-authenticate',
]
```
In your PC  

1. Clone the gitolite-admin repo.  
`git clone ssh://example.com/gitolite-admin.git;cd gitolite-admin`
1. Create local/commands  
`mkdir -p local/commands`
1. Place the git-lfs-authenticate  
`curl -o local/commands/git-lfs-authenticate https://raw.githubusercontent.com/HimaJyun/gitolite-lfs/master/commands/git-lfs-authenticate`
1. Commit and push  
```
git add local/commands/git-lfs-authenticate
git config core.filemode false
git update-index --add --chmod=+x local/commands/git-lfs-authenticate
git commit -am "Add git-lfs-authenticate command."
git push origin master
```
