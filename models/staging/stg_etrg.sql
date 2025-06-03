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
    {{ mc_source(var('source_param'),'ETRG') }}
