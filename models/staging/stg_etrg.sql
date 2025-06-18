select
    mandt,
    anlage,
    abrdats,
    abrvorg,
    trigstat,
    ableinh,
    erdat,
    ernam
from
    {{ source('RAW','ETRG') }}
