with erdk as (
    select
        mandt,
        opbel,
        intopbel,
        ergrd,
        invoiced,
        budat,
        erdat
    from
        {{ ref('stg_erdk_fat') }}
),

erchc as (
    select
        mandt,
        opbel,
        belnr
    from
        {{ ref('stg_erchc_fat') }}
),

erch as (
    select
        mandt,
        belnr,
        belegart,
        zzorigdoc
    from
        {{ ref('stg_erch_fat') }}
),

ultima_execucao as (
    select ultima_execucao
    from
        {{ ref('stg_int_ultima_exec_fat') }}
),

calculos as (
    select
        a.mandt,
        b.belnr as doc_calculo,
        a.opbel as doc_impressao,
        c.belegart as tipo_calculo,
        case
            when COALESCE(c.zzorigdoc, ' ') <> ' ' then c.zzorigdoc
        end as tipo_documento,
        case
            when a.ergrd = '04' then 'X'
        end as estorno,
        case
            when COALESCE(a.budat, '00000000') <> '00000000' then SUBSTR(a.budat, 1, 6)
        end as mes_competencia
    from
        erdk as a
    inner join
        erchc as b
        on a.mandt = b.mandt and a.opbel = b.opbel
    inner join
        erch as c
        on b.mandt = c.mandt and b.belnr = c.belnr
    where
        a.mandt = {{ mc_mandante() }}
        and a.invoiced = 'X'
        and COALESCE(a.ergrd, ' ') <> '04'
        and a.erdat >= (select ultima_execucao from ultima_execucao)
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
),

estornos_plenos as (
    select
        a.mandt,
        b.belnr as doc_calculo,
        a.opbel as doc_impressao,
        c.belegart as tipo_calculo,
        case
            when COALESCE(c.zzorigdoc, ' ') <> ' ' then c.zzorigdoc
        end as tipo_documento,
        case
            when a.ergrd = '04' then 'X'
        end as estorno,
        case
            when COALESCE(a.budat, '00000000') <> '00000000' then SUBSTR(a.budat, 1, 6)
        end as mes_competencia
    from
        erdk as a
    inner join
        erchc as b
        on a.mandt = b.mandt and a.intopbel = b.opbel
    inner join
        erch as c
        on b.mandt = c.mandt and b.belnr = c.belnr
    where
        a.mandt = {{ mc_mandante() }}
        and a.invoiced = 'X'
        and a.ergrd = '04'
        and a.erdat >= (select ultima_execucao from ultima_execucao)
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
),

documentos_unificados as (
    select
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        estorno,
        mes_competencia
    from
        calculos
    union all
    select
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        estorno,
        mes_competencia
    from
        estornos_plenos
),

final as (
    select
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        estorno,
        mes_competencia
    from
        documentos_unificados
)

select * from final
