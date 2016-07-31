# for Nginx
gitolite-lfs (and Gitolite with SmartHTTP) configuration for nginx.

Tips:  
nginx is **not suitable** for such applications.  
If it is possible it is recommended that you use the *Apache*.  

## CGI setup.
1. Install *spawn-fcgi* and *fcgiwrap*  
   `sudo apt-get install spawn-fcgi fcgiwrap`
1. Get init script.
   ```
   cd /etc/init.d
   sudo curl -O https://raw.githubusercontent.com/HimaJyun/gitolite-lfs/docs/Nginx/gitolite-lfs
   sudo chmod +x gitolite-lfs
   ```
1. Open and settings.  
   `sudo editor /etc/init.d/gitolite-lfs`
1. Add a service.  
   `sudo systemctl enable gitolite-lfs`
1. Start daemon.  
   `sudo systemctl start gitolite-lfs`

## Nginx setup
Please see the example.conf......

## Using X-Accel-Redirect
Tips:  
allow read access for [nginx executer].
```
sudo editor /var/git/.gitolite.rc
UMASK => 0077 to UMASK => 0027
sudo install -d -m 0750 -o git -g git /var/git/lfs
sudo chmod g+rx -R /var/git/lfs/
sudo gpasswd -a www-data git
```