select
    mandt,
    spras,
    belzart,
    text30
from
    {{ source('RAW','TE835T') }}
