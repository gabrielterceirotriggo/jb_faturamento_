{% if var('source_param') == 'EQTL_MA' %}
{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("ERCHC")}}',
    )
}}
{% endif %}
select
    mandt,
    belnr,
    lfdnr,
    opbel,
    cpudt,
    budat,
    intopbel,
    intcpudt,
    intbudat,
    tobreleasd,
    simulated,
    invoiced,
    spcanc,
    statupd,
    statupd_canc
from
    {{ source('RAW', 'ERCHC') }}
