CREATE OR REPLACE TABLE dim_channel AS
SELECT
    ROW_NUMBER() OVER (ORDER BY channel_id) AS channel_key,
    channel_id,
    channel_name,
    channel_type,
    CURRENT_DATE AS loaded_at
FROM raw_dim_channel
WHERE channel_id IS NOT NULL;

