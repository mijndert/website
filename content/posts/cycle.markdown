---
title: "Creating a workflow for Terraform using GitHub Actions"
date: 2020-05-08 
permalink: /thought/2020/terra/
description: "How to connect Terraform and GitHub Actions together."
---

Recently I started working with Terraform more and more, as CloudFormation is lagging behind in terms of support for newer AWS services. Terraform has quite a steep learning curve, but once it _clicks_ you never want to go back to the old days.

I created a [public repository](https://github.com/mijndert/terraform) up on GitHub so I can play around with Terraform and other related tools. This week [GitHub Satellite](https://githubsatellite.com/) is on, which brought us a much needed feature: a proper GitHub Action for working with Terraform in a CI/CD pipeline. The action is called [setup-terraform](https://www.terraform.io/docs/github-actions/setup-terraform.html) and is available right now.

Here's how it works.

If you take a look at [my repository](https://github.com/mijndert/terraform) you can see I've built a simple VPC module which I'm calling from `vpc.tf` in the root of the repository. Before you dive in, you first have to configure [Secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets). Secrets is where you will store your AWS credentials so Terraform can reach your environment and roll out changes if needed.

## Setting up Secrets

Head to your GitHub repository settings where your Terraform templates are stored. In the left sidebar you'll find Secrets. We'll need three Secrets for the workflow to work:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (example: eu-west-1)

Have a look at [the documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) if you want to know how to obtain AWS credentials.


## Breaking down the workflow

Now that we've got our Secrets set up, we can create a GitHub Action. In your GitHub repository, select Actions from the top menu and click _set up a workflow yourself_.

Let's break down each step.

This GitHub Action will run on Ubuntu and will invoke a bash shell so we can set environment variables.

```yaml
terraform:
  name: 'Terraform'
  runs-on: ubuntu-latest

  defaults:
    run:
      shell: bash
```

The following step will install Terraform.

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v1
```

This is how the Action will use the Secrets you configured earlier to set environement variables. Terraform will use these credentials to talk to AWS' API.

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
```

Once we have Terraform set up and the credentials loaded as environment variables we can run all commands you're familiar with from running Terraform locally.

```yaml
- name: Terraform init
  run: terraform init
- name: Terraform validate
  run: terraform validate
- name: Terraform format
  run: terraform fmt -check
- name: Terraform plan
  run: terraform plan
```

If you work with proper a proper Git branching strategy and make sure code [only gets into master](https://help.github.com/en/github/administering-a-repository/about-protected-branches) using pull requests, you can also `terraform apply` right from your workflow.

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/master' && github.event_name == 'push'
  run: terraform apply -auto-approve
```

Using [this workflow](https://github.com/mijndert/terraform/blob/master/.github/workflows/terraform.yml) in GitHub Actions you have a fully automated CI/CD pipeline that will validate your code, and even deploy changes to the correct environment when everything checks out. Of course you can go crazy with multiple environments and repositories but these are the basics. Try it out, I'd love to see what you do with it.
