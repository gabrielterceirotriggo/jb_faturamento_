select
    documento_impressao,
    tipo_impressao,
    data_criacao_impressao,
    usuario_criacao,
    data_modificacao_impressao,
    usuario_modificacao,
    data_competencia,
    data_vencimento_original,
    data_apresentacao,
    chave_reconciliacao,
    motivo_estorno_impressao,
    contrapartida,
    valor_total,
    estorno_pleno,
    fatura_virtual,
    TO_VARCHAR(data_competencia, 'YYYYMM') as mes_competencia
from
    {{ ref ('int_impressao_delta') }}
where
    estorno_pleno = 'X'
