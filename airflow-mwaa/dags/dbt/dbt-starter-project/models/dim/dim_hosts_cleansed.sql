{{
  config(
    materialized = 'view',
    )
}}

WITH src_hosts AS (
    SELECT * FROM {{ref("src_hosts")}}
)
SELECT 
    host_id,
    NVL( host_name, 'Anonymous') AS host_name, -- similar to below
    {# CASE 
        WHEN host_name IS NULL THEN 'Anonymous'
        ELSE host_name
    END AS host_name, #}
    is_superhost,
    created_at,
    updated_at
FROM
    src_hosts