| What I Built | How I Implemented | Where to Look |
|---|---|---|
| Star schema | Fact + dimensions + bridge on a declared grain | `analytics/models/marts/` |
| SCD2 snapshots | A year of salary history, backfilled | `analytics/snapshots/` + `scripts/` |
| Incremental fact | Merge on `job_id`; only new days load | `fct_job_postings.sql` |
| Macros | A custom parser + an overridden built-in | `analytics/macros/` |
| Tests | Generic, singular, and custom generic | `analytics/tests/` + the properties YAML files |
| Environments | Dev/prod as catalogs: dev from the laptop, prod only from the job | Snowflake: `dev` + `prod` |
| Orchestration | Scheduled Snowflake Job, zero secrets | Snowflake → Tasks & Pipelines |
| Analyses | Questions kept next to the models that answer them | `analytics/analyses/` |
