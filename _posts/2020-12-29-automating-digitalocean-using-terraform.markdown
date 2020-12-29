---
layout: post
title: "Automating Digitalocean using Terraform"
date: 2020-12-29
permalink: /thought/:year/automating-digitalocean-using-terraform/
description: "Employing infrastructure as code to save a few clicks."
---

I've been an AWS engineer/consultant for 13 years already, but [Digitalocean](https://m.do.co/c/7333c5d3f093) will always be my go-to for personal projects. AWS is usually too complicated and expensive a platform for my needs. Sometimes I just need a quick VM to test some stuff out, or get something on the internet quickly.

I've had a shell script that bootstraps my Linux VM's for the longest time, it installs a bunch of packages, creates users, configures the timezone and much more. But the process of creating a new Droplet was still something I did by hand. Now, I've had quite a bit of experience with Terraform, I've been using it at a few different clients for AWS deployments after all. Luckily, there's a [Terraform provider for Digitalocean](https://registry.terraform.io/providers/digitalocean/digitalocean/latest) as well, and it's pretty awesome.

I went looking for examples on how other people used Terraform to deploy Droplets and Kubernetes clusters on Digitalocean. What I found however was a whole load of outdated code. Since those articles were written both Terraform and the Digitalocean provider had seen significant changes.

I created my own quickstarts to make it just that much easier to work with Digitalocean: meet [Jaws](https://github.com/mijndert/jaws) and [Wheel](https://github.com/mijndert/wheel). 

Here's what I learned along the way.

## Installing Terraform

**macOS**

Install using [Homebrew](https://brew.sh/):

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows**

Install using [Chocolatey](https://chocolatey.org/):

```
choco install terraform
```

**Ubuntu**

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

## Credentials

In order to interface with the Digitalocean API you need a [Personal access token](https://cloud.digitalocean.com/account/api/tokens). This token should be kept safe since it will grant read and write access to your Digitalocean account. 

You can make the token available in your CLI by setting an environment variable:

```
export DIGITALOCEAN_ACCESS_TOKEN=<personal access token>
```

Older versions of the Digitalocean provider seemed to not automatically look for this environment variable, the latest one most definitly does. All you need to do to set up the provider is:

```
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.3"
    }
  }
}
```

## Getting information from the API

When you want to launch for example a Droplet you need to know the names of both Images and Droplet sizes. The provider documentation doesn't make it abundantly clear what the values can and should be. You can look at the API documentation, but you can also ask the API directly:

```
curl -X GET --silent "https://api.digitalocean.com/v2/images?per_page=999" -H "Authorization: Bearer $DIGITALOCEAN_ACCESS_TOKEN" |jq '.'
```

## Adding an SSH key

You can add your own SSH key for authentication to each Droplet you launch. Using Terraform it's really easy to add your own:

```
resource "digitalocean_ssh_key" "this" {
  name               = "Terraform Example"
  public_key         = file("~/.ssh/id_rsa.pub")
}
```

When you create a Droplet you can now point to this SSH key's fingerprint to add it at runtime:

```
ssh_keys = [digitalocean_ssh_key.this.fingerprint]
```

## The Digitalocean provider is really simple and elegant 

While the documentation could definitely be improved I'll start with infrastructure-as-code first for all of my Digitalocean needs. It's just too simple to add a Droplet, create a Kubernetes cluster or configure a Cloud Firewall. Using Terraform will also allow me to more efficiently remove unused resources. When I create resources by hand it's a bit cumbersome to go back and delete everything once I'm done.

If you want to learn more about Terraform I recommend you start with the [getting started guide](https://www.terraform.io/intro/index.html). It explains in detail what Terraform is and how you can get started using it for all kinds of different use-cases.