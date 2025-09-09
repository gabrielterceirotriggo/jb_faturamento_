{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("DBERDL")}}',
    )
}}
select
    mandt,
    printdoc,
    printdocline,
    belzart,
    ktosl,
    xtotal_amnt,
    nettobtr,
    sbasw,
    txjcd,
    hvorg,
    tvorg,
    sktpz,
    linesort,
    ab,
    bis,
    stprz
from
    {{ source('RAW','DBERDL') }}
