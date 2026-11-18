-- skill demand across the whole star (fct ⋈ bridge ⋈ dim_skill).
-- a QUESTION, not a model — it lives in analyses/ (3.08.2). all roles by default;
-- pick yours with:
--   dbt compile --select in_demand_skills --vars 'job_title: Data Analyst'
-- then read target/compiled/analytics/analyses/in_demand_skills.sql (compile writes the file, it prints nothing)

WITH job_postings AS (

    SELECT "job_id" AS job_id
    FROM {{ ref('fct_job_postings') }}
    {% if var('job_title', none) %}
    WHERE "search_term" = '{{ var("job_title") }}'
    {% endif %}

),

bridge AS (
    SELECT * FROM {{ ref('bridge_job_skills') }}
),

skills AS (
    SELECT * FROM {{ ref('dim_skill') }}
)

SELECT
    skills.display_name,
    skills.category,
    COUNT(DISTINCT bridge.job_id) AS demand_count,
    ROUND(COUNT(DISTINCT bridge.job_id) / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100, 1) AS demand_pct
FROM bridge
INNER JOIN skills ON skills.skill_id = bridge.skill_id
INNER JOIN job_postings ON job_postings.job_id = bridge.job_id
GROUP BY skills.skill_id, skills.display_name, skills.category
ORDER BY demand_count DESC