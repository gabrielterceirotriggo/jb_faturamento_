{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("DBERCHZ5")}}',
    )
}}
select
    mandt,
    belnr,
    belzeile,
    belzart,
    branche,
    tvorg,
    linesort,
    ab,
    bis,
    tariftyp,
    temp_area,
    v_abrmenge,
    n_abrmenge
from
    {{ source('RAW','DBERCHZ5') }}
