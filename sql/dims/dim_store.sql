CREATE OR REPLACE TABLE dim_store AS
SELECT
    ROW_NUMBER() OVER (ORDER BY store_id) AS store_key,
    store_id,
    store_name,
    city,
    region,
    province,
    store_type,
    CURRENT_DATE AS loaded_at
FROM raw_dim_store
WHERE store_id IS NOT NULL;

