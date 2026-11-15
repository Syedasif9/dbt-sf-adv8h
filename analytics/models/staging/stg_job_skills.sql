with source as (
    select * from {{ source('jobs','dbt_parquet_skills') }}
),
cleaned as (
select
    $1:job_id::string as job_id,
    $1:skill_id::string as skill_id,
    trim($1:skill_keyword::string) as skill_keyword
from source
)
select * from cleaned