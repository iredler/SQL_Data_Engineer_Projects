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