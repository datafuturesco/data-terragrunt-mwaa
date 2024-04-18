# Data Terragrunt MWAA Shared Modules Repository

Another great feature of Terragrunt is the ability to store terraform code for modules
in a remote repository. This allows various Terragrunt repositories to reuse common code 
defined anywhere (DRY). You can even version lock to tagged releases the code so that you can
ensure there is not feature creep. And you can also isolate that per deployed environment
as well. See https://github.com/dovy-yurman/terragrunt-example-modules for an example of
such a shared module repository. In this repository `~/live/dev/us-east-1/applications/airflow-mwaa/s3-bucket/terragrunt.hcl`
file provides examples of referencing remote module by way of branch as well as tagged version.

## Project Layout



```text
├── live/
│   └── [ENV_NAME]/
│      └── env.hcl
│      └── account.hcl
│      └── [REGION]/
│         └── region.hcl
├── modules/
```

You are welcome to create multiple regions per environment and any number of environments. An example
would be:

```text
├── live/
│   └── defaults.hcl
│   └── dev/
│      └── env.hcl
│      └── account.hcl
│      └── us-east-1/
│         └── region.hcl
│   └── stage/
│      └── env.hcl    
│      └── account.hcl    
│      └── us-east-1/
│         └── region.hcl
│      └── us-east-2/
│         └── region.hcl
```

In this case the `dev` environment would be deployed to `us-east-2`, but the `stage` environment would
have resources in `us-east-1` and `us-east-2`.

| File        | Description                                                                                                                                                     |
|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| default.hcl | This is the primary config file for this repository. It sets the default `platform` name, as well as many other variables.                                      |
| env.hcl     | A dynamic file which uses the `[ENV]` folder as the variable. Must be at the region level.                                                                      |
| region.hcl  | A dynamic file which uses the `[REGION]` folder as the variable. Must be at the region level.                                                                   |
| account.hcl | An override config file which allows you to bypass values set by the `defaults.hlc` file. This is for use when you have environments in different AWS accounts. |

#### Local `modules` folder

During development, or if you do not find a need to share modules outside of this repo, you may
store your terraform code within a `modules` folder within the repo. Remember `live/` is for invoking 
module code. No direct terraform should ever be stored in `./live`. You reference this code as a source
in the manner displayed within `~/`

#### Debugging Variables

Since debugging the inheritance can be fairly difficult, you can run the below command. It will
generate a `terragrunt-debug.tfvars.json` file at the `~/live/[ENV]/[REGION]/[MODULE]`
path. This will contain all the values passed to the module (terraform) code.

```commandline
terragrunt run-all plan --terragrunt-debug
```

#### Running & Testing Code

Running this repo matches the commands that terraform offers, except you must prepend the
command with `terragrunt run-all`. Run these commands within the `live` folder.

```commandline
terragrunt run-all [STANDARD TERRAFORM COMMAND]
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy
```

If you want to isolate to a single environment, there are two simple approaches.
Each approach can be used to isolate down to a single region, module, etc.

###### 1. Isolate Execution w/ `--terragrunt-working-dir` 
Use the `--terragrunt-working-dir` and provide a full path to the folder you want to 
isolate. You can use this from the root folder of this repository. Be sure to use ./
to instruct terragrunt it's relative to the current path.

```commandline
terragrunt run-all plan --terragrunt-working-dir ./live/dev/
```

###### 2. Isolate Execution by `cd`
The second method is less specific to invoke. Simply navigate to the folder where you 
want to perform recursive execution. The folder you are in will serve as the top level
folder for execution. An example of this approach is as follows.

```commandline
cd live/dev
terragrunt run-all plan
```

#### GitHub Deploy User Setup
Once an instance is deployed, a user will be created. An example of such users would be `dwp-[NAME]-[ENV]-github-deploy`. This user is created for the purpose of GitHub deployment. It has access to the bucket created for MWAA so you can set multiple repos to push to a given MWAA instance. However, you must manually create the access key as this cannot be automated in an effective way. Have someone with IAM go through and create the key. Then you can store these values in the repo under the following variables:
- AWS_S3_BUCKET__[ENV]
- AWS_ACCESS_KEY_ID__[ENV]
- AWS_SECRET_ACCESS_KEY__[ENV]

Then the GitHub Action, as found in repos in https://github.com/david-yurman/data-wholesale, can be used for automated deployment.
