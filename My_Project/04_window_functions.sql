WITH daily_validations AS (
    SELECT
        transaction_date,
        COUNT(*) AS validation_count
    FROM passenger_validations
    GROUP BY transaction_date
)
SELECT
    transaction_date,
    validation_count,
    SUM(validation_count) OVER (
        ORDER BY transaction_date
    ) AS cumulative_validations
FROM daily_validations
ORDER BY transaction_date;

