## Configure DBT

You can place any DBT files in here. You will need to alter a few files to ensure the default values match your needs.

### dbt_project.yml 

##### `name` argument
You will need to alter the `[PROJECT]` value with your project name. Please note, `-`'s and `spaces` will not work. Please use underscores.

##### `models` argument
This will also have to be modified under the `models:` argument as the first referenced point is the profile name.

##### `+database` argument
Lastly, you will want to change the `+database:` key to match your project.

### profiles.yml

This file defines the defaults for all variables. The only real key that needs modifying is the `database` key.

> Please note the `database` key is  referenced a few times. Be sure to update all references!