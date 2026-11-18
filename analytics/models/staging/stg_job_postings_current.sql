{{ 
  config(
    materialized = 'ephemeral',
    )
}}

select *
from {{ref('stg_job_postings')}}
where SEARCH_DATE <= CAST('{{ var('as_of',run_started_at) }}' AS DATE)
qualify row_number() over(
  partition by JOB_ID
  ORDER BY SEARCHED_AT DESC
)=1

