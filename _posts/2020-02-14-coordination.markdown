---
layout: post
title: "Things I've learnt while setting up a GitHub repository"
date: 2020-02-14
permalink: /thought/:year/coordination/
description: "GitHub has some incredible tools for teams to work together, you just have to make use of them."
---

For the past few weeks I've been planning and working on [a new project](https://github.com/mijndert/cloudformation). It's not a very novel idea but it's something I want to exist and I'm hoping others will get some value out of it as well.

As I want this project to be bigger than just myself I wanted to make sure the project is set up for easy managent and automation. I made use of just about every trick GitHub has on offer, like issue labels, projects, and GitHub Actions.

Along the way I learned a lot about setting up a GitHub repository.

## Create issues for everything

Instead of keeping your own to-do list of stuff you still need to implement for your project, keep a public to-do list by creating issues on GitHub. This way other people can have a look at the roadmap and they can pick their own issues to work on as well. At first, you can just dump some information in the issue and make it more specific along the way.

Another good thing is to [add sub-tasks](https://github.blog/2013-01-09-task-lists-in-gfm-issues-pulls-comments/) in the issue by adding a task list. GitHub will automatically show the progress on the sub-tasks on the list of issues, which is an even better way or keeping track of everything.

## Make use of issue templates

Another great feature of GitHub issues is the ability to create [issue templates](https://help.github.com/en/github/building-a-strong-community/configuring-issue-templates-for-your-repository). These templates are used whenever someone tries opening an issue on your project. You can fully optimize the issue template to suit the needs of your project. These templates make sure things like bug reports and feature requests are written in a predictable way and helps people from filling out the correct information.

## Label all issues

A GitHub repository can never have enough [labels for issues](https://help.github.com/en/github/managing-your-work-on-github/about-labels). I created labels for general development, feature requests, bug reports, and many more. Using filter queries you can filter out your issue list making it super easy to find what you're looking for. It will also help contributors from finding out what to work on next.

## Automate everything using GitHub Actions

GitHub Actions is a great way to automate all sorts of tasks and have a proper CI/CD setup going. My project has an action that runs on every commit that uses _cfn-lint_ to check the code quality of the CloudFormation templates. There's [actions for just about everything](https://github.com/marketplace?type=actions) and you can also [create actions yourself](https://help.github.com/en/actions) if you have some need that's not yet provided for by the community.

## Create an automated project board

Once you have your issues set up, you can also create an [automated kanban board](https://help.github.com/en/github/managing-your-work-on-github/about-project-boards). If you assign your issues to the correct project board, they will automatically show up in the _backlog_ column of the kanban board. When an issue gets reoponed it will automatically move to _To Do_ and when I close an issue it will move to _Done_. The only thing I didn't automate is a column named _In progress_. I'm using this kanban board to have a visual roadmap of the project.
