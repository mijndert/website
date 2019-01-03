---
layout: post
title: Using Docker to run WordPress behind an Nginx reverse proxy
date: 2014-10-24 14:00:00.000000000 +02:00
permalink: /writing/posts/using-docker-run-wordpress-behind-nginx-reverse-proxy/
---
<a href="https://www.docker.com/">Docker</a> really seems to be taking off as a viable solution for development workflows. If you're working with WordPress there's already a lot of good tools besides Docker to bootstrap a new WordPress website. But here's how to do it with Docker.

<!-- more -->

### Install Docker on Ubuntu

```bash
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
$ sudo sh -c "echo deb https://get.docker.com/ubuntu docker main\
> /etc/apt/sources.list.d/docker.list"
$ sudo apt-get update
$ sudo apt-get install lxc-docker
```

There's also a simple script to help with this installation:

```bash
$ curl -sSL https://get.docker.com/ubuntu/ | sudo sh
```

To test that everything is working you can start an empty Ubuntu container:

```bash
$ sudo docker run -i -t ubuntu /bin/bash
```

<a href="https://docs.docker.com/installation/ubuntulinux/">More information on installing Docker on Ubuntu</a>.

### Get a Docker container up and running with Nginx as a reverse proxy

If you want to customize <a href="https://github.com/jwilder/nginx-proxy">the Docker container</a> before launching it you can get it from GitHub and build it yourself.

```bash
$ cd /where/you/want/to/store/the/image_source
$ git clone https://github.com/jwilder/nginx-proxy.git
$ cd nginx-proxy
$ docker build -t="nginx-proxy" .
```

Run the Docker container with the Nginx reverse proxy on port 80 this way:

```bash
$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock jwilder/nginx-proxy
```

### Running WordPress inside a Docker container

In the last step we'll get a Docker container up and running with Nginx, MySQL and WordPress. The Docker container will automatically register in the Nginx reverse proxy using an environment variable.

```bash
$ git clone https://github.com/eugeneware/docker-wordpress-nginx.git
$ cd docker-wordpress-nginx
$ sudo docker build -t="docker-wordpress-nginx" .
```

Now we need to start a Docker container with WordPress installed. We'll use port 8080 on the outside of the container to proxy requests to, on the inside of the container it will be port 8080 too, but you can use any port you like. We'll also pass VIRTUAL_HOST to the container to ensure it will be registered in the reverse proxy automatically.

```bash
$ docker run -e VIRTUAL_HOST=wordpress1.dev -p 8080:8080 --name wp1dev -d docker-wordpress-nginx
```

### Tools

For management of images and containers I played with <a href="https://github.com/crosbymichael/dockerui">DockerUI</a>. It's still in very early beta but it looks really promising and makes stopping and starting containers easier.

You can also use <a href="http://passingcuriosity.com/2013/dnsmasq-dev-osx/">DNSmasq</a> to point for example all *.dev requests to your local machine.
