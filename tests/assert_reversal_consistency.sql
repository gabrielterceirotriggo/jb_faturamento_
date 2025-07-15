-- Test to ensure reversal document consistency
-- This test validates that reversal documents have proper business logic applied
-- and that reversal indicators are consistent

select
    mes_competencia,
    documento_calculo,
    documento_impressao,
    estornado,
    estorno_pleno,
    estorno_ajuste,
    reversao,
    'reversal_inconsistency' as test_type
from {{ ref('faturamento') }}
where
    -- Check for inconsistent reversal indicators
    (estornado = 'X' and estorno_pleno is null and estorno_ajuste is null)
    or (estorno_pleno = 'X' and estornado is null)
    or (estorno_ajuste = 'X' and estornado is null)
    or (reversao = 'X' and estornado is null)
    or (estorno_pleno = 'X' and estorno_ajuste = 'X')  -- Cannot be both full and adjustment reversal 