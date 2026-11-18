with job_postings as(
select * from {{ ref('stg_job_postings') }}
),
deduped as (
    select *,
        row_number() over (partition by job_id order by search_date desc, searched_at desc) as rn
    from job_postings
)
select
    JOB_ID,
     JOB_TITLE,
      COMPANY_NAME, 
      JOB_LOCATION, 
      SOURCE_PLATFORM, 
      JOB_SALARY, 
      JOB_POSTED_AT, 
      SALARY_MIN, SALARY_MAX, 
      SALARY_AVG, 
      SALARY_PERIOD, 
      SALARY_CURRENCY,
       JOB_SCHEDULE_TYPE,
        JOB_WORK_FROM_HOME, 
        SEARCHED_AT, 
        SEARCH_DATE,
         SEARCH_TERM,
          SEARCH_LOCATION,
           HAS_NO_DEGREE_MENTIONED, 
           HAS_HEALTH_INSURANCE,
            HAS_DENTAL_INSURANCE, 
            HAS_PAID_TIME_OFF
from deduped
where rn = 1