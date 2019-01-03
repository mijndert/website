---
layout: post
title: Quickly switch between AWS accounts using aws-cli
date: 2014-10-02 14:00:00.000000000 +02:00
permalink: /writing/posts/quickly-switch-accounts-using-aws-cli/
---
The <a href="http://docs.aws.amazon.com/cli/latest/index.html">AWS CLI tools</a> are really great for quick tasks on your AWS infrastructure, like looking which instances are currently running. You can also using aws-cli for automation of course. One thing I found annoying while working with multiple accounts was having to add --profile to my command each time I wanted to do something with aws-cli.

<!-- more -->

I wrote a small function to mitigate that issue. You can place this anywhere you like as long as it's in your *$PATH*. I've put it in */usr/local/bin/awscred*.

```bash
#!/bin/bash
AWSDIR=~/.aws/
    if [ -z "$1" ]; then
            echo "Example: awscred gct"
    else
    if [ -n $1 ] ; then
            echo "Enabling account $1 ..."
            export AWS_CONFIG_DIR=$AWSDIR
            export AWS_CONFIG_FILE=$AWSDIR$1
            export AWS_ACCOUNT_NAME=$1
            export AWS_DEFAULT_PROFILE=$1
            export AWS_ACCESS_KEY_ID=$(cat $AWSDIR$1 | grep ^aws_access_key_id | cut -f2- -d"=" | tr -d " ")
            export AWS_SECRET_ACCESS_KEY=$(cat $AWSDIR$1 | grep ^aws_secret_access_key | cut -f2- -d"=" | tr -d " ")
            echo "$1 is now active"
    else
            echo "$1 - file does not exist in $AWSDIR"
    fi
fi
```

We need to create an alias for this new executable and have it sourced every time in order to properly set *env* variables.

```bash
alias awscred="source awscred"
```

I also enabled auto-completion.

```bash
complete -C aws_completer aws
```

Create a directory called .aws in your home directory and start adding accounts.

```bash
$ vi .aws/client1
```

With this content. Please keep in mind to store your access keys in a secure place.

```bash
[client1]
aws_access_key_id=
aws_secret_access_key=
region=
```
