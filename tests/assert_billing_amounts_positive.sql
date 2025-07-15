-- Test to ensure billing amounts are positive values
-- This test validates that all financial amounts in the billing table are non-negative

select
    mes_competencia,
    documento_calculo,
    documento_impressao,
    valor_fatura,
    valor_contabil,
    'negative_billing_amount' as test_type
from {{ ref('faturamento') }}
where
    valor_fatura < 0
    or valor_contabil < 0
    or (valor_fatura is not null and valor_fatura < 0)
    or (valor_contabil is not null and valor_contabil < 0) 