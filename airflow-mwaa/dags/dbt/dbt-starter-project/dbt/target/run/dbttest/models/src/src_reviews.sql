
  create or replace   view AIRFLOW.DEV.src_reviews
  
   as (
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
  );

