with calculos as (
    select
        a.mandt,
        b.belnr as doc_calculo,
        a.opbel as doc_impressao,
        c.belegart as tipo_calculo,
        case
            when c.zzorigdoc <> ' ' then c.zzorigdoc
        end as tipo_documento,
        case
            when a.ergrd = '04' then 'X'
        end as estorno,
        case
            when a.budat <> '00000000' then SUBSTR(a.budat, 0, 6)
        end as mes_competencia
    from
        {{ ref('stg_erdk') }} as a
    inner join
        {{ ref('stg_erchc') }} as b
        on (a.mandt = b.mandt) and (a.opbel = b.opbel)
    inner join
        {{ ref('stg_erch') }} as c
        on (b.mandt = c.mandt) and (b.belnr = c.belnr)
    where
        a.mandt = {{ mc_mandante(var('source_param')) }} 
        and a.invoiced = 'X'
        and a.ergrd <> '04'
        and a.erdat
        >= (select ultima_execucao from {{ ref('stg_int_ultima_exec') }})
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
),

estornos_plenos as (
    select
        a.mandt,
        b.belnr as doc_calculo,
        a.opbel as doc_impressao,
        c.belegart as tipo_calculo,
        case
            when c.zzorigdoc <> ' ' then c.zzorigdoc
        end as tipo_documento,
        case
            when a.ergrd = '04' then 'X'
        end as estorno,
        case
            when a.budat <> '00000000' then SUBSTR(a.budat, 0, 6)
        end as mes_competencia
    from
        {{ ref ('stg_erdk') }} as a
    inner join {{ ref ('stg_erchc') }} as b
        on
            (a.mandt = b.mandt)
            and (a.intopbel = b.opbel)
    inner join {{ ref ('stg_erch') }} as c
        on
            (b.mandt = c.mandt)
            and b.belnr = c.belnr
    where
        a.mandt = {{ mc_mandante(var('source_param')) }}
        and a.invoiced = 'X'
        and a.ergrd = '04'
        and a.erdat
        >= (select ultima_execucao from {{ ref('stg_int_ultima_exec') }})
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
),

uniao as (
    select
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        TO_VARCHAR(estorno) as estorno,
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
        TO_VARCHAR(estorno) as estorno,
        mes_competencia
    from
        estornos_plenos
)

select
    mandt,
    doc_calculo,
    doc_impressao,
    tipo_calculo,
    tipo_documento,
    estorno,
    mes_competencia
from
    uniao
