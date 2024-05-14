{%- macro incremental_filter(column_str=none, lookback_int=none) -%}

    {%- if is_incremental() -%}

        {%- if column_str is none -%}
            {{ exceptions.raise_compiler_error("Invalid must provide a `column_str` value.") }}
        {%- endif -%}

        {%- if var('backfill_start_date', default=false) -%}
            and {{ column_str }} >= '{{ var("backfill_start_date") }}'
            {%- if var('backfill_end_date', default=false) -%}
                and {{ column_str }} <= '{{ var("backfill_end_date") }}'
            {%- endif -%}

        {%- elif var('backfill_start_int', default=false) and var('backfill_end_int', default=false) -%}
            and {{ column_str }} >= current_date() + {{ var('backfill_start_int') }}
            and {{ column_str }} <= current_date() + {{ var('backfill_end_int') }}
        {%- else -%}

            {%- if lookback_int is not none -%}
                and {{ column_str }} >= current_date() + {{ lookback_int }}
            {%- else -%}
                {%- set sql -%}select max({{ column_str }}) from {{ this }}{%- endset -%}
                {%- if execute -%}
                    and {{ column_str }} > '{{ run_query(sql).columns[0].values()[0] }}'
                {%- endif -%}
            {%- endif -%}

        {%- endif -%}

    {%- endif -%}

{%- endmacro -%}