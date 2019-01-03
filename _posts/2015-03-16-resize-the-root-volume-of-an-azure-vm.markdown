---
layout: post
title: Resize the root volume of an Azure VM
date: 2015-03-16 13:40:59.000000000 +02:00
permalink: /writing/posts/resize-the-root-volume-of-an-azure-vm/
---
Every [Azure virtual machine](http://azure.microsoft.com/nl-nl/services/virtual-machines/) comes with a certain amount of storage for it's root volume, plus a few hundred GigaBytes of *instance storage* which will get deleted if you reboot the VM. For storing data you can either create a new disk and attach it to your VM, or you can resize the root volume with a little trick I learned.

<!-- more -->

We're going to use [Cloudxplorer](http://clumsyleaf.com/products/cloudxplorer) to do the actual resizing of a disk attached to an Ubuntu VM, so you'll need to install that first.

The first step is to log in to the [Azure Portal](https://manage.windowsazure.com/) and stop the VM you want to edit. Wait for the VM to properly stop before doing anything else.

Now have a look at the storage account in which your VHD resides and click "Manage Access Keys". Take note of the *storage account name* and *primary access key*.

![](/assets/images/azure-resize-1.png)

In Cloudxplorer choose *Accounts > New > Azure Blobs Account* and insert your storage account name* and *primary access key*.

![](/assets/images/azure-resize-2.png)

Once your storage account shows up, right-click the VHD you want to resize and choose *break lease*. This will decouple the VHD from the VM. Right-click the VHD again and choose *expand virtual disk*.

![](/assets/images/azure-resize-3.png)

After the resize operation is done you can right-click the VHD to *acquire lease* and attach the VHD to the VM again. In the Azure Portal you can then start the VM.

--------
source: [http://www.ms4u.info/2014/03/how-to-expand-virtual-disk-in-windows.html](http://www.ms4u.info/2014/03/how-to-expand-virtual-disk-in-windows.html)
