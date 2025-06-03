SELECT
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
FROM 
    {{ mc_source(var('source_param'),'DBERDLB') }}
