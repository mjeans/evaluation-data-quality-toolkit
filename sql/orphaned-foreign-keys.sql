-- Identify site identifiers that do not resolve to the site dimension.
SELECT
    records.site_id,
    COUNT(*) AS orphaned_rows
FROM analytics.evaluation_records AS records
LEFT JOIN analytics.site_dimension AS sites
    ON records.site_id = sites.site_id
WHERE sites.site_id IS NULL
GROUP BY records.site_id
ORDER BY orphaned_rows DESC;
