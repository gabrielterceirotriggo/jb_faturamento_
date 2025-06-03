SELECT
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
FROM 
    {{ mc_source(var('source_param'),'DBERCHZ5')}}
    