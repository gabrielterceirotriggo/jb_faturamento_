select
    mandt,
    operand,
    belzart,
    flag,
    nettobtr_flag,
    ez_abrmenge_flag
from
    {{ source('RAW','ZFATT057_OPHIST') }}
