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
        {{ ref('stg_zcfat_irreg_cab') }}

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
        case
            when adat = '00000000' then null
            else to_date(adat, 'YYYYMMDD')
        end as data_leitura,
        case
            when erdat = '00000000' then null
            else to_date(erdat, 'YYYYMMDD')
        end as data_criacao
    from
        zcfat_irreg_cab
    where
        mandt = {{ mc_mandante(var('source_param')) }}

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
