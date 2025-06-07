select
    mandt,
    anlage,
    abrdats,
    abrvorg,
    trigstat,
    ableinh,
    erdat,
    ernam,
    data_dados
from
    {{ source('RAW','ETRG') }}
