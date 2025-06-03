select
    zcfat_irreg_inf.belnr as documento_calculo,
    zcfat_irreg_inf.belzart as item_documento,
    zcfat_irreg_inf.vertrag as contrato,
    zcfat_irreg_inf.anlage as instalacao,
    zcfat_irreg_inf."status",
    zcfat_irreg_inf.qtde_dias as total_dias_periodo,
    zcfat_irreg_inf.qtde_dias_fat as total_dias_faturado,
    zcfat_irreg_inf.qtde_dias_nfat as total_dias_nao_faturado,
    zcfat_irreg_inf.qtde_faturas as total_faturas,
    zcfat_irreg_inf.cons_total as consumo_total,
    zcfat_irreg_inf.cons_diario as consumo_diario,
    zcfat_irreg_inf.cons_faturado as consumo_faturado,
    zcfat_irreg_inf.cons_atual as consumo_atual,
    zcfat_irreg_inf.cons_ajuste as consumo_ajuste,
    zcfat_irreg_inf.cons_media as consumo_media,
    zcfat_irreg_inf.cons_diferenca as consumo_diferenca,
    zcfat_irreg_inf.cons_dia_complemento as consumo_dia_complemento,
    zcfat_irreg_inf.cons_fat_complemento as consumo_fat_complemento,
    zcfat_irreg_inf.cons_nao_faturado as consumo_nao_faturado,
    zcfat_irreg_inf.leit_anterior as leitura_anterior,
    zcfat_irreg_inf.parcelas,
    zcfat_irreg_inf.ajus_user as operando,
    case
        when zcfat_irreg_inf.adat = '00000000' then null
        else TO_DATE(zcfat_irreg_inf.adat, 'YYYYMMDD')
    end as data_leitura,
    case
        when zcfat_irreg_inf.invoiced = ' ' then null
        else zcfat_irreg_inf.invoiced
    end as flag,
    case
        when zcfat_irreg_inf.grupo_estim = ' ' then null
        else zcfat_irreg_inf.grupo_estim
    end as tipo_estimativa,
    case
        when zcfat_irreg_inf.data_lei_anterior = '00000000' then null
        else TO_DATE(zcfat_irreg_inf.data_lei_anterior, 'YYYYMMDD')
    end as data_leitura_anterior,
    case
        when zcfat_irreg_inf.rpnum = ' ' then null
        else zcfat_irreg_inf.rpnum
    end as numero_documento
from
    {{ ref ('stg_zcfat_irreg_inf') }} as zcfat_irreg_inf
where
    zcfat_irreg_inf.mandt in (401, 402, 403, 404)
