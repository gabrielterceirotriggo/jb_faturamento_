SELECT
    mandt,
    anlage,
    abrdats,
    abrvorg,
    trigstat,
    ableinh,
    erdat,
    ernam,
    data_dados
FROM
    {{ mc_source(var('source_param'),'ETRG')}}

    