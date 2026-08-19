WITH daily_validations AS (
    SELECT
        transaction_date,
        COUNT(*) AS validation_count,
        SUM(revenue_euro) AS revenue
    FROM passenger_validations
    GROUP BY transaction_date
)

SELECT *
FROM daily_validations
ORDER BY transaction_date;