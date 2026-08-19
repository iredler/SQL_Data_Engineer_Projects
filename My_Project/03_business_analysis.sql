-- Business Question 1
-- Which stops have the highest number of passenger validations?
SELECT
pv.sales_channel,
SUM(revenue_euro) as total_revenue,
COUNT(ticket_type) as total_tickets_sold
FROM 
passenger_validations as pv
WHERE 
ticket_type NOT LIKE '%Deutschlandticket%'
AND revenue_euro IS NOT NULL
GROUP BY pv.sales_channel 
ORDER BY total_revenue DESC;
/*
┌────────────────┬───────────────┬────────────────────┐
│ sales_channel  │ total_revenue │ total_tickets_sold │
│    varchar     │ decimal(38,2) │       int64        │
├────────────────┼───────────────┼────────────────────┤
│ DB Navigator   │      80308.80 │              13384 │
│ Ticket Machine │      80020.80 │              13292 │
│ HVV Switch App │      79209.60 │              13244 │
└────────────────┴───────────────┴────────────────────┘
*/

-- Business Question 2
-- Which ticket types generate the most revenue?
SELECT
r.route_short_name,
r.agency_id,
COUNT(pv.validation_id) as total_passengers,
SUM(pv.revenue_euro) as total_revenue
FROM routes as r
INNER JOIN trips as t
ON r.route_id = t.route_id
INNER JOIN agency as a
ON r.agency_id = a.agency_id
INNER JOIN passenger_validations as pv
ON pv.trip_id = t.trip_id
GROUP BY r.route_short_name, r.agency_id
ORDER BY total_revenue DESC
LIMIT 5;
/*
┌──────────────────┬───────────┬──────────────────┬───────────────┐
│ route_short_name │ agency_id │ total_passengers │ total_revenue │
│     varchar      │   int64   │      int64       │ decimal(38,2) │
├──────────────────┼───────────┼──────────────────┼───────────────┤
│ AST              │        20 │              268 │        667.20 │
│ 1                │       344 │              252 │        543.60 │
│ 302              │       309 │              189 │        450.00 │
│ U5               │        72 │              187 │        436.80 │
│ 11               │        24 │              158 │        434.40 │
└──────────────────┴───────────┴──────────────────┴───────────────┘
*/

-- Business Question 3
-- Which routes have the highest passenger activity?
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
/*
┌──────────────────┬───────────────┬───────────────────────┐
│ transaction_date │ daily_revenue │ running_total_revenue │
│       date       │ decimal(38,2) │     decimal(38,2)     │
├──────────────────┼───────────────┼───────────────────────┤
│ 2026-07-18       │       7795.20 │               7795.20 │
│ 2026-07-19       │       8128.80 │              15924.00 │
│ 2026-07-20       │       8041.20 │              23965.20 │
│ 2026-07-21       │       7845.60 │              31810.80 │
│ 2026-07-22       │       7915.20 │              39726.00 │
│ 2026-07-23       │       7912.80 │              47638.80 │
│ 2026-07-24       │       7789.20 │              55428.00 │
│ 2026-07-25       │       8362.80 │              63790.80 │
│ 2026-07-26       │       7912.80 │              71703.60 │
│ 2026-07-27       │       7981.20 │              79684.80 │
│ 2026-07-28       │       8076.00 │              87760.80 │
│ 2026-07-29       │       7725.60 │              95486.40 │
│ 2026-07-30       │       8110.80 │             103597.20 │
│ 2026-07-31       │       8504.40 │             112101.60 │
│ 2026-08-01       │       7886.40 │             119988.00 │
│ 2026-08-02       │       8058.00 │             128046.00 │
│ 2026-08-03       │       7875.60 │             135921.60 │
│ 2026-08-04       │       8448.00 │             144369.60 │
│ 2026-08-05       │       7736.40 │             152106.00 │
│ 2026-08-06       │       7861.20 │             159967.20 │
│ 2026-08-07       │       7869.60 │             167836.80 │
│ 2026-08-08       │       7848.00 │             175684.80 │
│ 2026-08-09       │       8307.60 │             183992.40 │
│ 2026-08-10       │       7719.60 │             191712.00 │
│ 2026-08-11       │       8222.40 │             199934.40 │
│ 2026-08-12       │       7920.00 │             207854.40 │
│ 2026-08-13       │       8070.00 │             215924.40 │
│ 2026-08-14       │       8077.20 │             224001.60 │
│ 2026-08-15       │       7652.40 │             231654.00 │
│ 2026-08-16       │       7885.20 │             239539.20 │
└──────────────────┴───────────────┴───────────────────────┘
  30 rows                                        3 columns
*/