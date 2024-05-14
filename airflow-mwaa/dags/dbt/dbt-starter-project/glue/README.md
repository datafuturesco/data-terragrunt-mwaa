# Wholesale Data Product - Glue Jobs

## What is this folder for? ##

This stores the glue jobs for this product repo. It allows us to keep a copy of each Glue job to ensure we can reproduce
all aspects of our orders in another system. Each glue job is also send to to the MWAA repo for us with 

* About Glue: https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html


## How do I deploy? ##

The visual editor found at https://us-east-1.console.aws.amazon.com/gluestudio/home?region=us-east-1#/jobs?selectedInterface=source_and_target
is where all the processes are deployed. 

After you update a job click on `Actions` -> `Push to repository`. This will do a git commit for you of the updated
job code.

## How do I get a job set up with version control? ##

Each job must have the version control manually setup. To save you time, here are the entries you should provide.

```yaml
Git service: GitHub
Personal access token: [TODO - generate one]
Repository owner: david-yurman
Repository: data-wholesale (this repo)
Branch: dev (the branch you are working on)
Folder: glue/jobs
```


## Contribution guidelines ##

We use a campground philosophy, meaning leave things better than you find them.

## Who do I talk to? ##

* Elliott Cordo
* Dōvy Paukstys

## To Be Done 
* Find a safe place to store the access token bound to a single repo.

## Known Issues

* Job pushing is NOT automatic. You have to make sure that you commit the changes manually.
