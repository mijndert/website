---
layout: post
title: Serve 503 maintenance pages with Lighttpd
date: 2012-09-05
permalink: /writing/posts/503-maintenance-pages-lighttpd/
---
Every website needs some maintenance every now and then. Maybe you're pushing some major updates or your database server needs an upgrade. In any case, it's nice to have a maintenance page to let your visitors know service will be restored soon. This maintenance page could be a simple HTML file but by default there isn't really a way to push a 503 status code. I created a small LUA wrapper script to fix this issue.

<!-- more -->

The LUA scripts looks like this.

```lua
if (lighty.stat(lighty.env["physical.doc-root"] .. "/index.html")) then
                lighty.content = { { filename = lighty.env["physical.doc-root"] .. "/index.html" } }
                lighty.header["Content-Type"] = "text/html"
        return 503
end
```

As you can see we wrap the index.html of our maintenace page and return a 503 status code. Now we need to tell our Lighttpd virtual host what to serve.

```bash
$HTTP["host"] =~ "(^|www\.)your-vhost\.tld" {
                server.document-root = "/var/www/your-vhost"
                magnet.attract-physical-path-to = (server.document-root + "/magnet.lua")
}
```
