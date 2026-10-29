SELECT LENGTH('SQL');
SELECT LOWER('SQL');
SELECT UPPER('sql');
SELECT LEFT('SQL', 2);
SELECT RIGHT('SQL', 2);
SELECT SUBSTRING('SQL', 2, 2);
SELECT CONCAT('SQL', ' is fun!');
SELECT 'SQL' || ' is fun!';
SELECT TRIM('   SQL   ');
SELECT REPLACE('SQL is fun!', 'fun', 'awesome');
SELECT REGEXP_REPLACE('SQL is fun!', 'fun', 'awesome');
SELECT REGEXP_REPLACE('irinaredler26@gmail.com', '.*(@)', '\1');

--Final Example - Cleanup this using Text Functions
--CTE lower
WITH title_lower AS(
    SELECT job_title,
    LOWER(TRIM(job_title)) AS job_title_lower
    FROM job_postings_fact
)

SELECT
job_title,
CASE
    WHEN job_title_lower LIKE '%data%' AND job_title_lower LIKE '%analyst%' 
        THEN 'Data Analyst'
    WHEN job_title_lower LIKE '%data%' AND job_title_lower LIKE '%engineer%' 
        THEN 'Data Engineer'
    WHEN job_title_lower LIKE '%data%' AND job_title_lower LIKE '%scientist%' 
        THEN 'Data Scientist'
    ELSE 'Other'
END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;

-- Null Functions
SELECT 
MEDIAN(NULLIF(salary_hour_avg, 0)) AS salary_hour_avg,
MEDIAN(NULLIF(salary_year_avg, 0)) AS salary_year_avg
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
OR salary_year_avg IS NOT NULL
ORDER BY salary_year_avg 
LIMIT 10;

SELECT COALESCE(NULL,1,2);

SELECT
salary_hour_avg,
salary_year_avg,
COALESCE(salary_hour_avg * 2080, salary_year_avg, NULL)
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

-- Final Example 
WITH salaries AS (
    SELECT
    job_title_short,
    salary_hour_avg,
    salary_year_avg
    CASE 
    WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
    WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    END AS standardized_salary
FROM job_postings_fact
)
SELECT 
job_title_short,
salary_year_avg,
salary_hour_avg,
standardized_salary,
CASE
WHEN standardized_salary IS NULL THEN 'Missing'
WHEN standardized_salary < 75_000 THEN 'Low'
WHEN standardized_salary < 150_000 THEN 'Mid'
ELSE 'High'
END AS salary_bucket
FROM salaries
ORDER BY standardized_salary DESC

-- Simplify with Coalesce
SELECT
job_title_short,
salary_year_avg,
salary_hour_avg,
COALESCE(salary_year_avg, salary_hour_avg * 2080) AS standardized_salary,
    CASE
    WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) IS NULL THEN 'Missing'
    WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 75_000 THEN 'Low'
COALESCE(salary_year_avg, salary_hour_avg * 2080) < 150_000 THEN 'Mid'
    ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC;
