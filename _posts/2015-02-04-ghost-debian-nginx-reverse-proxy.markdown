---
layout: post
title: Ghost on Debian with Nginx as a reverse proxy
date: 2015-02-04 13:04:21.000000000 +02:00
permalink: /writing/posts/ghost-debian-nginx-reverse-proxy/
---
I finally came around to trying out Ghost and I'm loving it. So much that I switched my old Jekyll website over to Ghost. I used a [small Ruby script](https://github.com/mattvh/Jekyll-to-Ghost/blob/master/jekylltoghost.rb) to convert my Markdown files to a JSON file that Ghost can use to import my posts. Here's a quick tutorial how to install NodeJS and Ghost and use Nginx as a reverse proxy.

<!-- more -->

### Install dependencies

We'll need NPM and unzip to extract Ghost and prepare it's dependencies.

```bash
apt-get install unzip npm
```

After all that's done we can install NodeJS. [Nodesource](https://nodesource.com/) provides an excellent Debian repository for NodeJS packages. Add it to your *sources.list* or create a new file in */etc/apt/sources.list.d/*.

```bash
deb https://deb.nodesource.com/node wheezy main
deb-src https://deb.nodesource.com/node wheezy main
```

We can now install NodeJS

```bash
apt-get install nodejs
```

You should be able to execute *nodejs* and run a few commands.

```bash
nodejs
	> .help
	.break  Sometimes you get stuck, this gets you out
	.clear  Alias for .break
	.exit   Exit the repl
	.help   Show repl options
	.load   Load JS from a file into the REPL session
	.save   Save all evaluated commands in this REPL session to a file
```

### Install Ghost

We will create a user for Ghost to run as and [download](https://ghost.org/download/) the latest version.

```bash
adduser ghost
su - ghost
wget https://ghost.org/zip/ghost-0.5.8.zip
unzip  ghost-0.5.8.zip
rm ghost-0.5.8.zip
```

Prepare Ghost dependencies:

```bash
npm install --production
```

Don't forget to change the blog address:

```bash
vim config.js
```

### Install Forever

You should use Forever in order to automatically restart Ghost on changes or when it crashes.

As root:

```bash
npm install -g forever
```

Now we can start Ghost with it's own user:

```bash
NODE_ENV=production forever start index.js
```

To stop the Forever process that's keeping Ghost online you can list all processes and kill the ID.

```bash
forever list
forever stop <ID>
```

### Nginx reverse proxy

```bash
server {
    listen         80;
    server_name <your-blog-address>;
    root /home/ghost/;
    index index.php;

    if ($http_host != "<your-blog-address>") {
         rewrite ^ http://<your-blog-address>$request_uri permanent;
    }

    location / {
        proxy_set_header X-Real-IP  $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:2368;
    }

    location ~* \.(?:ico|css|js|gif|jpe?g|png|ttf|woff)$ {
        access_log off;
        expires 30d;
        add_header Pragma public;
        add_header Cache-Control "public, mustrevalidate, proxy-revalidate";
        proxy_pass http://127.0.0.1:2368;
    }

    location = /robots.txt { access_log off; log_not_found off; }
    location = /favicon.ico { access_log off; log_not_found off; }

    location ~ /\.ht {
            deny all;
    }
}
```

Test the configuration and reload Nginx

```bash
nginx -t && nginx -s reload
```

Your Ghost blog should now be online at `http://<your-blog-address>`.

### Start Ghost with Forever on boot

It's a bit of a hack but I've put the following in rc.local in order to let Forever run Ghost on boot:

```bash
su ghost -c 'cd /home/ghost/; NODE_ENV=production forever start index.js'
```
