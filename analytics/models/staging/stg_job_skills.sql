with source as (
    select * from {{ source('jobs','dbt_parquet_skills') }}
),
cleaned as (
select
    $1:job_id::string as JOB_ID,
    $1:skill_id::string as SKILL_ID,
    trim($1:skill_keyword::string) as SKILL_KEYWORD
from source
)
select * from cleaned