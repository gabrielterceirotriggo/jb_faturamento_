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
    ein01,
    data_dados
--constraint dberchz1_dberchz1_1729607942903359_pk primary key (mandt, belnr, belzeile)
from
    {{ mc_source(var('source_param'),'DBERCHZ1') }}
