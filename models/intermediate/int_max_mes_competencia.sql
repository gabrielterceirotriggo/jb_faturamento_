with itens_faturamento_delta as (
    select
        mes_competencia
    from
        {{ ref('itens_faturamento_delta') }}
),

calculo_mes_maximo as (
    select
        MAX(mes_competencia) as max_mes
    from
        itens_faturamento_delta
),

final as (
    select
        max_mes
    from
        calculo_mes_maximo
)

select * from final
