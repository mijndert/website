---
layout: post
title: Monitor Amazon Web Services RDS instances with Nagios
date: 2012-03-15
permalink: /writing/posts/monitor-amazon-web-services-rds-instances-nagios/
---
RDS or Relational Database Service allows you to run on-demand servers with full access to MySQL and Oracle databases. When you're using Nagios it's nice to have an alert for when your RDS instance becomes unresponsive. Nagios Exchange provides a small Perl script that can do exactly that.

<!-- more -->

You need to download and copy this Perl script to /usr/local/nagios/libexec, or wherever your Nagios install is on your system. Now we can define a service command.

```bash
define command{
	command_name check_mysqld
  command_line /usr/bin/perl $USER1$/check_mysqld.pl -H your-rds-hostname -u $ARG1$ -p $ARG2$
}
```

And we need a service check within the server config.

```bash
define service
	use generic-service
  host your-host
  service_description MySQLd check
  check_command check_mysqld!username!password
}
```

Now all we need to do is restart the Nagios daemon and wait for the new command to initialize. The service check will try to do a 'mysql status' command every once in a while.
