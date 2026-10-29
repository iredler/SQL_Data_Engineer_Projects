 SELECT 
 COUNT(*)
 FROM
 job_postings_fact;

SELECT 
jpf.job_id,
jpf.job_title_short,
cd.company_id,
cd.name AS company_name,
jpf.job_location
FROM 
job_postings_fact as jpf
LEFT JOIN company_dim as cd
ON jpf.company_id = cd.company_id
;

SELECT 
jpf.job_id,
jpf.job_title_short,
cd.company_id,
cd.name AS company_name,
jpf.job_location
FROM 
job_postings_fact as jpf
FULL OUTER JOIN company_dim as cd
ON jpf.company_id = cd.company_id
;

SELECTEXPLAIN ANALYZE
*
FROM 
skills_dim
LIMIT 10 ;

SELECT
jpf.job_id,
jpf.job_title_short,
sd.skill_id,
--sd.skills
FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sd
ON jpf.job_id = sd.job_id
LIMIT 10;

SELECT
jpf.job_id,
jpf.job_title_short,
sjd.skill_id,
sd.skills
FROM job_postings_fact as jpf
FULL JOIN skills_job_dim as sjd
ON jpf.job_id = sjd.job_id
FULL JOIN skills_dim as sd
ON sjd.skill_id = sd.skill_id
;

--  -- when its take a lot of time, that will make your query more efficient.
EXPLAIN ANALYZE
SELECT
cd.name as company_name, 
COUNT(jpf.job_id) as posting_count
FROM job_postings_fact as jpf
LEFT JOIN company_dim as cd
ON cd.company_id = jpf.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name
HAVING COUNT(jpf.job_id) > 3000
ORDER BY posting_count DESC
LIMIT 10;

