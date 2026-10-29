-- .read /Users/irinaredler/SQL_Data_Engineer_Projects/Lessons/1.21/1.21_DDL_DML_Pt1.sql
USE data_jobs; 
DROP DATABASE IF EXISTS job_mart;

CREATE DATABASE IF NOT EXISTS job_mart;

SHOW DATABASES;

-- DROP DATABASE IN EXISTS job_mart;

SELECT *
FROM information_schema.schemata;

USE job_mart; -- First step to evoide a repetition in CREATE funktion (only for Motherduck)

CREATE SCHEMA IF NOT EXISTS staging; -- Second step create a new schema_name for job_mart

-- DROP SCHEMA IF EXISTS staging;

CREATE TABLE IF NOT EXISTS staging.preferred_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR
);

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'job_mart';

INSERT INTO staging.preferred_roles (role_id,role_name)
VALUES 
(1, 'Data Engineer'),
(2, 'Senior Data Engineer'),
(3, 'Software Engineer');

SELECT *
FROM staging.preferred_roles;

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE role_id = 1 OR role_id = 2;

UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id = 3;

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

SELECT *
FROM staging.priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role to priority_lvl;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER; 

UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

SELECT *
FROM staging.priority_roles;