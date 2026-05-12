CREATE OR REPLACE TABLE dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    CAST(unit_cost AS DECIMAL(10, 2)) AS unit_cost,
    CAST(unit_price AS DECIMAL(10, 2)) AS unit_price,
    CURRENT_DATE AS loaded_at
FROM raw_dim_product
WHERE product_id IS NOT NULL;

