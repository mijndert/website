---
layout: post
title: A faster WordPress with Lighttpd
date: 2012-01-26
permalink: /writing/posts/a-faster-wordpress-with-lighttpd/
---
For the sake of this tutorial and my own comfort I'm going to assume you're using some sort of Debian based Linux distribution. But of course this will work on anything that runs Lighttpd.

<!-- more -->

First we'll install Lighttpd and get PHP working.

	apt-get install lighttpd php5-cgi lighttpd-mod-magnet

Configuration files for Lighttpd go into /etc/lighttpd/conf-enabled. We need the following.

### 10-fastcgi.conf

```bash
server.modules   += ( "mod_fastcgi" )

fastcgi.server    = ( ".php" =>
        ((
                "bin-path" => "/usr/bin/php-cgi",
                "socket" => "/tmp/php.socket",
                "max-procs" => 2,
                "idle-timeout" => 20,
                "bin-environment" => (
                        "broken-scriptfilename" => "enable",
                        "PHP_FCGI_CHILDREN" => "8",
                        "PHP_FCGI_MAX_REQUESTS" => "10000"
                ),
                "bin-copy-environment" => (
                        "PATH", "SHELL", "USER"
                ),
                "broken-scriptfilename" => "enable",
                "allow-x-send-file" => "enable"
        ))
)
```

### 10-magnet.conf

```bash
server.modules += ( "mod_magnet" )
your-vhost.conf
$HTTP["host"] =~ "^(www\.)?yourhost\.tld" {
  var.servername = "yourhost"

  # Set basedir for our domains
  var.basedir = "/var/www/"

  # Documentroot = basedir + servername
  server.document-root = basedir + servername

  # Attach the mod_magnet URL
  magnet.attract-physical-path-to = ( "/etc/lighttpd/wordpress.lua" )
}
```

### lighttpd.conf

```bash
server.modules = (
        "mod_access",
        "mod_expire",
        "mod_alias",
        "mod_compress",
        "mod_redirect",
        "mod_rewrite",
)

server.document-root        = "/var/www"
server.upload-dirs          = ( "/var/cache/lighttpd/uploads" )
server.errorlog             = "/var/log/lighttpd/error.log"
server.pid-file             = "/var/run/lighttpd.pid"
server.username             = "www-data"
server.groupname            = "www-data"
index-file.names            = ( "index.php", "index.html",
                                "index.htm", "default.htm",
                               " index.lighttpd.html" )
url.access-deny             = ( "~", ".inc" )
static-file.exclude-extensions = ( ".php", ".pl", ".fcgi" )
dir-listing.encoding        = "utf-8"
server.dir-listing          = "enable"

$HTTP["url"] =~ "\.(png|js|jpg|gif|ico|css)$" {
        expire.url = ( "" => "access 40 days" )
}

$HTTP["url"] =~ "\.(html|htm)$" {
        expire.url = ( "" => "access 1 seconds" )
}

compress.cache-dir          = "/var/cache/lighttpd/compress/"
compress.filetype           = ( "application/x-javascript", "text/css", "text/html", "text/plain" )
include_shell "/usr/share/lighttpd/create-mime.assign.pl"
include_shell "/usr/share/lighttpd/include-conf-enabled.pl"
```

### MySQL and PHPMyAdmin

```bash
apt-get install mysql-server-5.1
mkdir /var/www/phpmyadmin
cd /var/www/phpmyadmin
svn co https://phpmyadmin.svn.sourceforge.net/svnroot/phpmyadmin/tags/STABLE/phpMyAdmin .
```

### WordPress
Now you can download WordPress and create a database. You will also need to place wordpress.lua in the configured directory. The LUA file needs to look like this.

```lua
attr = lighty.stat(lighty.env["physical.path"])
if (not attr) then
  lighty.env["uri.path"] = "/index.php"
  lighty.env["physical.rel-path"] = lighty.env["uri.path"]
  lighty.env["physical.path"] = lighty.env["physical.doc-root"] .. lighty.env["physical.rel-path"]
end
```
