---
layout: post
title: "Run Ghost in Docker behind Nginx"
date: 2018-01-11 13:24:59 +02:00
permalink: /writing/posts/run-ghost-in-docker-behind-nginx/
---

To me installing and upgrading Ghost is way too hard. Using Docker it's a little more manageable. Launching a Docker container with Ghost is easy - first you have to install Docker (I'm using Ubuntu).<!-- more -->

```
apt install docker.io
```

Create a user to run your Docker container as and add that user to the Docker group:

```
useradd -s /bin/bash -m mijndert -d /home/mijndert
usermod -aG docker mijndert
```

To make the Docker container stateless and store the data locally, create a folder:

```
mkdir /home/mijndert/ghost
chown -R mijndert:www-data /home/mijndert/ghost
chmod -R 0770 /home/mijndert/ghost
chmod g+s /home/mijndert/ghost
```

After that you can run the Docker container:

```
docker run -d --name ghost --restart always -e url=http://mijndertstuij.nl -p 2368:2368 -v /home/mijndert/ghost:/var/lib/ghost/content ghost
```

The restart always flag ensures that your Docker container will always start when the Docker daemon launches.

To make sure Nginx acts as a reverse proxy, add this to your virtual host config:

```
location / {
    	proxy_pass                          http://localhost:2368;
    	proxy_set_header  Host              $http_host;   # required for docker client's sake
    	proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
    	proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
    	proxy_set_header  X-Forwarded-Proto $scheme;
    	proxy_read_timeout                  900;
}
```
