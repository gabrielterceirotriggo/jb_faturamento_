with faturamento as (
    select
        mes_referencia,
        conta_contrato,
        cnr,
        tipo_calculo,
        ordem_faturamento,
        mes_competencia,
        documento_calculo,
        documento_impressao,
        data_criacao_impressao
    from
        {{ ref('faturamento') }}
),

contratos_para_ranquear as (
    select
        mes_referencia,
        conta_contrato
    from
        faturamento
    where
        cnr is null
        and tipo_calculo in ('CP', 'CF', 'CS')
        and ordem_faturamento is null
    group by
        mes_referencia,
        conta_contrato
),

faturamento_enriquecido as (
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
        contratos_para_ranquear as c
    left join
        faturamento as b
        on c.conta_contrato = b.conta_contrato
        and c.mes_referencia = b.mes_referencia
),

final as (
    select
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        rnk
    from
        faturamento_enriquecido
)

select * from final
