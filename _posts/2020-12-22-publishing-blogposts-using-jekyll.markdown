---
layout: post
title: "Publishing thoughts using Jekyll"
date: 2020-12-22 
permalink: /thought/:year/publishing-thoughts-using-jekyll/
description: ""
---

[Jekyll](https://jekyllrb.com/) has been my static website generator for years now. I understand every little detail of its inner workings and I can create my own themes and plug-ins if needed. Jekyll allows for an incredible amount of control, something I would have to give up had I used [WordPress](https://wordpress.org/) or some other CMS. Jekyll also allows me to create websites that perform very well, and I always strive for a score of 100 on [Lighthouse](https://developers.google.com/web/tools/lighthouse).

Over the years I've made [quite some changes](https://github.com/mijndert/website) to my website though. I mostly want the least amount of friction between my thoughts and publishing them on the internet. That's what I created a bunch of scripts to help with just that.

## Generating the website

I use a workflow with [Docker](https://www.docker.com/) and [Make](https://www.gnu.org/software/make/manual/make.html) to preview this website on my laptop. I don't want the hassle of installing and maintaining Jekyll on my local machine, so Docker seems like the only logical solution.

Everything's wrapped in a [Makefile](https://www.gnu.org/software/make/manual/make.html) so I don't have to remember the commands, I just run `make serve` to fire up the built-in webserver.

```
.PHONY: clean post build serve 

clean:
	$(RM) -r _site/

post:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/minimal rake post

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/minimal jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/minimal jekyll s --drafts
```

## Creating a new post

As you can see the Makefile also includes a command to generate a new post. This command uses a tool called [Rake](https://github.com/ruby/rake), which is a Make-like tool for [Ruby](https://www.ruby-lang.org/en/), it's included in the Docker image as well.

A new post ends up in the `_drafts` folder where I can freely write without it ending up on the website before I want to actually publish it. When I eventually do want to publish, I just move the [Markdown](https://daringfireball.net/projects/markdown/syntax) file from `_drafts` into `_posts`.

Like everything else about this website, the Rakefile to achieve this is also [available on GitHub](https://github.com/mijndert/website/blob/master/Rakefile).

Make sure you include `show_drafts: false` in your configuration so drafts won't end up on the website anyway.

## GitHub Pages

Hosting a completely static website doesn't require some complex stack of software - that's why I've been hosting on [GitHub Pages](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/creating-a-github-pages-site) for quite a while now. Like any other service, GitHub Pages can and will go offline sometimes, but it's free so I have absolutely nothing to complain about.

GitHub Pages even comes with a free [SSL certificate](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/securing-your-github-pages-site-with-https) for you domain and you can set up a custom [404 error page](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/creating-a-custom-404-page-for-your-github-pages-site).