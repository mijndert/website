---
layout: post
title: 'Orchastrator: Arithmetic operation resulted in an overflow'
date: 2013-03-15 13:00:00.000000000 +02:00
permalink: /writing/posts/orchastrator-2012-arithmetic-operation-resulted-overflow/
---
If you, by chance, want to use Microsoft System Center Orchastrator 2012 to create user accounts in your Active Directory, you might run into a problem with the Get User activity. There's a weird bug persisting in Orchestrator caused by the Maximum Password Age in your Group Policy Object (GPO). If this value is set to 0, the Runbook will fail stating the "Arithmetic operation resulted in an overflow".

<!-- more -->

To fix this issue, go into your Group Policy Management and edit your GPO. Go into Policies > Security Settings > Account Policies > Password Policy. Now change the Maximum Password Age value to 999.
