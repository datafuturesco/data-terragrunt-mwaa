

WITH src_hosts AS (
    SELECT * FROM TEST.DEV.src_hosts
)
SELECT 
    host_id,
    NVL( host_name, 'Anonymous') AS host_name, -- similar to below
    
    is_superhost,
    created_at,
    updated_at
FROM
    src_hosts