-- Array Intro (All List Functions work with Array)
SELECT [1,2,3];
SELECT ['python', 'sql', 'r'] as skills;

-- Convert to ARRAY
WITH skills AS(
SELECT 'python' AS skill
UNION ALL 
SELECT 'sql'
UNION ALL
SELECT 'r'
), skills_array as (
SELECT ARRAY_AGG(skill ORDER BY skill) as skills
FROM skills
)
SELECT 
    skills[1] AS first_skill,
    skills[2] AS second_skill,
    skills[3] AS third_skill
FROM skills_array
;

-- STRUCT Into 
SELECT{skill: 'python', type: 'programming'} as skill_struct;

-- struct_pack Function
WITH skill_struct AS(
SELECT struct_pack( 
    skill := 'python',
    type := 'programming'
) as a
)
SELECT 
a.skill,
a.type
FROM skill_struct;

WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT
struct_pack(
    skill := skills,
    type := types
)
FROM skill_table;

-- Array of structs
SELECT [
    { skill: 'python', type: 'programming'},
    {skill: 'sql', type: 'query_language'},
    {skill: 'r', type: 'programming'}
] as skills_array_of_structs;

-- 
WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' as types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS (
    SELECT
    ARRAY_AGG(
        STRUCT_PACK(
            skill := skills,
            type := types
        )
    ) array_struct
    FROM skill_table
)
SELECT 
array_struct[1].skill,
array_struct[2].type,
array_struct[3]
FROM skills_array_struct;

-- Map into (not popular)
WITH skill_map AS(
SELECT MAP{'skill': 'python', 'type' : 'programming'} as skill_type
) 
SELECT
    skill_type['skill'],
    skill_type['type']
FROM 
    skill_map
;

-- JSON (Java skript Objeck Notation) text-based serialisation format for nasted data
-- commonly used for ingestion and serving
WITH raw_skill_json AS(
    SELECT
        '{"skill":"python", "type":"programming"}' :: JSON as skill_json
)
SELECT
STRUCT_PACK(
    skill := json_extract_string(skill_json, '$.skill'),
    type := json_extract_string(skill_json, '$.type')
)
FROM raw_skill_json;

-- JSON to ARRAY of Structs
WITH raw_json AS(
    SELECT
    '[
            {"skill":"python", "type":"programming"},
            {"skill":"sql", "type":"query_language"},
            {"skill":"r", "type":"programming"}
    ]' :: JSON as skills_json
)
SELECT 
ARRAY_AGG(
STRUCT_PACK(
    skill := json_extract_string(e.value, '$.skill'),
    type := json_extract_string(e.value, '$.type')
)
ORDER BY json_extract_string(e.value, '$.skill')
) as skills
FROM raw_json, json_each(skills_json) as e;

-- Array final example
-- Build a flat skill table for co-workers to access job titles, salary info, and skills in one table
CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) as skills_array
FROM job_postings_fact as jpf 
LEFT JOIN skills_job_dim as sjd 
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL
;
-- From the prespective of a Data Analyst, analyse the median salary per skill
-- extract every skill and analyze one by one 
WITH flat_skill AS(
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM job_skills_array
)
SELECT 
skill,
MEDIAN(salary_year_avg) as median_salary
FROM flat_skill
GROUP BY skill
ORDER BY median_salary DESC
;

-- ARRAY OF STRUCTs - Final Example
-- Build a flat skill & type table for co_workers to access job_titles, salary info, and type in the one table
CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type := sd.type,
            skill_name := sd.skills
        )
    ) as skill_type
FROM job_postings_fact as jpf 
LEFT JOIN skills_job_dim as sjd 
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd 
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL
;
-- From the prespective of a Data Analyst, analyse the median salary per type of skill
WITH flat_skills AS(
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skill_type).skill_type AS skill_type,
     UNNEST(skill_type).skill_name AS skill_name,
    FROM 
        job_skills_array_struct
)
SELECT 
skill_type,
MEDIAN(salary_year_avg) as median_salary
FROM flat_skills
GROUP BY skill_type
ORDER BY median_salary DESC
;
