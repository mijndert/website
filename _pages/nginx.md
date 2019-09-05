---
layout: page
title: Secure Nginx config
description: "A collection of snippets for Nginx."
permalink: /more/nginx/
---

## Timeouts

Do not keep connections open longer then necessary to reduce resource usage and deny Slowloris type attacks.

```shell
client_body_timeout 3s; # maximum time between packets the client can pause when sending nginx any data
client_header_timeout 3s; # maximum time the client has to send the entire header to nginx
send_timeout 3s; # maximum time between packets nginx is allowed to pause when sending the client data
keepalive_timeout 9s; # timeout which a single keep-alive client connection will stay open
keepalive_requests 10;  # number of requests per connection, does not affect SPDY
keepalive_disable none; # allow all browsers to use keepalive connections
```

## Size limits

```shell
client_body_buffer_size 8k;
client_header_buffer_size 1k;
client_max_body_size 10m;
large_client_header_buffers 4 4k;
```

## Headers

```shell
server_tokens off;
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";
add_header Strict-Transport-Security "max-age=7776000; includeSubDomains; preload";
```

## TLS configuration

```shell
ssl_protocols TLSv1.3;
ssl_prefer_server_ciphers on; 
ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
ssl_ecdh_curve secp384r1; 
ssl_session_timeout 10m;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 1.1.1.1 valid=1800s;
resolver_timeout 5s; 
```