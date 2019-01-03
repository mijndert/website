---
layout: post
title: An A+ SSL setup using Nginx and Letsencrypt
date: 2016-03-21 10:04:21.000000000 +02:00
permalink: /writing/posts/letsencrypt-ssl-nginx/
---

Back in 2014 I wrote about getting an [A+ on SSL Labs using StartSSL](https://mijndertstuij.nl/posts/getting-a-on-ssllabs-with-nginx-startssl/). Much has changed since then, for starters we can now use the awesome [Letsencrypt](https://letsencrypt.org/) to get our certificates.

Letsencrypt is completely free, just like StartSSL, but it will only give out certificates that are valid for 90 days. Luckily you can renew your certificate just as easily as creating one.

<!-- more -->

Let's talk about how to configure Nginx to get that precious A+ on [SSL Labs](https://www.ssllabs.com/ssltest/analyze.html).

### Setting up Letsencrypt

First we need to install Letsencrypt. Well, not really because there's nothing to install. Letsencrypt is very portable.

```bash
git clone https://github.com/letsencrypt/letsencrypt
```

### Requesting a certificate

There's a few ways to request a certificate because it needs to be verified during the request process. Because I already have a web server running on port 80 I use the webroot method which places a small file in your webroot.

```bash
sh /root/letsencrypt/letsencrypt-auto certonly --webroot --webroot-path /the/path/of/my/webroot --domains domain.xyz,www.domain.xyz,my.domain.xyz --agree-tos --email foo@bar.xyz
```

This will request a certificate and put it in ```/etc/letsencrypt/live/domain.xyz```.

### Generating DH params

Before actually configuring Nginx we'll need to set up our [DH params](https://wiki.openssl.org/index.php/Diffie-Hellman_parameters):

```bash
openssl dhparam -out /etc/nginx/dhparam.pem 4096
```

### Setting up Nginx

Put this in your Nginx.conf or something that's included.

```bash
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;

# Diffie-Hellman parameter for DHE ciphersuites
ssl_dhparam /etc/nginx/dhparam.pem;

ssl_protocols TLSv1.1 TLSv1.2;
ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';
ssl_prefer_server_ciphers on;

# HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
add_header Strict-Transport-Security max-age=15768000;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;

## verify chain of trust of OCSP response using Root CA and Intermediate certs
# actual chain is in each vhost
resolver 8.8.8.8 8.8.4.4 valid=86400;
resolver_timeout 10;
```

### Vhost configuration

I'll assume you already have a vhost set up and we're just going to add the SSL configuration.

```bash
listen 443 ssl;
listen [::]:443 ssl;

ssl_certificate /etc/letsencrypt/live/domain.xyz/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/domain.xyz/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/domain.xyz/chain.pem;

if ($scheme = http) {
   return 301 https://$server_name$request_uri;
}
```

### The result

To test your set up you can go to [SSL Labs](https://www.ssllabs.com/ssltest/analyze.html). You should be getting an A+.

### Renewing a certificate

The letsencrypt-auto binary has a renew account which I use in a cron job. It will loop through all of your certificates and check if a renewal is pending.

I recommend you run this command every week to make sure all of your certificates renew in time.

```bash
sh /root/letsencrypt/letsencrypt-auto renew && service nginx reload >/var/log/renew.log
```
