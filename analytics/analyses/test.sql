select 
    company_name,
    count(distinct job_id)as jobs_changed
from
    dbtfc.snapshots.job_postings_snapshot
where DBT_VALID_TO is not null
group by company_name
order by jobs_changed desc