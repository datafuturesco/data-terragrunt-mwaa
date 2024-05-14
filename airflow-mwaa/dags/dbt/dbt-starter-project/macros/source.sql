{% macro source(source_name, table_name, include_database = False) %}

    {% do return(builtins.source(source_name, table_name).include(database = include_database)) %}

{% endmacro %}