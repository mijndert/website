---
layout: post
title: Export and import AWS Cloudsearch data
date: 2016-04-01 10:04:21.000000000 +02:00
permalink: /writing/posts/exporting-cloudsearch-data/
---

[AWS CloudSearch](https://aws.amazon.com/cloudsearch/) is a highly scalable and reliable solution to implement search in your application or website. You can feed your search data into the service and never have to worry about performance or in any way scaling it to fit your needs. AWS CloudSearch supports about 34 languages and [features](https://aws.amazon.com/cloudsearch/details/) such as highlighting, autocomplete and geospatial search.<!-- more -->

One downside though is that there's currently no easy way of exporting your data out of AWS CloudSearch. You might want to have the same exact data in your production account after playing with the service in your sandbox account. After a few tries I figured out how to export the data and import it back into a new CloudSearch domain.

I'm assuming you already have a new CloudSearch domain set up and ready to go.

### Exporting the data

AWS CloudSearch can be accessed by HTTP(S) as you might already know. You can use that to our advantage to create some ugly output of our data.

```bash
https://<cloudsearch-domainname>-<cloudsearch-id>.<region>.cloudsearch.amazonaws.com/2013-01-01/search?q=matchall&size=600&q.parser=structured
```

You can find the first part of that URL in the AWS web console. Let's break the other parts down.

You should append ```2013-01-01``` if you use the 2013 API version for CloudSearch. To get all results I used ```search?q=matchall``` followed by ```&size=600``` to ask for 600 items. If you have more items change this number to the desired amount. To get actual structured JSON I pass ```&q.parser=structured``` as the last argument.

Now that you have our results in a browser window (or curl) you can copy-paste this into a new JSON file, for example output.json.

### Working with the JSON

Unfortunantly the JSON you have now isn't yet ready to import back into CloudSearch. You need to modify a few things here and there.

#### Readability

The make the JSON a little more readable you need to lint it. The fastest way I found is using a little utility called [jsonpp](https://github.com/jmhodges/jsonpp). You can install it on a Mac using [Homebrew](http://brew.sh/) (```brew install jsonpp```).

To create a file with readable JSON you can do:

```bash
jsonpp output.json > output_pretty.json
```

#### Modifying the JSON file

1. First you need to get rid of the first part of the JSON, for me it looked something like this: ```{"status":{"rid":"<some ID>","time-ms":2},"hits":{"found":576,"start":0,"hit":```
2. Now get rid of the last two curly brackets ``}}``
3. Make sure the JSON has a ```[``` at the beginning and ```] ```at the end so it's all one big array
4. Use the search & replace function of your editor to replace all occurrences ```"fields": {``` with ```"type" : "add" ,"fields": {```

That last step is important because it tells CloudWatch you want to add these records to the domain.

### Importing the data

Now that you have our JSON all cleaned up you can start importing the data into our new CloudSearch domain using the AWS-CLI tools:

```bash
aws cloudsearchdomain --endpoint-url https://<cloudsearch-domainname>-<cloudsearch-id>.<region>.cloudsearch.amazonaws.com upload-documents --content-type application/json --documents ./output_pretty.json
```
