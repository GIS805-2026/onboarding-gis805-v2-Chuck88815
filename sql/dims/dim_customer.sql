CREATE OR REPLACE TABLE dim_customer AS
WITH scd2_events AS (
    SELECT
        customer_id,
        CAST(change_date AS DATE) AS effective_from
    FROM raw_customer_changes
    WHERE field_changed IN ('city', 'province', 'segment')
),
version_dates AS (
    SELECT
        customer_id,
        CAST('1900-01-01' AS DATE) AS effective_from
    FROM raw_dim_customer
    WHERE customer_id IS NOT NULL

    UNION

    SELECT
        customer_id,
        effective_from
    FROM scd2_events
),
versions AS (
    SELECT
        customer_id,
        effective_from,
        COALESCE(
            LEAD(effective_from) OVER (
                PARTITION BY customer_id
                ORDER BY effective_from
            ) - INTERVAL 1 DAY,
            CAST('9999-12-31' AS DATE)
        ) AS effective_to
    FROM version_dates
),
latest_name_correction AS (
    SELECT
        customer_id,
        new_value AS corrected_last_name
    FROM (
        SELECT
            customer_id,
            new_value,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY CAST(change_date AS DATE) DESC
            ) AS rn
        FROM raw_customer_changes
        WHERE change_type = 'name_correction'
    ) t
    WHERE rn = 1
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY v.customer_id, v.effective_from
    ) AS customer_key,
    c.customer_id,
    c.first_name || ' ' || COALESCE(n.corrected_last_name, c.last_name) AS full_name,
    c.email_domain,
    COALESCE((
        SELECT cc.new_value
        FROM raw_customer_changes cc
        WHERE cc.customer_id = v.customer_id
          AND cc.field_changed = 'city'
          AND CAST(cc.change_date AS DATE) <= v.effective_from
        ORDER BY CAST(cc.change_date AS DATE) DESC
        LIMIT 1
    ), c.city) AS city,
    COALESCE((
        SELECT cc.new_value
        FROM raw_customer_changes cc
        WHERE cc.customer_id = v.customer_id
          AND cc.field_changed = 'province'
          AND CAST(cc.change_date AS DATE) <= v.effective_from
        ORDER BY CAST(cc.change_date AS DATE) DESC
        LIMIT 1
    ), c.province) AS province,
    COALESCE((
        SELECT cc.new_value
        FROM raw_customer_changes cc
        WHERE cc.customer_id = v.customer_id
          AND cc.field_changed = 'segment'
          AND CAST(cc.change_date AS DATE) <= v.effective_from
        ORDER BY CAST(cc.change_date AS DATE) DESC
        LIMIT 1
    ), c.loyalty_segment) AS loyalty_segment,
    CAST(c.join_date AS DATE) AS join_date,
    v.effective_from,
    v.effective_to,
    v.effective_to = CAST('9999-12-31' AS DATE) AS is_current,
    CURRENT_DATE AS loaded_at
FROM versions v
JOIN raw_dim_customer c
    ON v.customer_id = c.customer_id
LEFT JOIN latest_name_correction n
    ON c.customer_id = n.customer_id
WHERE c.customer_id IS NOT NULL;
