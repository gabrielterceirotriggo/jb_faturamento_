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
    zordem,
    data_dados
    --constraint dberdlb_dberdlb_pk primary key (mandt, printdoc, printdocline)
from
    {{ source('RAW','DBERDLB') }}
