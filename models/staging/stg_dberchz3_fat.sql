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
