{{
  config(
    post_hook = [
      "{{ atualiza_ordem() }}",
      "{{ vlr_cont_delta() }}",
      "{{ atualiza_data_carga() }}"
    ],
    )
}}
with ordem_faturamento as (
    select
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        rnk
    from
        {{ ref('int_ordem_faturamento') }}
),

contagem_de_faturamento_duplicado as (
    select
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        rnk,
        COUNT(*) as qtd
    from
        ordem_faturamento
    group by
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        rnk
    having COUNT(*) > 1
),

final as (
    select
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        rnk,
        qtd
    from
        contagem_de_faturamento_duplicado
)

select * from final
