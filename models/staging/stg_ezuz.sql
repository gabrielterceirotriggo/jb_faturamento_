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
    {{ mc_source(var('source_param'),'EZUZ') }}
-- WHERE
-- 	ERDAT = '20250214'
