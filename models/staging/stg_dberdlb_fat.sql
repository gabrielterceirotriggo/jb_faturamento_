{{
  config(
    snowflake_warehouse = 'WH_QLIK_CG',
    pre_hook = '{{roda_merge("DBERDLB")}}',
    )
}}
select
    mandt,
    printdoc,
    printdocline,
    billdoc,
    billdocline,
    hvorg,
    bukrs,
    xtotal_amnt,
    vertrag,
    abpopbel,
    sparte,
    txjcd,
    mwskz,
    nettobtr,
    sttax,
    ztipo,
    zordem
from
    {{ source('RAW','DBERDLB') }}
