---
title: "Creating a personal wiki"
date: 2021-06-14
permalink: /thought/2021/personal-wiki/
description: "Creating a personal wiki that runs on GitHub pages using mdBook."
draft: false
---

Every since I came across the term Digital/Second Brain it kind of stuck in my head, pun intended. I value an open internet where information is freely available for everyone. I want to share all of the knowledge that I gather through my work with the world, hoping someone gets some amount of value from it. If nothing else, at least it serves as a sort of time capsule - a view into my brain at any given time.

> Information should be free, both as in beer and as in freedom.

To start gathering some information and dumping everything that I know into digital files I started using [Obsidian](https://obsidian.md/). It's a nice tool but very hard to put online for everyone to see. I started looking for alternatives and found [mdBook](https://github.com/rust-lang/mdBook) still alive and kicking.

I now host [my personal wiki](https://wiki.mijndertstuij.nl/) for free on GitHub pages so it's very easy to update, portable and I can view everything offline as well.

## Setup

Because I want to be able to just run mdBook everywhere I created a [Dockerfile](https://github.com/mijndert/wiki/blob/main/Dockerfile). The Dockerfile spits out an image approximitly 750MB in size (I'm pretty sure I can bring that down a little).

```dockerfile
FROM rust:slim
ARG MDBOOK_VERSION="0.4.10"
RUN cargo install mdbook --vers ${MDBOOK_VERSION}
WORKDIR /data
VOLUME ["/data"]
```

A `Makefile` ensures I don't have to remember a bunch of commands:

```makefile
SHELL := bash
.PHONY: build serve stop

build:
  docker build -t mdbook .

serve:
  docker run -d --name mdbook --rm -p 3000:3000 -v $(PWD):/data -u $(id -u):$(id -g) -it mdbook mdbook serve -p 3000 -n 0.0.0.0

stop:
  docker stop mdbook
```

Using my Docker image I can run `mdbook init` to create a new project.

```bash
docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) -it mdbook mdbook init
```

You can now fill out the `book.toml` file in the root of your project - you can [use mine](https://github.com/mijndert/wiki/blob/main/book.toml) as a starting point if you want to. To view your new project just execute `make serve` to make it available on [http://localhost:3000](http://localohost:3000).

## GitHub Actions

To deploy your mdBook to GitHub Pages you can use a [pre-built GitHub Action](https://github.com/peaceiris/actions-mdbook). Make sure you add the `cname` option mentioned in the documentation to enable a custom domain.