SELECT * FROM
    {{ref('dim_listings_cleansed')}} AS listings
JOIN {{ ref('fct_reviews')}} AS fct
ON listings.listing_id = fct.listing_id
WHERE listings.created_at >= fct.review_date