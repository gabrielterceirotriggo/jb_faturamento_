with zcfat_irreg_cab as (

    select
        mandt,
        ablbelnr,
        anlage,
        aplicacao,
        parcelas,
        fat_compl,
        ernam,
        adat,
        erdat
    from
        {{ ref('stg_zcfat_irreg_cab_fat') }}

),

tratamento_cabecalho as (

    select
        mandt as mandante,
        ablbelnr as id_leitura,
        anlage as instalacao,
        aplicacao,
        parcelas,
        fat_compl,
        ernam as criado_por,
        try_to_date(adat, 'YYYYMMDD') as data_leitura,
        try_to_date(erdat, 'YYYYMMDD') as data_criacao
    from
        zcfat_irreg_cab
    where
        mandt = {{ mc_mandante() }}

),

final as (

    select
        mandante,
        id_leitura,
        instalacao,
        aplicacao,
        parcelas,
        fat_compl,
        criado_por,
        data_leitura,
        data_criacao
    from
        tratamento_cabecalho

)

select * from final
