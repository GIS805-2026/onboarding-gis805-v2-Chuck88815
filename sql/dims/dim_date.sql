CREATE OR REPLACE TABLE dim_date AS
SELECT
    ROW_NUMBER() OVER (ORDER BY date_key) AS date_surrogate_key,
    CAST(date_key AS DATE) AS date_key,
    CAST(year AS INTEGER) AS year,
    CAST(quarter AS INTEGER) AS quarter,
    CAST(month AS INTEGER) AS month,
    month_name,
    CAST(week_iso AS INTEGER) AS week_iso,
    CAST(day_of_week AS INTEGER) AS day_of_week,
    day_name,
    CAST(is_weekend AS INTEGER) AS is_weekend,
    CURRENT_DATE AS loaded_at
FROM raw_dim_date
WHERE date_key IS NOT NULL;

