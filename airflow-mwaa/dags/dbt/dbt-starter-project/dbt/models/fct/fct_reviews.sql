-- This is a configuration block to create an incremental materialization
-- It appends the data to the reviews fact table when any new reviews come in
{{
  config(
    materialized = 'incremental',
    on_schema_change = 'fail' 
    )
}}
-- Then you define your CTE as usual
WITH src_reviews AS (
    SELECT * FROM {{ ref("src_reviews")}}
)
SELECT * FROM src_reviews
WHERE review_text IS NOT NULL
-- how dbt knows a record review is new or not 
-- we need to create a jinja if stmt
{%  if is_incremental() %}
  and review_date > (select max(review_date) from {{ this }})
{% endif %}