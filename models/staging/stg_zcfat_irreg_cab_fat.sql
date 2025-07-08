select
    mandt,
    ablbelnr,
    anlage,
    adat,
    aplicacao,
    parcelas,
    fat_compl,
    ernam,
    erdat,
    tipo_devol,
    fat_aberta
from
    {{ source('RAW','ZCFAT_IRREG_CAB') }}
