
  create or replace   view TEST.DEV.src_hosts
  
   as (
    WITH raw_hosts AS (
    SELECT * FROM TEST.RAW.raw_hosts
)
SELECT 
    id AS host_id,
    name AS host_name,
    is_superhost,
    created_at,
    updated_at
FROM 
    raw_hosts
  );

