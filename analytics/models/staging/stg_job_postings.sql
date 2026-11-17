{% set extensions_keywords = ["no degree mentioned",
                              "Health insurance", 
                              "Dental insurance", 
                              "Paid time off"] 
%}
with source as (
select * from {{ source('jobs','dbt_parquet_data')}}
WHERE "error" IS NULL AND "error_message" IS NULL AND "job_title" IS NOT NULL
),
parsed AS (
    SELECT
        *,
        TRY_PARSE_JSON("job_extensions_raw")::array AS job_extensions
    FROM source
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
    "search_time" as "searched_at",
    "search_date",
    "search_term",
    "search_location",
    {% for keyword in extensions_keywords -%}
    ARRAY_CONTAINS(
        '{{ keyword }}'::VARIANT,
        job_extensions
    ) AS "has_{{ slugify(keyword) }}"
    {{- "," if not loop.last }}
    {% endfor %}
FROM parsed
)
select * from cleaned
