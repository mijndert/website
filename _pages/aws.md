---
layout: page
title: AWS explained
description: "A continously updated (brief) guide to AWS."
permalink: /aws/
---

In the old world you had to do extensive research into the right equipment that would hopefully meet all of your demands. Then you had to order the hardware, which would take another month, and then someone had to install and configure the equipment. Provisioning a bunch of servers would easily take a few months. **We're now building an entirely new class of infrastructure and democratizing them so anyone has access to them**.

Today, companies can provision their infrastructure in just a few minutes and scale the amount of resources up and down as demand fluctuates. In the meantime, you just pay for the resources that you actually use. This kind of flexibility **democratizes access to compute resources**  and allows anyone with the right idea to build it and scale to millions of users without spending a dime up-front.

That's where AWS comes in.

AWS is short for Amazon Web Services. **The world’s largest online book store also happens to run the world’s largest public cloud provider**. Back in 2006 AWS launched with just a handful over services. Today, AWS offers PaaS (platform as a service), IaaS (infrastructure as a service), serverless computing, and much more, with well over 200 different services and products.

In this guide I want to go through as many services as possible and (briefly) explain what the service is and how you can benefit from using it.

## Compute

- [EC2 (Elastic Compute Cloud)](#) &mdash; Much like a VPS or a virtual machine. EC2 offers compute power and full administrator access to a server running either Linux, Windows or even macOS. EC2 offers before Intel (X86) and Graviton (ARM) options for its CPU. 
- [EC2 Autoscaling](#) &mdash; Offers services designed to automatically scale the amount of EC2 instances up or down as load/demand fluctuates. 
- [Lightsail](#) &mdash; A service similar to EC2 but with the pricing model of a company like DigitalOcean or Linode as a predetermined amount of data transfer is included in the price.

## Storage

- [S3 (Simple Storage Service)](#) &mdash; A service that offers unlimited storage. You can put files up to 5 Terabytes in so called buckets, which act like folders. You can interface with S3 via the API but there are a lot of third-party clients as well.
- [EFS (Elastic File System)](#) &mdash; Offers NFS volumes in the cloud, with the added value that you don't have to provision any storage yourself. EFS will grow the storage automatically for you.
- [EBS (Elastic Block Store)](#) &mdash; Acts like a USB drive for your compute resources. EBS offers so called volumes which can be up to 16 Terabytes in size and come in many different variants. There's a variant which offers cheap but slow storage, and a variant which offers very fast storage but that comes at a price.
- [AWS Backup](#) &mdash;
- [Storage Gateway](#) &mdash;

## Networking and content delivery

- [VPC (Virtual Private Cloud)](#) &mdash;
- [Transit Gateway](#) &mdash;
- [Route53](#) &mdash;
- [AWS Shield](#) &mdash;
- [WAF (Web Application Firewall)](#) &mdash;
- [Direct Connect](#) &mdash;
- [CloudFront](#) &mdash;

## Security

- [IAM (Identity and Access Management)](#) &mdash;

## Databases

- [RDS (Relational Database Service)](#) &mdash;
- [DMS (Database Migration Service)](#) &mdash;
- [DynamoDB](#) &mdash;
- [Redshift](#) &mdash;
- [Elasticache](#) &mdash;
- [DocumentDB](#) &mdash;

## Serverless

- [Lambda](#) &mdash;
- [API Gateway](#) &mdash;
- [Step Functions](#) &mdash;
- [Aurora Serverless](#) &mdash;

## Containers

- [ECS (Elastic Container Service)](#) &mdash;
- [ECR (Elastic Container Registry)](#) &mdash;
- [EKS (Elastic Kubernetes Service)](#) &mdash;
- [Fargate](#) &mdash;

## Analytics

## Machine Learning 

## Other

- [SQS (Simple Queue Service)](#) &mdash;
- [](#) &mdash;
- [](#) &mdash;