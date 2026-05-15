CREATE OR REPLACE TABLE fact_sales AS
SELECT
    f.order_number,
    f.sale_line_id,

    CAST(f.order_date AS DATE) AS order_date,
    d.date_surrogate_key AS order_date_key,
    c.customer_key,
    p.product_key,
    s.store_key,
    ch.channel_key,

    f.customer_id,
    f.product_id,
    f.store_id,
    f.channel_id,

    CAST(f.quantity AS INTEGER) AS quantity,
    CAST(f.unit_price AS DECIMAL(10, 2)) AS unit_price,
    CAST(f.discount_pct AS DECIMAL(5, 2)) AS discount_pct,
    CAST(f.net_price AS DECIMAL(10, 2)) AS net_price,
    CAST(f.line_total AS DECIMAL(12, 2)) AS line_total,
    CAST(f.quantity * f.unit_price AS DECIMAL(12, 2)) AS gross_amount,
    CURRENT_DATE AS loaded_at
FROM raw_fact_sales f
LEFT JOIN dim_date d
    ON CAST(f.order_date AS DATE) = d.date_key
LEFT JOIN dim_customer c
    ON f.customer_id = c.customer_id
   AND CAST(f.order_date AS DATE) BETWEEN c.effective_from AND c.effective_to
LEFT JOIN dim_product p
    ON f.product_id = p.product_id
LEFT JOIN dim_store s
    ON f.store_id = s.store_id
LEFT JOIN dim_channel ch
    ON f.channel_id = ch.channel_id;
