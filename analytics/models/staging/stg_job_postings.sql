
with source as (
select * from {{ source('jobs','dbt_parquet_data')}}
WHERE "error" IS NULL AND "error_message" IS NULL AND "job_title" IS NOT NULL
),
cleaned as(
select
    "job_id",
    "job_title",
    trim("company_name") as "company_name",
    "job_location",
    regexp_replace("job_via",'^via','') as "job_via",
    "job_posted_at",
    "job_salary",
    "job_schedule_type",
    "job_work_from_home",
    "job_extensions_raw",
    "search_time" as "searched_at",
    "search_date",
    "search_term",
    "search_location"
from source
)
select * from cleaned
