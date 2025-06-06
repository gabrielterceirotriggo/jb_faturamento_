with ranked_data as (
    select
        data_criacao_calculo,
        CAST(documento_calculo as VARCHAR(12)) as documento_calculo,
        CAST(usuario_criacao_calculo as VARCHAR(12)) as usuario_criacao_calculo,
        CAST(motivo_estorno_ajuste as VARCHAR(2)) as motivo_estorno_calculo,
        CAST(documento_estorno_ajuste as VARCHAR(12))
            as documento_estorno_ajuste,
        CAST(valor_fatura as DECIMAL(13, 2)) as valor_fatura,
    from
        {{ ref('int_calculo_delta') }}
    where
        estorno_ajuste = 'X'
)

select
    documento_calculo,
    data_criacao_calculo,
    usuario_criacao_calculo,
    motivo_estorno_calculo,
    documento_estorno_ajuste,
    valor_fatura
from
    ranked_data
qualify ROW_NUMBER() over (
    partition by
        documento_estorno_ajuste
    order by
        documento_estorno_ajuste desc,
        data_criacao_calculo desc
) = 1
