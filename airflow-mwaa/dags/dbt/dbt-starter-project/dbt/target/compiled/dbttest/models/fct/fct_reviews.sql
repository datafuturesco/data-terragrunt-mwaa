-- This is a configuration block to create an incremental materialization
-- It appends the data to the reviews fact table when any new reviews come in

-- Then you define your CTE as usual
WITH  __dbt__cte__src_reviews as (
WITH raw_reviews AS(
    SELECT * FROM AIRFLOW.raw.raw_reviews
)
SELECT 
    listing_id,
    date AS review_date,
    reviewer_name,
    comments AS review_text,
    sentiment AS review_sentiment
FROM
    raw_reviews
), src_reviews AS (
    SELECT * FROM __dbt__cte__src_reviews
)
SELECT * FROM src_reviews
WHERE review_text IS NOT NULL
-- how dbt knows a record review is new or not 
-- we need to create a jinja if stmt

  and review_date > (select max(review_date) from AIRFLOW.DEV.fct_reviews)
