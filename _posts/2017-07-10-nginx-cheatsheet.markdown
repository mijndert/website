---
layout: post
title: "Nginx cheatsheet"
date: 2017-07-10 13:24:59 +02:00
permalink: /writing/posts/nginx-cheatsheet/
---

I good while back I wrote some stuff about Nginx on an internal wiki. At that time the company was converting from using Apache to Nginx and not everyone was up to speed. I dubbed the wiki entry the _Nginx Cheatsheet_. I recently unearthed this fine piece of writing and I'm re-posting it here so more people might benefit from the effort.<!-- more -->

## Simple vhost

The most simple vhost I can think of:

```
server {
   listen 80;
   server_name domain.nl www.domain.nl;
   root /home/DOMAIN/www;
   index index.html;
}
```

## Limit accesibility

### By username

```
Location / {
    auth_basic "Login for <BLABLA>";
    auth_basic_user_file /home/BLABLA.htpasswd
}
```

### By IP address

```
Location / {
    satisfy any;
    allow 1.2.3.4;
    deny all;
}
```

### By either username or IP address

```
Location / {
    satisfy any;
    auth_basic "Login for <BLABLA>";
    auth_basic_user_file /home/BLABLA.htpasswd
    allow 1.2.3.4;
    deny all;
}
```

## FastCGI

The most basic way to connect Nginx to FastCGI is this:

```
location ~ \.(hh|php)$ {
   root /home/USERNAME/www;
   include /etc/nginx/fastcgi_params;
   fastcgi_pass 127.0.0.1:9000;
   try_files $uri=404;
   fastcgi_index index.php;
   fastcgi_param SCRIPT_FILENAME /home/USERNAME/www$fastcgi_script_name;
   fastcgi_param PATH_TRANSLATED /home/USERNAME/www$fastcgi_script_name;
}
```

More on tweaking FastCGI settings in _DoS prevention_.

## Redirects

If you want to have one or more domain names to redirect to another it's really easy to do so. Way easier than Apache anyway.

```
server {
   listen       80;
   server_name  olddomain.nl www.olddomain.nl;
   return       301 http://www.DOMAINNAME.nl$request_uri;
}
```

You can also do some neat things with regex:

```
# Server-wide redirect
rewrite ^/example/something/?.* http://DOMAIN.nl/example permanent;
# Location-specific redirect
location /example/something/ {
  rewrite /example/something/(.*)$ http://DOMAIN.nl/$1;
}
```

And you can 'if' your way out of a rewrite, for example when ?post_type is included in the URI:

```
location ~ ^/feed$ { if ($arg_post_type = "") { rewrite ^/rss2/?$http://feedpress.me/example redirect; } }
```

Redirect all traffic to HTTPS:

```
if ($scheme = 'http') {
     rewrite ^ https://$host$request_uri? permanent;
}
```

## FastCGI caching

First you'll need to add a cache path to the top of your vhost:

```
fastcgi_cache_path /var/cache/nginx/DOMAIN levels=1:2 keys_zone=DOMAIN:100m inactive=60m;
```

You can also add a header to check whether your requests is cached or not. You'll either get HIT (you're cached), MISS (it was not in cache, will be next time!) or BYPASS (something is forcing your request not to be cached) as returned values.

```
add_header X-Cache $upstream_cache_status;
```

Enable caching and have query strings and POST requests always go to PHP:

```
# fastcgi_cache start
set $no_cache 0;

# POST requests and urls with a query string should always go to PHP
if ($request_method = POST) {
   set $no_cache 1;
}

if ($query_string != "") {
   set $no_cache 1;
}
```

You can make exceptions for certain query strings that you do want to have cached:

```
# don't cache pages which have these query strings as arg
if ( $arg_utm_campaign != "" ) { set $no_cache 0; }
if ( $arg_utm_medium != "" ) { set $no_cache 0; }
if ( $arg_utm_source != "" ) { set $no_cache 0; }
if ( $arg_gclid != "" ) { set $no_cache 0; }
```

You should make exceptions for certain pages you don't want to have cached, like /login and /admin. Also, when a user has a cookie because he/she is logged in.

```
# Don't cache uris containing the following segments
if ($request_uri ~* "(/wp-admin/|/xmlrpc.php||sitemap(_index)?.xml)" {
   set $no_cache 1;
}

# Don't use the cache for logged in users or recent commenters
if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
   set $no_cache 1;
}
```

In order to actually have PHP output be cached, you'll need to add this to your 'Location' for .php files:

```
fastcgi_cache_bypass $no_cache;
fastcgi_no_cache $no_cache;
fastcgi_cache DOMAIN;
fastcgi_cache_valid 200 302 60m; # WARNING: only use high valids if cache purge module is used
fastcgi_cache_valid 404 1m; # keep 404 low
```

If you want to disable caching for whatever reason you only have to set no_cache to 1:

```
set $no_cache 1;
```

In order to remove entries from the FastCGI cache you'll need to use the ngx_cache_purge module. This allows certain IP's to call for example http://domain.nl/purge/about. There's a plugin for WordPress that does this automatically for you upon editting posts and pages.

```
location ~ /purge(/.*) {
   allow 127.0.0.1;
   allow 1.2.3.4;
   deny all;
   fastcgi_cache_purge DOMAIN "$scheme$request_method$host$1";
}
```

## Sub-domains

In Apache you can use ServerAlias to add more domain names to a vhost. Nginx doesn't have any of that because it's confusing. In Nginx you just add more stuff behind ServerName.

```
ServerName domain.nl domain.com domain.org
```

You can also have all sub-domains (and the zone apex itself) of a certain zone apex pointing into a vhost by adding just one entry to ServerName:

```
ServerName .domain.nl
```

This will match domain.nl, www.domain.nl, bob.domain.nl, example.domain.nl, etc.

## Userdir

Nginx does not natively support userdirs, but it can be done by using regex captures.

```
location ~ ^/~(.+?)(/.*)?$ {
   alias /home/$1/www$2;
}
```

You may get 403 Forbidden when you just put the snippet above into your nginx configuration, because by default nginx does not allow autoindex. If you would like it to behave more like the default Apache userdir, add two lines as below:

```
location ~ ^/~(.+?)(/.*)?$ {
   alias /home/$1/www$2;
   index  index.php index.html;
   autoindex on;
}
```

## DoS prevention

In order to prevent people, or processes, from completely flooding FastCGI with requests and filling the buffers, we add some sensible defaults to the FastCGI settings.

The following tries to prevent hanging FastCGI processes, full buffers and request flooding:

```
fastcgi_intercept_errors on;
fastcgi_ignore_client_abort off;
fastcgi_connect_timeout 60;
fastcgi_send_timeout 180;
fastcgi_read_timeout 180;
fastcgi_buffer_size 128k;
fastcgi_buffers 4 256k;
fastcgi_busy_buffers_size 256k;
fastcgi_temp_file_write_size 256k;
```

## Deny execution of PHP files

To prevent the execution of .php files in the uploads directory in WordPress' case you can add the following to your vhost:

```
location ~* /(?:uploads|files)/.*\.php$ {
  deny all;
}
```

This is a security measure. Sometimes a plugin is broken and allows an attacker to upload .php files. These files will usually end up in wp-content/uploads.

## Performance tweaks

### Enable gzip

```
gzip                      on;
gzip_min_length           1100;
gzip_buffers              4 32k;
gzip_vary                 on;
gzip_http_version         1.0;
gzip_comp_level           5; # 5 has best overall compression vs slightly higher cpu. Depending on server load this can be set to 4.
gzip_proxied              any;
gzip_types                text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/json;
gzip_disable              "MSIE [1-6]\.(?!.*SV1)";
```

### Enable open file cache

```
open_file_cache           max=200000 inactive=2h;
open_file_cache_errors    on;
open_file_cache_min_uses  2;
open_file_cache_valid     1h;
```

### Open file limits

```
# set open fd limit to 81920
worker_rlimit_nofile 81920; # must be equal or higher as 'worker_processes' * 'worker_connections'
events {
   worker_connections 10240; # 'worker_processes' * 'worker_connections' cannot exceed 'worker_rlimit_nofile'
   use epoll;
   multi_accept on;
}
```

## SSL
More on using SSL with Nginx can be found [here](https://mijndertstuij.nl/writing/posts/letsencrypt-ssl-nginx/) and [here](http://127.0.0.1:4000/writing/posts/using-acme.sh-to-issue-lets-encrypt-certificates/).

## Work with me here, okay?

If you see anything that's outdated or otherwise broken, please open a pull request on [my repository](https://github.com/mijndert/mijndertstuij.nl).
