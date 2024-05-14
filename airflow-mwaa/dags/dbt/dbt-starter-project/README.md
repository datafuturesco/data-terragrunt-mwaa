# Data Product Example Repo

## What is this repository for?

This repo is a project repo example for other projects to clone. Enclosed are DDLs, DAGs, and DBT models for deploying the entire model structure within Snowflake.

- About DBT: https://www.getdbt.com/
- About Airflow (DAGs): https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html

## How do I deploy?

The repo auto-deploys the code to MWAA on each commit using GitHub actions. If you want to manually run it, you will need to
configure DBT locally. `See the How do I get set up?` section for more details.

## How do I get set up?

- Follow these instructions to install via pip: https://docs.getdbt.com/docs/core/pip-install
- Create/append the following information to your `~/.dbt/profiles.yaml` file. Remember to update the bracketed values
  with your login

```yaml
data_warehouse:
  outputs:
    dev:
      account: ltb53227.us-east-1
      database: [PRODUCT]_DEV_STG
      password: [SNOWFLAKE PASSWORD]
      role: [YOUR DEFAULT ROLE]
      schema: development
      threads: 1
      type: snowflake
      user: [SNOWFLAKE USERNAME]
      warehouse: READ_WH
  target: dev
```

- `cd` into dbt and run the command `dbt run`

By using the above config, all models that are not specified a schema will be deployed to a schema with the prefix of `development_`.

## CI/ CD

CI/CD is automatic thanks to GitHub actions. There are 3 keys that get configured which control all deployment at each
commit.

- `AWS_ACCESS_KEY_ID__[ENV]`
- `AWS_SECRET_ACCESS_KEY__[ENV]`
- `AWS_S3_BUCKET__[ENV]`

The `ENV` must match the branch name.

The GitHub actions are simple. At each commit, the `dags`, `dbt`, and `glue/jobs` folders are inspected for changes.
If changes are detected, the access key info is used to upload to the specified S3 bucket. This gets picked up by the
running MWAA instance and all changes to that branch are deployed to the environment.

## Contribution guidelines

We use a campground philosophy, meaning leave things better than you find them.

## Who do I talk to?

- Elliott Cordo
- Dōvy Paukstys

## To Be Done

- more tests
- Perhaps we should create a util to deploy DDLs automatically?

## Known Issues

- We haven't yet fully tested in multiple environments. There may be some issues when that occurs.
- DDLs are very manual and must be run one at a time.
