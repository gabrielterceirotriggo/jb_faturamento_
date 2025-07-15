-- Test to ensure consumption data consistency
-- This test validates that billed consumption and measured consumption are consistent
-- within reasonable tolerance levels

select
    mes_competencia,
    documento_calculo,
    documento_impressao,
    consumo_faturado,
    consumo_medido,
    abs(consumo_faturado - consumo_medido) as consumption_difference,
    'consumption_inconsistency' as test_type
from {{ ref('faturamento') }}
where
    consumo_faturado is not null
    and consumo_medido is not null
    and abs(consumo_faturado - consumo_medido) > 1000  -- Tolerance threshold
    and estornado is null  -- Exclude reversed documents 