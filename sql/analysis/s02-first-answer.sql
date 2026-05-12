-- S02 proof query
-- CEO question: which product categories sell in which regions by quarter?

SELECT
    p.category,
    s.region,
    d.year,
    d.quarter,
    SUM(f.line_total) AS total_revenue,
    SUM(f.quantity) AS total_units,
    COUNT(*) AS sales_lines
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
JOIN dim_store s
    ON f.store_key = s.store_key
JOIN dim_date d
    ON f.order_date_key = d.date_surrogate_key
GROUP BY
    p.category,
    s.region,
    d.year,
    d.quarter
ORDER BY total_revenue DESC
LIMIT 10;
