select
    mandt,
    logikzw,
    bis,
    zuart,
    logiknr2,
    ab,
    messdrck,
    abrfakt,
    progt,
    attribut,
    erdat,
    ernam,
    aedat,
    aenam
from
    {{ source('RAW','EZUZ') }}
-- WHERE
-- 	ERDAT = '20250214'
