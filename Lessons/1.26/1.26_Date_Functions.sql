SELECT 
    job_posted_date
FROM job_postings_fact
LIMIT 10;


SELECT 
    job_posted_date,
    job_posted_date ::DATE AS date,
    job_posted_date ::TIME AS time,
    job_posted_date ::TIMESTAMP AS timestamp,
    job_posted_date :: TIMESTAMPTZ AS timestamptz
FROM job_postings_fact
LIMIT 10;

SELECT 
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year,
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY 
EXTRACT(YEAR FROM job_posted_date),
EXTRACT(MONTH FROM job_posted_date)
ORDER BY 
job_posted_year,
job_posted_month
;

SELECT 
    job_posted_date,
    DATE_TRUNC('month', job_posted_date)::DATE AS job_posted_month
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;

SELECT 
    job_posted_date,
    DATE_TRUNC('year', job_posted_date) AS job_posted_year,
    DATE_TRUNC('quarter', job_posted_date) AS job_posted_quarter,
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    DATE_TRUNC('week', job_posted_date) AS job_posted_week,
    DATE_TRUNC('day', job_posted_date) AS job_posted_day,
    DATE_TRUNC('hour', job_posted_date) AS job_posted_hour
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;


SELECT
DATE_TRUNC('month', job_posted_date)::DATE AS job_posted_month,
COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer' AND 
    DATE_TRUNC('year', job_posted_date) = '2024-01-01'::DATE
--EXTRACT (YEAR FROM job_posted_date) = 2024
GROUP BY 
DATE_TRUNC('month', job_posted_date)
ORDER BY 
job_posted_month
;

SELECT 
'2026-01-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'EST';

SELECT
    job_title_short,
    job_location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS job_posted_date_est
FROM job_postings_fact
WHERE job_location = 'New York, NY';


SELECT
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour_est,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_location = 'New York, NY'
GROUP BY
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
ORDER BY
    job_posted_hour_est 
;


