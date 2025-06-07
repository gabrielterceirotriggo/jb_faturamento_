select
    mandt,
    spras,
    belzart,
    text30,
    data_dados
from
    {{ source('RAW','TE835T') }}
