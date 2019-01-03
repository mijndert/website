#!/bin/bash
AWSDIR=~/.aws
if [ -z "$1" ]; then
	echo "Example: awsenv account1"
else
        if grep -Fxq "[$1]" $AWSDIR/credentials; then
		echo "Enabling account $1 ..."
		unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_ACCOUNT_NAME
		export AWS_CONFIG_DIR=$AWSDIR
       		export AWS_CONFIG_FILE=$AWSDIR/credentials
                export AWS_ACCOUNT_NAME=$1
		export AWS_ACCESS_KEY_ID=$(aws --profile $1 configure get aws_access_key_id)
		export AWS_SECRET_ACCESS_KEY=$(aws --profile $1 configure get aws_secret_access_key)
                echo "$1 is now active"
       	else
               	echo "$1 - account does not exist in $AWSDIR/credentials"
	fi
fi
