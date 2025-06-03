WITH ranked_data AS (
    SELECT
        CAST(documento_calculo AS VARCHAR(12)) AS documento_calculo,
        data_criacao_calculo, 
        CAST(usuario_criacao_calculo AS VARCHAR(12)) AS usuario_criacao_calculo,
        CAST(motivo_estorno_ajuste AS VARCHAR(2)) AS motivo_estorno_calculo,
        CAST(documento_estorno_ajuste AS VARCHAR(12)) AS documento_estorno_ajuste,
        CAST(valor_fatura AS DECIMAL(13, 2)) AS valor_fatura,
        ROW_NUMBER() OVER (PARTITION BY documento_estorno_ajuste ORDER BY data_criacao_calculo DESC) AS row_num
    FROM
        {{ ref('int_calculo_delta') }}
    WHERE
        estorno_ajuste = 'X'
)

SELECT
    documento_calculo,
    data_criacao_calculo,
    usuario_criacao_calculo,
    motivo_estorno_calculo,
    documento_estorno_ajuste,
    valor_fatura
FROM
    ranked_data
WHERE
    row_num = 1
ORDER BY
    documento_estorno_ajuste DESC, data_criacao_calculo DESC
