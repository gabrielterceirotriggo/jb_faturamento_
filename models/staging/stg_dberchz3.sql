select
    mandt,
    belnr,
    belzeile,
    zonennr,
    preisbtr,
    n_nettobtr_l,
    nettobtr,
    data_dados
--constraint dberchz3_dberchz3_1729607952512699_pk primary key (mandt, belnr, belzeile)
from
    {{ source('RAW','DBERCHZ3') }}
