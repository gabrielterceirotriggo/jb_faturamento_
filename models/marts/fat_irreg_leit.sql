select
    zcfat_irreg_cab.mandt as mandante,
    zcfat_irreg_cab.ablbelnr as id_leitura,
    zcfat_irreg_cab.anlage as instalacao,
    zcfat_irreg_cab.aplicacao,
    zcfat_irreg_cab.parcelas,
    zcfat_irreg_cab.fat_compl,
    zcfat_irreg_cab.ernam as criado_por,
    case
        when zcfat_irreg_cab.adat = '00000000' then null
        else TO_DATE(zcfat_irreg_cab.adat, 'YYYYMMDD')
    end as data_leitura,
    case
        when zcfat_irreg_cab.erdat = '00000000' then null
        else TO_DATE(zcfat_irreg_cab.erdat, 'YYYYMMDD')
    end as data_criacao
from
    {{ ref ('stg_zcfat_irreg_cab') }} as zcfat_irreg_cab
where
    zcfat_irreg_cab.mandt = {{ mc_mandante(var('source_param')) }}
