-- S03 proof query
-- Shows customer SCD2 history and compares sales before and after a change.

WITH changed_customer AS (
    SELECT customer_id
    FROM dim_customer
    GROUP BY customer_id
    HAVING COUNT(*) > 1
    ORDER BY customer_id
    LIMIT 1
),
history AS (
    SELECT
        c.customer_id,
        c.customer_key,
        c.city,
        c.province,
        c.loyalty_segment,
        c.effective_from,
        c.effective_to,
        c.is_current
    FROM dim_customer c
    JOIN changed_customer x
        ON c.customer_id = x.customer_id
),
sales_by_version AS (
    SELECT
        h.customer_id,
        h.customer_key,
        h.city,
        h.province,
        h.loyalty_segment,
        h.effective_from,
        h.effective_to,
        h.is_current,
        COUNT(f.sale_line_id) AS sales_lines,
        COALESCE(SUM(f.line_total), 0) AS total_revenue
    FROM history h
    LEFT JOIN fact_sales f
        ON h.customer_key = f.customer_key
    GROUP BY
        h.customer_id,
        h.customer_key,
        h.city,
        h.province,
        h.loyalty_segment,
        h.effective_from,
        h.effective_to,
        h.is_current
)
SELECT *
FROM sales_by_version
ORDER BY effective_from;
