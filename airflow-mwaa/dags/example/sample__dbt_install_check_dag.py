from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
import os
import pendulum

DAG_ID = os.path.basename(__file__).replace(".py", "")

dir_path = os.path.dirname(os.path.abspath(__file__))+'/../dbt'
print(dir_path)

local_tz = pendulum.timezone('America/New_York')

with DAG(
        dag_id=DAG_ID,
        schedule_interval=None,
        description="DBT installed properly check dag. {dir_path}",
        catchup=False,
        start_date=days_ago(1),
        # start_date= datetime(2024,3,11, tzinfo=local_tz),  # Start date of the DAG
) as dag:
    cli_command = BashOperator(
        task_id="bash_command",
        bash_command=f"/usr/local/airflow/.local/bin/dbt --version"
    )
