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
    "job_salary",
    "job_posted_at",
        {{ parse_salary('min') }} AS "salary_min",
        {{ parse_salary('max') }} AS "salary_max",
        -- the standard salary measure: midpoint of the parsed range (a single value
        -- is its own range). UNIT-AGNOSTIC on purpose — consumers pair it with
        -- salary_period + salary_currency filters; averaging across units is on them
        ({{ parse_salary('min') }} + {{ parse_salary('max') }}) / 2 AS "salary_avg",
        REGEXP_SUBSTR("job_salary", 'an? (year|hour|month|day|week)$', 1, 1, 'e', 1) AS "salary_period",
        -- leading marker ('PKR', 'CA$', '₱', ...); a salaried row with NO marker is
        -- assumed USD — stamped explicitly so consumers write salary_currency = 'USD'
        -- instead of remembering what a null means. salary-less rows stay null
        CASE
            WHEN "job_salary" IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_SUBSTR("job_salary", '^([^0-9]+)', 1, 1, 'e', 1)), ''), 'USD')
        END AS "salary_currency",
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
