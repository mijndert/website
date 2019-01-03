---
layout: post
title: Getting A+ on SSLLabs with Nginx and StartSSL
date: 2014-10-07 14:00:00.000000000 +02:00
permalink: /writing/posts/getting-a-on-ssllabs-with-nginx-startssl/
---
Qualys offers an <a href="https://www.ssllabs.com/ssltest/">SSL Test</a> where you can check your SSL setup. They make recommendations on what to tweak to get the highest score possible. I want to share how I achieved A+ using Nginx and <a href="https://www.startssl.com/">StartSSL</a>.

<!-- more -->

For your Perfect Forward Secrecy (PFS), insert this into the HTTP block of your Nginx.conf.

```bash
ssl_session_cache shared:SSL:10m;
```

And include the config.

```bash
include perfect-forward-secrecy.conf;
```

We force SSL protocols and ciphers in perfect-forward-secrecy.conf

```bash
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM";
ssl_dhparam /etc/ssl/dh2048.pem;
```

I know the cipher list isn't perfect, but I'm going for compatibility while still maintaining that A+ score.

Generate a rotation key for PFS:

```bash
openssl dhparam -out /etc/ssl/dh2048.pem 2048
```

And edit your vhost:

```bash
listen 443;
ssl on;
ssl_certificate     /etc/ssl/HOSTNAME.crt;
ssl_certificate_key /etc/ssl/HOSTNAME.key;
add_header Strict-Transport-Security max-age=31536000;
add_header X-Frame-Options DENY;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
```
