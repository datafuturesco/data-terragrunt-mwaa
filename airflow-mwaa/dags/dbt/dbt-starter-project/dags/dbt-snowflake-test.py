import os
import json
import yaml
import subprocess
from dateutil import parser

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable
from airflow.decorators import dag, task, task_group
from airflow.utils.task_group import TaskGroup

from datetime import datetime
import pendulum

local_tz = pendulum.timezone('America/New_York')

DAG_ID = os.path.basename(__file__).replace(".py", "")

# Set all the variables!
env_vars = {}
for item in [
    'DBT_USER',
    'DBT_PASSWORD',
    'DBT_SNOWFLAKE_ACCOUNT',
    'DBT_DBNAME',
    'DBT_ROLE',
    'DBT_SCHEMA',
    'DBT_WAREHOUSE',
    'DBT_ENV',
]:
    try:
        test = Variable.get(item)
        if test:
            os.environ[item] = test
            env_vars[item] = '{{ var.value.' + item + ' }}'
    except Exception as e:
        pass

HOME = os.environ["HOME"]  # retrieve the location of your home folder
project_name = DAG_ID.split('__')[0]
dbt_path = f"{HOME}/dags/dbt/dbt-starter-project/dbt"
new_dbt_path = f"/tmp/dbt-{project_name}"
dbt_exec = f'/usr/local/airflow/.local/bin/dbt'
manifest_path = f"{new_dbt_path}/target/manifest.json"  # path to manifest.json

print('dbt_path', dbt_path)
print('new_dbt_path', new_dbt_path)
print('dbt_exec', dbt_exec)
print('manifest_path', manifest_path)
print('env_vars', env_vars)

with DAG(
        dag_id=DAG_ID,
        description="Run the {dir_path} DBT code.",
        start_date= datetime(2024,5,15, tzinfo=local_tz),  # Start date of the DAG
        schedule_interval = "25 7 * * *",
        catchup=False,
        concurrency=3, 
        max_active_runs=1,
) as dag:
    with TaskGroup(group_id='bash_task') as bash_task:
        bash_check = BashOperator(
            task_id='bash_check',
            bash_command='echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbdata && echo "Current Working Directory: $(pwd)" '
        )
        
    with TaskGroup(group_id='dbt_task') as dbt_task:
        dbt_run = BashOperator(
            task_id="dbt_run",
            bash_command=f'rm -rf {new_dbt_path} '
                         + f' && cp -rf {dbt_path} {new_dbt_path}'
                         + f' && cd {new_dbt_path} && {dbt_exec} deps'
                         + f' && cd {new_dbt_path} && {dbt_exec} seed && {dbt_exec} compile --profiles-dir .'
                         + f" && {dbt_exec} run --profiles-dir .",
            env=env_vars,
            retries=1,
        )
        
        dbt_run
        
    bash_task >> dbt_task
    
if __name__ == "__main__":
    dag.cli()