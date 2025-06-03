select
    mandt,
    operand,
    belzart,
    flag,
    nettobtr_flag,
    ez_abrmenge_flag,
    data_dados
from
    {{ mc_source(var('source_param'),'ZFATT057_OPHIST') }}
