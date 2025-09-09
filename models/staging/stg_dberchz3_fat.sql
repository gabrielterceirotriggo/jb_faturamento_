{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("DBERCHZ3")}}',
    )
}}
select
    mandt,
    belnr,
    belzeile,
    zonennr,
    preisbtr,
    n_nettobtr_l,
    nettobtr
from
    {{ source('RAW','DBERCHZ3') }}
