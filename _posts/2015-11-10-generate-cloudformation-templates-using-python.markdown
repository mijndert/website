---
layout: post
title: Generate CloudFormation templates using Python
date: 2015-11-10 21:37:55.000000000 +02:00
permalink: /writing/posts/generate-cloudformation-templates-using-python/
---
[Troposphere](https://github.com/cloudtools/troposphere) is a Python library which makes it easier to write and maintain [CloudFormation](https://aws.amazon.com/cloudformation/) templates. From the README:

> The troposphere library allows for easier creation of the AWS CloudFormation JSON by writing Python code to describe the AWS resources. Troposphere also includes some basic support for OpenStack resources via heat.

> To facilitate catching CloudFormation or JSON errors early the library has property and type checking built into the classes.

<!-- more -->

Troposphere can be easily installed inside a [virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/) with *pip install troposphere*. It's also probably a good idea to make sure you can [switch AWS accounts](http://mijndertstuij.nl/quickly-switch-accounts-using-aws-cli/) quickly on the CLI. This is needed when we want to run Ansible playbooks against CloudFormation. More on that later.

Let's get to some examples.

### Imports

Every Troposphere file has to start with a few *imports* and a description.

```python
from troposphere import Base64, GetAtt, GetAZs, If, Select, Join, Output, Parameter, Ref, Template, Tags
from troposphere import rds, ec2

__author__ = 'Mijndert Stuij'

def GenerateRDSInstance():
    t = Template()

    t.add_description("RDS instance in existing VPC")
```

### Params

After that we will put in a few *params* which we will with data using Ansible later on. Here's a parameter for the name of the CloudFormation stack.

```python
stackname_param = t.add_parameter(Parameter(
    "stackname",
    Description="Environment Name (default: StackNameNotDefined)",
    Type="String",
    Default="StackNameNotDefined",
))
```

And here's a param for the name of a database. Notice the constraints we can use.

```python
dbname = t.add_parameter(Parameter(
    "dbname",
    Default="MyDatabase",
    Description="The database name",
    Type="String",
    MinLength="1",
    MaxLength="64",
    AllowedPattern="[a-zA-Z][a-zA-Z0-9]*",
    ConstraintDescription=("must begin with a letter and contain only"
                           " alphanumeric characters.")
))
```

### Creating an RDS instance

Here's an example of a Troposphere template which will create a CloudFormation JSON file that will launch an RDS instance. We'll give the RDS a name, assign some storage and a subnet, and we will say that its engine should be MySQL 5.6.

Notice the *ref* being used in some places. You can *ref* to a *param* to get its value returned.

```python
rdsinstance = t.add_resource(rds.DBInstance(
    "rdsinstance",
    DBName=Ref(dbname),
    AllocatedStorage=Ref(dballocatedstorage),
    DBInstanceClass=Ref(dbclass),
    Engine="MySQL",
    EngineVersion="5.6",
    MasterUsername=Ref(dbuser),
    MasterUserPassword=Ref(dbpassword),
    DBSubnetGroupName=Ref(dbsubnetgroup),
    VPCSecurityGroups=[Ref(dbsecuritygroup)],
    MultiAZ="True",
    AutoMinorVersionUpgrade="False",
    BackupRetentionPeriod="7",
    StorageType="gp2"
))
```

### Outputs

CloudFormation allows us to give some output after CloudFormation is done doing its business. In this case we will *join* some data together to create a JDBC connection string. You can copy-paste this into the configuration of your application, obviously.

```python
t.add_output(Output(
    "JDBCConnectionString",
    Description="JDBC connection string for database",
    Value=Join("", [
        "jdbc:mysql://",
        GetAtt("rdsinstance", "Endpoint.Address"),
        ":",
        GetAtt("rdsinstance", "Endpoint.Port"),
        "/",
        Ref(dbname)
    ])
))
```

### Return JSON

Notice how in the beginning of this tutorial we did `t = Template()`? To generate the CloudFormation JSON file we'll need to write the result of our Troposphere code to valid JSON. Troposphere will do this for us, of course.

```python
return t
if __name__ == "__main__":
    t = GenerateRDSInstance()
    with open('../cfm/rds.json', 'w') as f:
        f.write(str(t.to_json()))
    print "JSON written"
```

### Results

Here's the results of our hard work:

- [Troposphere template](https://gist.github.com/mijndert/9e0587f6b188f641def7)
- [CloudFormation JSON](https://gist.github.com/mijndert/c6af61fed8b6427313dc)

Some documentation on functions can be found on [Nullege](http://nullege.com/codes/search/troposphere).

### Ansible

To make it easy to fill in the blanks on those *params* I use Ansible. Ansible can talk to CloudFormation to either run new CloudFormation stacks, or destroy them completely.

This is the last step in this tutorial. Again, Ansible will fill in our *params* using Ansible's *vars* function and then we tell Ansible to run a CloudFormation task using our JSON file.

This allows you to run the same JSON file again and again by just changing some variables in an Ansible playbook.

```yaml
#
# ansible-playbook -i localhost-inventory ansible/rds.yml
#
---
- hosts: localhost
  connection: local
  gather_facts: False
  vars:
  - account: "MyAccountName"
  - stackname: "RDS"
  - dbname: "myDatabase"
  - dbuser: "myUser"
  - dbpassword: "myPassword"
  - dbclass: "db.t2.small"
  - dballocatedstorage: "5"
  - sourcesg: "sg-1234567"
  vars_files:
  - ../var/MyAccountName.yml
  tasks:
  - name: Run rds cfm template
    cloudformation:
      stack_name: "{{stackname}}"
      state: present
      region: "{{region}}"
      template: "../cfm/rds.json"
      template_parameters:
        stackname: "{{ stackname }}"
        vpcid: "{{ vpcid }}"
        prsubnets: "{{ prsubnets }}"
        pusubnets: "{{ pusubnets }}"
        dbname: "{{ dbname }}"
        dbuser: "{{ dbuser }}"
        dbpassword: "{{ dbpassword }}"
        dbclass: "{{ dbclass }}"
        dballocatedstorage: "{{ dballocatedstorage }}"
        sourcesg: "{{ sourcesg }}"
      tags:
        Stackname: "{{ stackname }}"
        Customer: "Company Ltd."
    register: rds
  - name: show output
    debug: var=rds
```
