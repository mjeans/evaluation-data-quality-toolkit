-- Return duplicate primary keys from an Athena/Trino-style table.
SELECT
    record_id,
    COUNT(*) AS row_count
FROM analytics.evaluation_records
GROUP BY record_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC, record_id;
