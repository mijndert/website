---
layout: post
title: Require MFA for AWS API and Console access
date: 2014-11-14 13:00:00.000000000 +02:00
permalink: /writing/posts/require-mfa-aws-api-console-access/
---
Sometimes you want to require your users to enable <a href="http://aws.amazon.com/iam/details/mfa/">MFA</a> (multi-factor authentication) before being able to do anything with the Amazon Web Services (AWS) account you gave them access to. There's a small conditional you have to add to your <a href="http://aws.amazon.com/iam/">IAM</a> policy in order to do so. But you'll also want to enable all users to add, delete and resync their MFA devices.

<!-- more -->

Here's the IAM policy I created to do just that.

```json
{
"Version": "2012-10-17",
"Statement": [
    {
        "Sid": "AllowAllUsersToListAccounts",
        "Effect": "Allow",
        "Action": [
            "iam:ListAccountAliases",
            "iam:ListUsers"
        ],
        "Resource": [
            "arn:aws:iam::xxx:user/*"
        ]
    },
    {
        "Sid": "AllowIndividualUserToSeeTheirAccountInformation",
        "Effect": "Allow",
        "Action": [
            "iam:ChangePassword",
            "iam:CreateLoginProfile",
            "iam:DeleteLoginProfile",
            "iam:GetAccountPasswordPolicy",
            "iam:GetAccountSummary",
            "iam:GetLoginProfile",
            "iam:UpdateLoginProfile"
        ],
        "Resource": [
            "arn:aws:iam::xxx:user/${aws:username}"
        ]
    },
    {
        "Sid": "AllowIndividualUserToListTheirMFA",
        "Effect": "Allow",
        "Action": [
            "iam:ListVirtualMFADevices",
            "iam:ListMFADevices"
        ],
        "Resource": [
            "arn:aws:iam::xxx:mfa/*",
            "arn:aws:iam::xxx:user/${aws:username}"
        ]
    },
    {
        "Sid": "AllowIndividualUserToManageThierMFA",
        "Effect": "Allow",
        "Action": [
            "iam:CreateVirtualMFADevice",
            "iam:DeactivateMFADevice",
            "iam:DeleteVirtualMFADevice",
            "iam:EnableMFADevice",
            "iam:ResyncMFADevice"
        ],
        "Resource": [
            "arn:aws:iam::xxx:mfa/${aws:username}",
            "arn:aws:iam::xxx:user/${aws:username}"
        ]
    },
    {
        "Sid": "DoNotAllowAnythingOtherThanAboveUnlessMFAd",
        "Effect": "Deny",
        "NotAction": "iam:*",
        "Resource": "*",
        "Condition": {
            "Null": {
                "aws:MultiFactorAuthAge": "true"
            }
        }
    }
  ]
}
```
