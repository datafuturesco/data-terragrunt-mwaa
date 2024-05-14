# DDLs
Since DBT does not handle any of the LOAD operations, DDL execution is quite manual. Place all
DDLs within this folder so you can create the appropriate schemas and tables. NOTE, if you have
a model that references a schema that doesn't exist, DBT will auto-create that schema. This 
folder is primarily for creating the database, and any tables that are loaded via external
applications, such as glue.

Be sure to add a grant all to the role you want at the end of each declaration to ensure there
is no a permissions issues. Example:

```SQL
GRANT ALL ON SCHEMA [DATABASE].[SCHEMA] to ROLE YURMAN_DATA_MANAGEMENT;
```