{{
  config(
    materialized = 'incremental',
    incremental_strategy= 'custom_insert_overwrite',
    )
}}
with etrg as (
    select
        anlage,
        abrvorg,
        ableinh,
        ernam,
        abrdats,
        trigstat,
        erdat,
        mandt
    from
        {{ ref('stg_etrg_fat') }}
),

calculo_previsto as (
    select
        anlage as instalacao,
        abrvorg as tipo_calculo,
        ableinh as ul,
        ernam as criado_por,
        try_to_date(abrdats, 'YYYYMMDD') as data_calc_previsto,
        case
            when trigstat = '1' then 'NAO_CALCULAVEL'
            when trigstat = '2' then 'CALCULAVEL'
        end as status,
        try_to_date(erdat, 'YYYYMMDD') as data_criacao
    from
        etrg
    where
        mandt = {{ mc_mandante() }}
),

final as (
    select
        instalacao,
        tipo_calculo,
        ul,
        criado_por,
        data_calc_previsto,
        status,
        data_criacao
    from
        calculo_previsto
)

select * from final
