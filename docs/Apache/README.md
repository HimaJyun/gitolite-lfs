# for Apache
gitolite-lfs (and Gitolite with SmartHTTP) configuration for Apache

## Apache
1. Install suEXEC  
   `sudo apt-get install apache2-suexec-custom`
1. Adjust the Permission.
```bash
find /var/www/git/ | sudo xargs chown git:git
find /var/www/git/ | sudo xargs chmod 0700
# for .htpasswd
sudo chmod 0755 /var/www/git/
sudo chmod 0644 /var/www/git/.htpasswd
```

1. Enable module  
   `sudo a2enmod suexec`
1. Apache setup.  
   `sudo editor /etc/apache2/sites-available/git.conf`  
   Please see the example.conf......

## Using X-Sendfile
Install mod_xsendfile.  
`sudo apt-get install libapache2-mod-xsendfile`

Tips:  
allow read access for [apache executer].
```
sudo editor /var/git/.gitolite.rc
UMASK => 0077 to UMASK => 0027
sudo install -d -m 0750 -o git -g git /var/git/lfs
sudo chmod g+rx -R /var/git/lfs/
sudo gpasswd -a www-data git
```
