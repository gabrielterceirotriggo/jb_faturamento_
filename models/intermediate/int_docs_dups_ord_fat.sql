{# {{
  config(
    post_hook = ["{{atualiza_ordem()}}","{{vlr_cont_delta()}}"],
    )
}} #}
select
    mes_competencia,
    mes_referencia,
    documento_calculo,
    documento_impressao,
    tipo_calculo,
    rnk,
    COUNT(*) as qtd
from {{ ref('int_ordem_faturamento') }}
group by
    mes_competencia,
    mes_referencia,
    documento_calculo,
    documento_impressao,
    tipo_calculo,
    rnk
having COUNT(*) > 1
