{#- the flagship macro: built at 3.51, installed twice at 3.52 (min, then
    max), extracted once here. expects the raw job_salary column in scope.
    handles: en-dash ranges ('100K–186K a year'), single values (both bounds),
    K/M suffixes, thousands commas + decimals, currency prefixes (ignored here;
    salary_currency owns them). serverless runs ansi mode, so every cast is a
    try_cast: unprofiled shapes degrade to null, never error. -#}
{% macro parse_salary(part) -%}
    {%- if part == 'min' -%}
        {%- set segment = 'SPLIT_PART("job_salary", \'–\', 1)' -%}
    {%- else -%}
        {# for single values SPLIT_PART returns '' on index 2, so fall back to part 1 #}
        {%- set segment = 'NULLIF(SPLIT_PART("job_salary", \'–\', 2), \'\')' -%}
        {%- set segment = 'COALESCE(' ~ segment ~ ', SPLIT_PART("job_salary", \'–\', 1))' -%}
    {%- endif -%}
    TRY_CAST(REPLACE(REGEXP_SUBSTR({{ segment }}, '[0-9][0-9,.]*', 1, 1), ',', '') AS DECIMAL(15, 2))
        * CASE UPPER(REGEXP_SUBSTR({{ segment }}, '[0-9][0-9,.]*([KkMm])', 1, 1, 'e', 1))
            WHEN 'K' THEN 1000
            WHEN 'M' THEN 1000000
            ELSE 1
          END
{%- endmacro %}