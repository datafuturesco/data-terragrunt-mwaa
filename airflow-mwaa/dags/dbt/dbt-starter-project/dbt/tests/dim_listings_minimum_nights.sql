SELECT * FROM 
    {{ref("dim_listings_cleansed")}}
WHERE 
    minimum_nights < 1
LIMIT 10


{# {{ test_positive_value( ref("dim_listings_cleansed"), 'minimum_nights')}} #}