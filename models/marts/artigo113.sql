{{
  config(
    materialized = 'incremental',
    incrementa_strategy= 'insert_overwrite',
    )
}}
with zcfat_irreg_inf as (

    select
        mandt,
        belnr,
        belzart,
        vertrag,
        anlage,
        status,
        qtde_dias,
        qtde_dias_fat,
        qtde_dias_nfat,
        qtde_faturas,
        cons_total,
        cons_diario,
        cons_faturado,
        cons_atual,
        cons_ajuste,
        cons_media,
        cons_diferenca,
        cons_dia_complemento,
        cons_fat_complemento,
        cons_nao_faturado,
        leit_anterior,
        parcelas,
        ajus_user,
        adat,
        invoiced,
        grupo_estim,
        data_lei_anterior,
        rpnum
    from
        {{ ref('stg_zcfat_irreg_inf') }}

),

tratamento_dados as (

    select
        belnr as documento_calculo,
        belzart as item_documento,
        vertrag as contrato,
        anlage as instalacao,
        status,
        qtde_dias as total_dias_periodo,
        qtde_dias_fat as total_dias_faturado,
        qtde_dias_nfat as total_dias_nao_faturado,
        qtde_faturas as total_faturas,
        cons_total as consumo_total,
        cons_diario as consumo_diario,
        cons_faturado as consumo_faturado,
        cons_atual as consumo_atual,
        cons_ajuste as consumo_ajuste,
        cons_media as consumo_media,
        cons_diferenca as consumo_diferenca,
        cons_dia_complemento as consumo_dia_complemento,
        cons_fat_complemento as consumo_fat_complemento,
        cons_nao_faturado as consumo_nao_faturado,
        leit_anterior as leitura_anterior,
        parcelas,
        ajus_user as operando,
        case
            when adat = '00000000' then null
            else to_date(adat, 'YYYYMMDD')
        end as data_leitura,
        case
            when invoiced = ' ' then null
            else invoiced
        end as flag,
        case
            when grupo_estim = ' ' then null
            else grupo_estim
        end as tipo_estimativa,
        case
            when data_lei_anterior = '00000000' then null
            else to_date(data_lei_anterior, 'YYYYMMDD')
        end as data_leitura_anterior,
        case
            when rpnum = ' ' then null
            else rpnum
        end as numero_documento
    from
        zcfat_irreg_inf
    where
        mandt = {{ mc_mandante(var('source_param')) }}

),

final as (

    select
        documento_calculo,
        item_documento,
        contrato,
        instalacao,
        status,
        total_dias_periodo,
        total_dias_faturado,
        total_dias_nao_faturado,
        total_faturas,
        consumo_total,
        consumo_diario,
        consumo_faturado,
        consumo_atual,
        consumo_ajuste,
        consumo_media,
        consumo_diferenca,
        consumo_dia_complemento,
        consumo_fat_complemento,
        consumo_nao_faturado,
        leitura_anterior,
        parcelas,
        operando,
        data_leitura,
        flag,
        tipo_estimativa,
        data_leitura_anterior,
        numero_documento
    from
        tratamento_dados
)

select * from final
