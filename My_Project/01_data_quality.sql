-- Find dublicate
SELECT
    validation_id,
    COUNT(*) AS record_count
FROM passenger_validations
GROUP BY validation_id
HAVING COUNT(*) > 1;

-- Validations without a matching trip
SELECT
    pv.validation_id,
    pv.trip_id
FROM passenger_validations pv
LEFT JOIN trips t
    ON pv.trip_id = t.trip_id
WHERE t.trip_id IS NULL;