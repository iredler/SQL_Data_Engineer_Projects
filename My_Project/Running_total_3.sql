
WITH DailyRevenue AS( 
SELECT 
transaction_date,
SUM(revenue_euro) as daily_revenue
FROM passenger_validations
WHERE ticket_type NOT LIKE '%Deutschlandticket%'
GROUP BY transaction_date
)
SELECT 
transaction_date,
daily_revenue,
SUM(daily_revenue) OVER (ORDER BY transaction_date) as running_total_revenue
FROM DailyRevenue 
ORDER BY transaction_date;
