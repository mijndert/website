---
layout: post
title: Using Acme.sh to issue Let's Encrypt certificates
date: 2017-03-14 10:49:05 +02:00
permalink: /writing/posts/using-acme.sh-to-issue-lets-encrypt-certificates/
---

Some time ago [I wrote about](https://mijndertstuij.nl/writing/posts/letsencrypt-ssl-nginx/) how to use [Let's Encrypt](https://letsencrypt.org/) certificates to get an A+ on the [SSL Labs test](https://www.ssllabs.com/ssltest/). Back then the only way to obtain and manage certificates was [CertBot](https://certbot.eff.org/). I always thought that solution made it a hassle to manage multiple certificates. My friend [Jorijn](https://jorijn.com/) brought [acme.sh](https://github.com/Neilpang/acme.sh) to my attention, a new way to issue and manage Let's Encrypt certificates. It was time for me to revisit the topic. <!-- more -->

## What is acme.sh?

Acme.sh is an ACME protocol client written purely in Shell (Unix shell) language so there are no dependencies other than having a shell (Bash, Dash, sh). It's the simplest yet most complete way to manage Let's Encrypt certificates.

## Install

To install acme.sh you can wget or curl the script from the internet and execute it.

```curl https://get.acme.sh | sh```

Or

```wget -O -  https://get.acme.sh | sh```

Of course it's a horrible idea to just execute a script on your machine using root credentials. Be sure to check out the script before and decide for yourself.

The script will:

- Create and copy acme.sh to your home dir ```($HOME): ~/.acme.sh/```. All certs will be placed in this folder too.
- Create alias for: ```acme.sh=~/.acme.sh/acme.sh```.
- Create daily cron job to check and renew the certs if needed.

You can also pull the code from git and execute the script from there:

```
git clone https://github.com/Neilpang/acme.sh.git
cd ./acme.sh
./acme.sh --install
```

You don't have to be root but it is recommended.

## Stateless

There are multiple ways to prove ownership of a domain using Acme.sh: standalone mode, using Apache or Nginx, DNS, or [stateless](https://github.com/Neilpang/acme.sh/wiki/Stateless-Mode). In my opinion the stateless mode is by far the easiest.

I've been using Nginx exclusively for 6 years so I'm going to give you the Nginx version. But this can also work with just about any webserver on the market today.

First get your account key thumbprint:

```acme.sh --register-account```

Now we can configure Nginx to return the account key thumbprint:

```
server {
...
  location ~ "^/\.well-known/acme-challenge/([-_a-zA-Z0-9]+)$" {
    default_type text/plain;
    return 200 "$1.YOURTHUMBPRINT";
  }
...
}
```

Replace ```YOURTHUMBPRINT``` with the key that you got back when you registered. Restart Nginx after making these changes.

## Issue & copy

Issue a certificate for example.com:

```acme.sh --issue -d example.com -d www.example.com  --stateless```

Create a directory in which to copy your certificates for use by Nginx. I used ```/etc/nginx/certificates``` but you can use anything you like really.

```
acme.sh --install-cert -d example.com \
--keypath       /etc/nginx/certificates/example.com.key  \
--fullchainpath /etc/nginx/certificates/example.com.pem \
--reloadcmd     "service nginx force-reload"
```

## Configure your vhost

Now we can insert the SSL certificate into your vhost:

```
server {
...
  listen 443 ssl;
  listen [::]:443 ssl;

  ssl_certificate /etc/nginx/certificates/example.com.pem;
  ssl_certificate_key /etc/nginx/certificates/example.com.key;

  if ($scheme = http) {
    return 301 https://$server_name$request_uri;
  }
...
}
```

Take a look at my [previous article on this topic](https://mijndertstuij.nl/writing/posts/letsencrypt-ssl-nginx/) for more information on how to configure Nginx for SSL usage.

## Congratulations

You now have a very easy way to issue new Let's Encrypt certificates. Every certificate will automatically be renewed if needed so it's fire-and-forgot from now on. Of course there's way more options in Acme.sh than I could ever cover on my website, so please [read the wiki](https://github.com/Neilpang/acme.sh/wiki).
