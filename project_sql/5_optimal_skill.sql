
WITH high_skill_demand AS (
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS number_of_skills
FROM
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg is NOT NULL AND
    job_work_from_home = True
GROUP BY skills_dim.skill_id
), high_salary_demand AS(
SELECT 
    skills_dim.skill_id,
    ROUND(AVG(salary_year_avg), 0) AS salary_avg
FROM
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg is NOT NULL AND
    job_work_from_home = True
GROUP BY skills_dim.skill_id

)

SELECT
    high_skill_demand.skill_id,
    high_skill_demand.skills,
    number_of_skills,
    salary_avg
FROM
    high_skill_demand
INNER JOIN
    high_salary_demand ON high_skill_demand.skill_id = high_salary_demand.skill_id
ORDER BY
    number_of_skills DESC,
    salary_avg DESC
    
--LIMIT 25