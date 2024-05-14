# from airflow import DAG
# from airflow.operators.bash_operator import BashOperator
# from airflow.utils.dates import days_ago
# from airflow.models import Variable
# import os
# import json
# import subprocess
# from dateutil import parser

# DAG_ID = os.path.basename(__file__).replace(".py", "")

# # Set all the variables!
# env_vars = {}
# for item in [

# ]:
#     try:
#         test = Variable.get(item)
#         if test:
#             os.environ[item] = test
#             env_vars[item] = '{{ var.value.' + item + ' }}'
#     except Exception as e:
#         pass

# HOME = os.environ["HOME"]  # retrieve the location of your home folder
# project_name = DAG_ID.split('__')[0]
# glue_path = f"{HOME}/glue/{project_name}"

# print('glue_path', glue_path)

# # TODO - Glob path at glue_path and get filenames, convert to tasks.

# with DAG(
#         dag_id=DAG_ID,
#         schedule_interval=None,
#         description="Run the {dir_path} DBT code.",
#         start_date=days_ago(1),  # Start date of the DAG
#         catchup=False,

# ) as dag:
#     # Create a dict of Operators
#     dbt_tasks = dict()

#     for node_id, node_info in nodes.items():
#         if node_info["resource_type"] == 'test':
#             # Skip test files!
#             continue
#         dbt_tasks[node_id] = BashOperator(
#             task_id=".".join(
#                 [
#                     node_info["resource_type"],
#                     node_info["package_name"],
#                     node_info["name"],
#                 ]
#             ),
#             env=env_vars,
#             bash_command=f'cd {new_dbt_path}'
#                          # + f' && export DBT_USER="{DBT_USER}" && export DBT_PASSWORD="{DBT_PASSWORD}"'
#                          # + f' && export DBT_USER="{{ var.value.DBT_USER }}" && export DBT_PASSWORD="{{ var.value.DBT_PASSWORD }}"'
#                          + f" && {dbt_exec} run --models {node_info['name']} --profiles-dir ."
#             # run the model!
#         )

# if __name__ == "__main__":
#     dag.cli()
