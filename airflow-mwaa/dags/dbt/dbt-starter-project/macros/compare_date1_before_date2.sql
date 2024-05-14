{%- macro clean_date(dt) -%}

    {% if dt | length > 10 %}
        left({{ dt }}, 10)
    {% else %}
        {{ dt }}
    {% endif %}

{%- endmacro -%}

{%- macro compare_date1_before_date2_conditional(date1_raw, date2_raw, expr) -%}

    {% set date1 = clean_date(date1_raw) %}
    {% set date2 = clean_date(date2_raw) %}

        CASE
            WHEN ({{ date1 }} IS NULL) or ({{ date2 }} IS NULL)
                THEN TRUE
            WHEN least(length({{ date1 }}), length({{ date2 }})) = 7 -- check year month
                THEN substr({{ date1 }}, 1, 7) < substr({{ date2 }}, 1, 7)
            WHEN least(length({{ date1 }}), length({{ date2 }})) = 4 -- check year
                THEN substr({{ date1 }}, 1, 4) < substr({{ date2 }}, 1, 4)
            WHEN least(length({{ date1 }}), length({{ date2 }})) = 10 -- check year-month-day
                THEN {{ date1 }} < {{ date2 }}
            ELSE FALSE
     END

{%- endmacro -%}