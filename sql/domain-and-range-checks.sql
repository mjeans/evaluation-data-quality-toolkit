-- Summarize common domain and range failures without exposing row-level data.
SELECT
    SUM(CASE
        WHEN program NOT IN ('comparison', 'intervention')
        THEN 1 ELSE 0
    END) AS invalid_program_rows,
    SUM(CASE
        WHEN baseline_score < 0 OR baseline_score > 100
        THEN 1 ELSE 0
    END) AS invalid_baseline_rows,
    SUM(CASE
        WHEN outcome < 0 OR outcome > 100
        THEN 1 ELSE 0
    END) AS invalid_outcome_rows,
    SUM(CASE
        WHEN followup_date < enrollment_date
        THEN 1 ELSE 0
    END) AS invalid_date_order_rows
FROM analytics.evaluation_records;
