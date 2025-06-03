with base as (
    select
        b.mes_competencia,
        b.mes_referencia,
        b.documento_calculo,
        b.documento_impressao,
        b.tipo_calculo,
        ROW_NUMBER() over (
            partition by b.conta_contrato, b.tipo_calculo, b.mes_referencia
            order by b.data_criacao_impressao asc
        ) as rnk
    from
        (
            select
                a.mes_referencia,
                a.conta_contrato
            from
                {{ ref('faturamento') }} as a
            where
                1 = 1
                and a.cnr is null
                and a.tipo_calculo in ('CP', 'CF', 'CS')
                and a.ordem_faturamento is null
            group by a.mes_referencia, a.conta_contrato
        ) as c
    left join
        {{ ref('faturamento') }} as b
        on
            c.conta_contrato = b.conta_contrato
            and c.mes_referencia = b.mes_referencia
)

select
    mes_competencia,
    mes_referencia,
    documento_calculo,
    documento_impressao,
    tipo_calculo,
    rnk
from
    base
