---
layout: post
title: Grant an IAM user access to a specific S3 bucket and folder
date: 2015-02-13 14:07:39.000000000 +02:00
permalink: /writing/posts/grant-iam-access-specific-s3-bucket-folder/
---
In Amazon Web Services there's a product called [IAM (Identity and Access Management)](http://aws.amazon.com/iam/) which allows you to create users and groups and attach policies to both. In this how to we look at an IAM policy which allows a specific user to only have access to a specific [S3](http://aws.amazon.com/s3/) bucket and folder.

<!-- more -->

The first thing you will need to do is grant the IAM user the rights to list all S3 buckets in the account. Because the user can only read/write to a specific bucket we hide every other bucket with a *condition* statement. In this case the user will only be able to see the bucket *mybucket*.

```json
{
     "Effect": "Allow",
     "Action": "s3:ListAllMyBuckets",
     "Resource": "arn:aws:s3:::*",
     "Condition":{"StringLike":{"s3:prefix":["mybucket"]}}
  },
```

The next step is to grant the IAM user rights to list all folders within the bucket and hide all other folders in which the user doesn't have any rights. In this case the user will only see the folder *myfolder* in the bucket *mybucket*.

```json
{
   "Sid": "AllowListingOfUserFolder",
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::mybucket"],
      "Condition":{"StringLike":{"s3:prefix":["myfolder/*"]}}
}
```

The final step is to grant rights to read and write in the specific folder. We also allow the user to *Get* and *Delete* versioned objects and list all objects in *myfolder*.

```json
{
"Effect":"Allow",
   "Action":[
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
   ],
   "Resource":"arn:aws:s3:::mybucket/myfolder/*"
}
```

The final IAM policy:

```json
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": "s3:ListAllMyBuckets",
         "Resource": "arn:aws:s3:::*",
         "Condition":{"StringLike":{"s3:prefix":["mybucket"]}}
      },
      {
        "Sid": "AllowListingOfUserFolder",
        "Action": ["s3:ListBucket"],
        "Effect": "Allow",
        "Resource": ["arn:aws:s3:::mybucket"],
        "Condition":{"StringLike":{"s3:prefix":["myfolder/*"]}}
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion"
         ],
         "Resource":"arn:aws:s3:::mybucket/myfolder/*"
      }
   ]
}
```
