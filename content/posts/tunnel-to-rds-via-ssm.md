---
title: "Tunnel to RDS via SSM Session Manager"
date: 2021-05-14
url: /thought/2021/tunnel-rds-ssm-session-manager/
description: "How to create an SSH tunnel via SSM Session Manager to access private resources like RDS without opening port 22."
draft: true
---

AWS Systems Manager is a suite of tools to make administration of, mostly, EC2 instances a little easier. One of things in SSM's toolbox is Session Manager which allows you to connect to an EC2 instance without opening any ports in your security groups.

You can also use Session Manager to create an SSH tunnel to infrastructure in private subnets, like RDS or Redis.

To make use of SSM, an agent has to be installed on the target EC2 instance, this agent is installed by default on Amazon Linux 2 and a bunch of more recent Ubuntu versions. To follow along it's best to launch an EC2 instance using the latest Amazon Linux 2 AMI since it has all prerequisites installed by default.

## Generate an SSH key

Since we'll use an SSH tunnel we'll also need an SSH key to use it with. Currently the most secure SSH key possible uses the ed25519 algorithm. You can generate a new key like this:

```bash
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

> Note: It's generally a good idea to set a password on your SSH keys. Store the password in a password manager since it can't be recovered. Losing your password means generating a new SSH key.

## Launch instance connect

In order to launch instance connect you need to know the following 2 things about the instance:

1. The Availability Zone the instance is in;
2. The ID of the instance

Let's say you have an instance with ID i-123456789 in eu-west-1a.

```bash
aws ec2-instance-connect \
    send-ssh-public-key \
    --availability-zone eu-west-1a \
    --instance-id i-123456789 \
    --instance-os-user ssm-user \
    --ssh-public-key file://$HOME/.ssh/id_ed25519.pub
```

This will start a foreground process that initiates instance connect so keep your terminal open for the next step.

> When you're done you can quit the process by hitting ctrl+c.

## Open an SSH tunnel

Now we can open up an SSH tunnel as you would otherwise. In this case I use the aforementioned EC2 instance to connect to an RDS instance over port 3306, both local as well as rmeote.

```bash
ssh ssm-user@i-123456789 \
    -NL 3306:<RDS connection string>:3306
```

Now you should be able to connect to the RDS instance in a private subnet by connecting to `localhost:3306` from your workstation.