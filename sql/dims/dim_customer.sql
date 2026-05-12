CREATE OR REPLACE TABLE dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    first_name || ' ' || last_name AS full_name,
    email_domain,
    city,
    province,
    loyalty_segment,
    CAST(join_date AS DATE) AS join_date,
    TRUE AS is_current,
    CURRENT_DATE AS loaded_at
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;

