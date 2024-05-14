{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {#-- dbt defaults to concatenating the custom schema to the target schema --#}
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}