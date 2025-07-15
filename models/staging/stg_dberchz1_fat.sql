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
    ein01
from
    {{ source('RAW','DBERCHZ1') }}
