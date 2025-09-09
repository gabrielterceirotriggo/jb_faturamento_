{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("ERCHC")}}',
    )
}}
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
    --erchc_erchc_pk
from
    {{ source('RAW', 'ERCHC') }}
