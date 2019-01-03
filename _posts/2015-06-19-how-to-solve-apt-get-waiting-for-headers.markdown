---
layout: post
title: How to solve Apt-get waiting for headers
date: 2015-06-19 21:30:03.000000000 +02:00
permalink: /writing/posts/how-to-solve-apt-get-waiting-for-headers/
---
Sometimes you play around with some third-party repositories on your Debian-based Linux box, only to find out apt-get hangs while _waiting for headers_. Really annoying.

<!-- more -->

You can regenerate the apt-get list cache by executing the following steps.

```bash
sudo apt-get clean
cd /var/lib/apt
sudo mv lists lists.old
sudo mkdir -p lists/partial
sudo apt-get clean
sudo apt-get update
```

That should fix the issue and you should have _apt-get update_ working again. If it did, you can safely remove _/var/lib/apt/lists.old/_ from your system.
