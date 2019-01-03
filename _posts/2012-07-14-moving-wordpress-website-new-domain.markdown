---
layout: post
title: How to move a WordPress website to a new domain
date: 2012-07-14
permalink: /writing/posts/moving-wordpress-website-new-domain/
---
If you want to move your entire WordPress website to a new domain there's just three SQL queries to run. First we can change the base URL of the website.

<!-- more -->

```sql
UPDATE wp_options SET option_value = replace(option_value, 'http://www.olddomain.tld', 'http://www.newdomain.tld') WHERE option_name = 'home' OR option_name = 'siteurl';
```

Next we need to change every URL to existing blogposts. This value is stored in a GUID in the wp_posts table.

```sql
UPDATE wp_posts SET guid = replace(guid, 'http://www.olddomain.tld','http://www.newdomain.tld');
```

If you have links to blog posts and pages using absolute URL's you will also need to update this to the new website location.

```sql
UPDATE wp_posts SET post_content = replace(post_content, 'http://www.olddomain.tld', 'http://www.newdomain.tld');
```
