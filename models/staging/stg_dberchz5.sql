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
    n_abrmenge,
    data_dados
from
    {{ source('RAW','DBERCHZ5') }}
