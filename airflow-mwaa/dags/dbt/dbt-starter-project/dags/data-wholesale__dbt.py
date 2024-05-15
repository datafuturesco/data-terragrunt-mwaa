from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
}

dag = DAG(
    'dbt_snowflake_test',
    default_args=default_args,
    description='A DAG with a BashOperator to run dbt tasks',
    schedule_interval='@daily',
    start_date=days_ago(1),
    catchup=False,
    tags=['snowflake tasks']
)

# Define BashOperator task to echo pwd and change directory
extract_load = BashOperator(
    task_id='echo_and_cd',
    bash_command='echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbttest && echo "Current Working Directory: $(pwd)" && dbt run --full-refresh --models src.* --profiles-dir . ',
    dag=dag,
)

cleanse_data = BashOperator(
    task_id = "cleanse_data",
    bash_command = 'echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbttest && echo "Current Working Directory: $(pwd)" && dbt run --full-refresh --models dim.* --profiles-dir . ',
    dag=dag,
)
		
generate_fact_tables = BashOperator(
    task_id = "generate_fact_tables",
    bash_command = 'echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbttest && echo "Current Working Directory: $(pwd)" && dbt run --models fct.* --profiles-dir . ',
    dag=dag,
)
		
load_seed = BashOperator(
    task_id = "load_seed",
    bash_command = 'echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbttest && echo "Current Working Directory: $(pwd)" && dbt seed --profiles-dir . ',
    dag=dag,
)
		
mart_tables = BashOperator(
    task_id = "mart_tables",
    bash_command = 'echo "Current Working Directory: $(pwd)" && cd /usr/local/airflow/dags/dbttest && echo "Current Working Directory: $(pwd)" && dbt run --models mart.* --profiles-dir . ',
    dag=dag,
)
		
extract_load >> cleanse_data >> generate_fact_tables >> load_seed >> mart_tables

if __name__ == "__main__":
    dag.cli()