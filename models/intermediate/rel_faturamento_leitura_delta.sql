with faturamento_delta as (

    select documento_calculo
    from
        {{ ref('faturamento_delta') }}

),

dberchz2 as (

    select
        mandt,
        belnr,
        ablbelnr
    from
        {{ ref('stg_dberchz2') }}

),

documentos_com_leitura as (

    select
        faturamento_delta.documento_calculo,
        dberchz2.ablbelnr as id_leitura
    from
        faturamento_delta
    left outer join
        dberchz2
        on
            faturamento_delta.documento_calculo = dberchz2.belnr
            and dberchz2.mandt = {{ mc_mandante(var('source_param')) }}
    where
        dberchz2.mandt = {{ mc_mandante(var('source_param')) }}

),

leituras_validas as (

    select distinct
        documento_calculo,
        id_leitura
    from
        documentos_com_leitura
    where
        COALESCE(id_leitura, ' ') <> ' '

),

final as (

    select
        documento_calculo,
        id_leitura
    from
        leituras_validas

)

select * from final
