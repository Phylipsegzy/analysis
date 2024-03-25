CREATE TABLE job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(55)
);


INSERT INTO job_applied 
            (job_id,
            application_sent_date,
            custom_resume,
            resume_file_name,
            cover_letter_sent,
            cover_letter_file_name,
            status)
VALUES      
        (
        1,
        '2024-02-01',
        true,
        'resume_01.pdf',
        true,
        'cover_letter_01.pdf',
        'submitted'
        ),
        (
        2,
        '2024-02-02',
        true,
        'resume_02.pdf',
        true,
        'cover_letter_02.pdf',
        'interview scheduled'
        ),
        (
        3,
        '2024-02-03',
        true,
        'resume_03.pdf',
        true,
        'cover_letter_03.pdf',
        'submitted'
        ),
        (
        4,
        '2024-02-04',
        true,
        'resume_04.pdf',
        true,
        'cover_letter_04.pdf',
        'submitted'
        );

SELECT * FROM job_postings_fact
ORDER BY job_id ASC
LIMIT 100

UPDATE job_applied
SET contact = '0817848755'

ALTER TABLE job_applied
ALTER COLUMN contact_name TYPE TEXT;

SELECT '2023-02-19'::DATE,
        'true'::BOOLEAN

SELECT job_title_short AS title,
        job_location AS location,
        job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'WAT' AS date_time_zone,
        EXTRACT(MONTH FROM job_posted_date) AS date_month,
        EXTRACT(YEAR FROM job_posted_date) AS date_month
FROM    job_postings_fact
LIMIT 10

SELECT 
        COUNT(job_id) AS job_posted_count,
        job_title_short AS job_posted,
        EXTRACT(MONTH FROM job_posted_date) AS date_month
       -- EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM    
        job_postings_fact
WHERE   
        job_title_short = 'Data Analyst'
GROUP BY 
        date_month, job_posted
ORDER BY
        date_month DESC

-- January
CREATE TABLE january_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT *
FROM
    march_jobs

SELECT
        COUNT(job_id) AS number_of_jobs,
     
        CASE
                WHEN job_location = 'Anywhere' THEN 'Remote'
                WHEN job_location = 'New York, NY' THEN 'Local'
                ELSE 'Onsite'
        END AS location_category
FROM
        job_postings_fact
WHERE
        job_title_short = 'Data Analyst'
GROUP BY
        location_category;

SELECT *
FROM 
        job_postings_fact
ORDER BY job_id DESC
LIMIT 1000

SELECT
        company_id,
        name as company_name
FROM    company_dim
WHERE company_id IN(
        SELECT
                company_id
        FROM
                job_postings_fact
        WHERE   job_no_degree_mention = true
        ORDER BY
                company_id
)


WiTH company_job_count AS (
        SELECT 
                company_id,
                COUNT(*) AS total_jobs
        FROM
                job_postings_fact
        GROUP BY
                company_id
)
SELECT
        company_dim.name AS company_name,
        company_job_count.total_jobs
FROM
        company_dim
LEFT JOIN 
        company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
        total_jobs DESC

WiTH highest_skill_count AS (
        SELECT 
                skill_id,
                COUNT(*) AS total_skills
        FROM
                skills_job_dim
        GROUP BY
                skill_id
)
SELECT
        skills_dim.skills AS skill_name,
        highest_skill_count.total_skills
FROM
        skills_dim
LEFT JOIN 
        highest_skill_count ON highest_skill_count.skill_id = skills_dim.skill_id
ORDER BY
        total_skills ASC

select * from skills_dim


WITH company_job_count AS (
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT
    company_dim.name AS company_name,
    company_job_count.total_jobs,
    CASE
        WHEN company_job_count.total_jobs < 10 THEN 'Small'
        WHEN company_job_count.total_jobs >= 10 AND company_job_count.total_jobs < 50 THEN 'Medium'
        WHEN company_job_count.total_jobs >= 50 THEN 'Large'
    END AS Company_size
FROM
    company_dim
LEFT JOIN 
    company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    company_job_count.total_jobs DESC;


WITH remote_job_skills AS(
SELECT
        skill_id,
        
        count(*) AS skill_count
FROM    
        skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact ON skills_to_job.job_id = job_postings_fact.job_id
WHERE 
        job_postings_fact.job_work_from_home = true AND
        job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
        skill_id
)
SELECT * 
FROM remote_job_skills
INNER JOIN skills_dim as skill ON skill.skill_id = remote_job_skills.skill_id
ORDER BY
        skill_count DESC
LIMIT
        5

SELECT 
        job_title_short,
        company_id,
        job_location
FROM
    january_jobs

UNION ALL

SELECT 
        job_title_short,
        company_id,
        job_location
FROM
    february_jobs

UNION ALL

SELECT 
        job_title_short,
        company_id,
        job_location
FROM
    march_jobs



SELECT
        job_title_short,
        company_id,
        job_location,
        salary_year_avg
FROM    (
        SELECT 
                *
        FROM
        january_jobs
        UNION ALL
        SELECT 
                *
        FROM
        february_jobs
        UNION ALL
        SELECT 
                *
        FROM
        march_jobs
)
WHERE
        salary_year_avg > 70000 AND
        job_title_short = 'Data Analyst'
ORDER BY
        salary_year_avg DESC
