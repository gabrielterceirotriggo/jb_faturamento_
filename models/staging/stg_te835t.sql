select
    mandt,
    spras,
    belzart,
    text30,
    data_dados
from
    {{ mc_source(var('source_param'),'TE835T') }}
