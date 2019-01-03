---
layout: post
title: Fix a CPU consuming logrotate process
date: 2013-12-16 13:00:00.000000000 +02:00
permalink: /writing/posts/fix-cpu-consuming-logrotate-process/
---
This week I noticed something strange about the disk IO of a server running Postfix. As soon as I logged in to the server I saw logrotate consuming 99% CPU and about 50% memory. Here's how I diagnosed and fixed the problem.

<!-- more -->

First I looked at the contents of the logrotate status file:

```bash
tail /var/lib/logrotate/status "/var/log/mail.log.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.1.2.gz.1.1.2.gz.1.1.1.1.1.1.1.1.2.gz.1.1.1.1"
```

That doesn't look right. Some kind of loop has occured that caused every file in the directory to logrotate. Just to get an idea of the problem I looked at the size of the status file:

```bash
ls /var/lib/logrotate/status -lh
```

In my case the file grew to a whopping 95MB.

First of all, kill whatever logrotate is doing:

```bash
sudo kill -9 PID
```

Now let's have a look at the logrotate file for the mail log:

```bash
/var/log/mail.* { daily rotate 60 copytruncate delaycompress compress notifyempty missingok }
```

Looks like it matches all files called mail.* so mail.1.1.1.1.gz will also be matched and handled through logrotate again, and again, and again... The solution was obvious, after changing the first line to mail.log everything worked as intented.

Logrotate taking up a lot of resources is usually caused by a configuration error. The logrotate status file is your best friend in most cases.
