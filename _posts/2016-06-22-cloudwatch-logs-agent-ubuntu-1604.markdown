---
layout: post
title: Installing the AWS Cloudwatch Logs Agent on Ubuntu 16.04
date: 2016-06-22 07:04:21.000000000 +02:00
permalink: /writing/posts/cloudwatch-logs-agent-ubuntu-1604/
---

Not only can [AWS Cloudwatch](https://aws.amazon.com/cloudwatch/) alert you of problems with your resources, it can also store your log files and make them accesible in the AWS web interface. To make [AWS Cloudwatch Logs](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/WhatIsCloudWatchLogs.html) work you'll need to install a small agent on your EC2 instances. Currently AWS has support for CentOS, RHEL, Amazon Linux and Ubuntu 12.04 and 14.04, among some other distributions.

The newest LTS version of Ubuntu, [16.04](http://releases.ubuntu.com/16.04/), isn't on the list of supported versions yet. As Ubuntu switched to [Systemd](https://www.freedesktop.org/wiki/Software/systemd/) for their default init system you'll run into some trouble getting the Cloudwatch Logs Agent service started.

<!-- more -->

### Installing Cloudwatch Logs Agent

Amazon provides a small installer for the agent.

```bash
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
```

```bash
python awslogs-agent-setup.py -n -r MY_REGION
```

Where MY_REGION is the region your EC2 instances are running in, for example eu-west-1.

### Getting the service to run

Because Amazon doesn't provide support for Ubuntu 16.04 yet there also isn't a Systemd unit file yet. I created one myself.

```bash
[Unit]
Description=The CloudWatch Logs agent
After=rc-local.service

[Service]
Type=simple
Restart=always
KillMode=process
TimeoutSec=infinity
PIDFile=/var/awslogs/state/awslogs.pid
ExecStart=/var/awslogs/bin/awslogs-agent-launcher.sh --start --background --pidfile $PIDFILE --user awslogs --chuid awslogs &

[Install]
WantedBy=multi-user.target
```

Make sure the service will start itself on boot and start the Agent.

```bash
systemctl enable awslogs.service
systemctl start awslogs.service
```

### Ansible

To make installing and configuring the agent just a little easier I made an Ansible role available that will do all of this for you. You can pull the code from [the GitHub repository](https://github.com/mijndert/ansible-cloudwatch-logs-agent). Of course improvements are welcome via a pull request.
