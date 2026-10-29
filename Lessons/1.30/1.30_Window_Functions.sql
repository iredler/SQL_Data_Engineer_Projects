-- Count rows -- Aggregation only
SELECT COUNT(*)
FROM job_postings_fact;

-- Count rows -- Window function
SELECT job_id,
COUNT(*) OVER ()
FROM job_postings_fact;

-- PARTITION BY 
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (PARTITION BY job_title_short) AS avg_salary_hour
    FROM job_postings_fact
    ORDER BY 
    RANDOM()
    LIMIT 10;

-- PARTITION BY 
SELECT
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (PARTITION BY job_title_short, company_id) AS avg_salary_hour
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    ORDER BY 
    RANDOM()
    LIMIT 10;

--  ORDER BY + RANK
SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER ( ORDER BY salary_hour_avg DESC) AS rankj_hourly_salary
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    ORDER BY 
    salary_hour_avg DESC
    LIMIT 10;

  -- PARTITION BY + ORDER BY 

SELECT
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date) AS running_avg_hourly_by_title
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL AND job_title_short = 'Data Engineer'
    ORDER BY 
   job_title_short, job_posted_date
    LIMIT 10;

-- PARTITION BY + ORDER BY + Rank
SELECT
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL 
    ORDER BY 
salary_hour_avg DESC,
job_title_short
    LIMIT 10;

-- Ranking Fuunctions RANK() vs DENSE_RANK

SELECT
    job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK() OVER ( ORDER BY salary_hour_avg DESC) AS dense_rank_hourly_salary
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL
    ORDER BY 
    salary_hour_avg DESC
    LIMIT 140;

-- Row Number Function
SELECT *,
ROW_NUMBER() OVER (ORDER BY job_posted_date) AS row_num
FROM job_postings_fact
ORDER BY 
job_posted_date 
LIMIT 10;

-- Navigation Functions LEAD() and LAG()
-- LAG 
SELECT
job_id,
company_id,
job_title,
job_title_short,
job_posted_date,
salary_year_avg, 
LAG(salary_year_avg) OVER (
    PARTITION BY company_id
    ORDER BY job_posted_date
) AS prev_posted_date,
salary_year_avg - LAG(salary_year_avg) OVER (
    PARTITION BY company_id
    ORDER BY job_posted_date
) AS salary_change
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;


-- Avg salary by job_title_short
SELECT
job_title,
job_title_short,
salary_year_avg,
AVG(salary_year_avg) OVER 
    (PARTITION BY job_title_short) AS avg_salary_by_cat
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY job_title_short, salary_year_avg ASC
LIMIT 20;

-- Task 2
WITH jobs AS(
SELECT
job_id,
job_title_short,
salary_year_avg,
AVG(salary_year_avg) OVER 
    (PARTITION BY job_title_short) AS avg_salary_by_cat,
salary_year_avg - avg_salary_by_cat AS salary_diffrence
FROM job_postings_fact)
SELECT *
FROM jobs
WHERE salary_diffrence > 0
ORDER BY salary_diffrence  DESC
LIMIT 20;

-- Task 3
WITH job_postings AS (
SELECT
job_posted_date :: DATE AS posted_date,
job_title_short,
COUNT(*) as total_count,
SUM(salary_year_avg) total_salaries
FROM job_postings_fact
GROUP BY job_title_short, posted_date
ORDER BY posted_date ASC
)
SELECT
posted_date,
job_title_short,
SUM(total_count) OVER (PARTITION BY job_title_short ORDER BY posted_date ASC) as jobs_count, 
SUM(total_salaries) OVER (PARTITION BY job_title_short ORDER BY posted_date ASC)
FROM job_postings;

-- RANK, ROW_NUMBER Task 1
SELECT 
job_id,
job_title_short,
salary_year_avg,
ROW_NUMBER() OVER (PARTITION BY job_title_short ORDER BY salary_year_avg DESC, job_id ASC)
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;

-- Task 2 Top 3 Salaries 
WITH rank_salaries AS (
SELECT
job_id,
job_title_short,
salary_year_avg,
RANK() OVER (PARTITION BY job_title_short ORDER BY salary_year_avg DESC, job_id) 
as row_numb
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
)
SELECT
*
FROM rank_salaries
WHERE row_numb <=3
;

-- Task 3 Companies ranking
WITH top_companies AS (
    SELECT company_id,
        job_title_short, 
        AVG(salary_year_avg) as avg_salary,
        DENSE_RANK() OVER (PARTITION BY job_title_short ORDER BY avg_salary DESC) as company_rank
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY company_id, job_title_short
HAVING COUNT(company_id) >= 5
)
SELECT
tp.company_id,
tp.job_title_short,
cd.name,
avg_salary,
company_rank
FROM top_companies as tp
INNER JOIN company_dim as cd
    ON tp.company_id = cd.company_id
WHERE company_rank <=3
ORDER BY tp.company_id
;

-- Task 1 Navigation Funktions 

SELECT 
            job_id AS current_job_id,
            job_title_short,
            job_posted_date :: DATE as current_job_posted_date,
            LAG(job_id) OVER
                 (PARTITION BY job_title_short ORDER BY job_posted_date :: DATE ASC) AS previous_job_id,
            LAG(job_posted_date :: DATE) OVER
                 (PARTITION BY job_title_short ORDER BY job_posted_date ASC) AS previous_job_posted_date
            FROM
            job_postings_fact;


-- Task 2
WITH job_salaries_change AS (
    SELECT 
    job_id,
    job_title_short,
    job_posted_date,
    salary_year_avg as current_salary,
    LAG(salary_year_avg) OVER (PARTITION BY job_title_short ORDER BY job_posted_date ASC) as previous_salary,
    current_salary - previous_salary as salary_change,
    CAST(
    CASE 
    WHEN salary_change IS NULL THEN NULL
    ELSE 
    (current_salary - previous_salary) * 100 / previous_salary 
    END AS INTEGER) as change_percent
    FROM job_postings_fact
) 
SELECT
*
FROM job_salaries_change
WHERE current_salary IS NOT NULL AND previous_salary IS NOT NULL;

-- Task 3 LAST_VALUE, FIRST_VALUE
WITH job_posted_salary AS(
SELECT 
job_id,
job_title_short,
job_posted_date,
salary_year_avg
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
),
salary_window AS(
SELECT
*,
FIRST_VALUE(salary_year_avg) OVER (PARTITION BY job_title_short 
    ORDER BY job_posted_date ASC) as first_job_salary,
LAST_VALUE(salary_year_avg) OVER (PARTITION BY job_title_short 
    ORDER BY job_posted_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) 
    as last_job_salary
FROM job_posted_salary)
SELECT *,
last_job_salary - first_job_salary as salary_change
FROM salary_window
ORDER BY job_posted_date ASC
;
