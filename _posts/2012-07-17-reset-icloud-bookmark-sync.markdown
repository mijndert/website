---
layout: post
title: How to reset iCloud bookmark sync
date: 2012-07-17
permalink: /writing/posts/reset-icloud-bookmark-sync/
---
Some people get into a huge bookmark mess when they want to merge and sync their bookmarks via iCloud. This is how I finally fixed my issue.

<!-- more -->

1. Turn off iCloud bookmark sync on all of your devices except the Mac, choose to delete all previously synced bookmarks
2. Create a backup of your current bookmarks on your Mac, they are located in: ~/Library/Safari/Bookmarks.plist.
3. Correct your bookmarks in Safari on your Mac, make sure everything is the way you want it to be
4. Create another backup of your Safari bookmarks
5. Delete all bookmarks in Safari on your Mac and wait for iCloud to catch up
6. Move your bookmarks backup back into the Library folder and wait for iCloud to catch up again
7. Turn on iCloud bookmarks sync on your other devices
