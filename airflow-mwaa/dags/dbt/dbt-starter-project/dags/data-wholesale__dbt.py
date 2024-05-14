from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from airflow.models import Variable
import os
import json
import subprocess
from dateutil import parser

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
    'DBT_ENV'
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
dbt_path = f"{HOME}/dags/{project_name}/dbt"
new_dbt_path = f"/tmp/dbt-{project_name}"
dbt_exec = f'/usr/local/airflow/.local/bin/dbt'
manifest_path = f"{dbt_path}/target/manifest.json"  # path to manifest.json

print('dbt_path', dbt_path)
print('new_dbt_path', new_dbt_path)
print('dbt_exec', dbt_exec)
print('manifest_path', manifest_path)
print('env_vars', env_vars)

forced_rebuilt = False
if os.path.isfile(manifest_path):
    result = subprocess.run([
        f"stat --format %y {manifest_path}"
    ], shell=True, capture_output=True, text=True)
    manifest_age = parser.parse(result.stdout)
    print('MANIFEST AGE', manifest_age)

    result = subprocess.run([
        f"stat --format %y $(ls -t $(find {dbt_path} -type f) | head -n 1)"
    ], shell=True, capture_output=True, text=True)
    dbt_age = parser.parse(result.stdout)
    print('DBT AGE', result.stdout)
    if dbt_age > manifest_age:
        forced_rebuilt = True
        print('FORCING A REBUILD!')

if os.path.exists(f'{new_dbt_path}/target'):
    print("Target path exists")
if forced_rebuilt:
    print("Forced_rebuilt is true")
if forced_rebuilt or not os.path.exists(
        f'{new_dbt_path}/target'):
    print("forcing rebuild")
    
# TODO - Also check age of file vs manifest. If file is older force a rebuild?
if forced_rebuilt or not os.path.exists(
        f'{new_dbt_path}/target'):  # If the manifest file doesn't exist, let's generate it!
    print('Deleting old directory')
    result = subprocess.run([
        f"rm -rf {new_dbt_path}"
    ], shell=True, capture_output=True, text=True)
    print(result.stdout)
    print('Building manifest.json file.')
    result = subprocess.run([
        f"cp -rf {dbt_path} {new_dbt_path}"
    ], shell=True, capture_output=True, text=True)
    # print(result.stdout)
    result = subprocess.run([
        f'cd {new_dbt_path} && {dbt_exec} deps'
    ], shell=True, capture_output=True, text=True)
    # print(result.stdout)
    print('Running the actual compile!!!5')
    result = subprocess.run([
        f'cd {new_dbt_path} && {dbt_exec} compile --profiles-dir .'
    ], shell=True, capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr)
    print('what the?!1')
    result = subprocess.run([
        f"ls {dbt_path}"
    ], shell=True, capture_output=True, text=True)
    print(result.stdout)
    print('what the?!2')
    result = subprocess.run([
        f"ls {new_dbt_path}"
    ], shell=True, capture_output=True, text=True)
    print(result.stdout)

if not os.path.isfile(manifest_path):
    raise ValueError('Project file failed to compile.')

with open(manifest_path) as f:  # Open manifest.json
    manifest = json.load(f)  # Load its contents into a Python Dictionary
    nodes = manifest["nodes"]  # Extract just the nodes

print("\n\n\n\nnodes\n\n\n\n")
print(nodes)
print("\n\n\n\n")

with DAG(
        dag_id=DAG_ID,
        schedule_interval=None,
        description="Run the {dir_path} DBT code.",
        start_date=days_ago(1),  # Start date of the DAG
        catchup=False,

) as dag:
    # Create a dict of Operators
    dbt_tasks = dict()

    # dbt_tasks['init'] = BashOperator(
    #     task_id='Init',
    #     env=env_vars,
    #     bash_command=f"cp -rf {dbt_path} /tmp/"  # Copy to the temp dir!
    
    #                  + f' && eval "\$(virtualenv venv )"'  # Load Virtualenv
    #                  + f' && eval "\$(ls venv)"'  # Load Pyenv Virtualenv
    #                  + f" && pyenv activate demo_dbt"  # Activate the dbt virtual environment
    #                  + f' && export DBT_USER="{{ var.value.DBT_USER }}" && export DBT_PASSWORD="{{ var.value.DBT_PASSWORD }}"'
    #                  + f' && cd {new_dbt_path}'
    #                  + f" && {dbt_exec} deps"  # Install the dependencies.
    #                  + f" && {dbt_exec} parse --profiles-dir ."  # Parse the dbt manifest.
    #     # run the setup!
    # )

    for node_id, node_info in nodes.items():
        print("node_id: ",node_id)
        if node_info["resource_type"] == 'test':
            # Skip test files!
            continue
        dbt_tasks[node_id] = BashOperator(
            task_id=".".join(
                [
                    node_info["resource_type"],
                    node_info["package_name"],
                    node_info["name"],
                ]
            ),
            env=env_vars,
            bash_command=f'cd {new_dbt_path}'
                         # + f' && export DBT_USER="{DBT_USER}" && export DBT_PASSWORD="{DBT_PASSWORD}"'
                         # + f' && export DBT_USER="{{ var.value.DBT_USER }}" && export DBT_PASSWORD="{{ var.value.DBT_PASSWORD }}"'
                         + f" && {dbt_exec} run --models {node_info['name']} --profiles-dir ."
            # run the model!
        )
        # Define relationships between Operators
    for node_id, node_info in nodes.items():
        if node_info["resource_type"] == 'test':
            # Skip test files!
            continue
        if node_info["package_name"] == 'src':
            continue
        print("\n\n\n\n node info: ",node_info)
        upstream_nodes = node_info["depends_on"]["nodes"]
        if upstream_nodes:
            print("upstream nodes are present\n\n\n\n")
            print("upstream_nodes: ", upstream_nodes)
            for upstream_node in upstream_nodes:
                print("\n\n\n upstream_node name: ",upstream_node)
                dbt_tasks[upstream_node] >> dbt_tasks[node_id]
        # else:
            # dbt_tasks['init'] >> dbt_tasks[node_id]

if __name__ == "__main__":
    dag.cli()
