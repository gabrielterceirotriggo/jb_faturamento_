{% macro vlr_cont_delta() %}

    {% set update_query %}
        UPDATE
            {{ this }} AS a
        SET
            VALOR_CONTABIL = x.VALOR_AJUSTADO
        FROM (
            SELECT *
            FROM (
                SELECT DISTINCT 
                    X.DOCUMENTO_CALCULO, 
                    X.DOCUMENTO_IMPRESSAO,
                    RANK() OVER (
                        PARTITION BY X.CONTA_CONTRATO, X.DOCUMENTO_CALCULO, X.DOCUMENTO_IMPRESSAO, X.ESTORNO_PLENO 
                        ORDER BY Y.DATA_CRIACAO_IMPRESSAO DESC
                    ) AS ORDEM,
                    X.VALOR_FATURA, 
                    X.VALOR_CONTABIL, 
                    Y.VALOR_FATURA AS VALOR_ORIGINAL,
                    (
                        (CASE WHEN Y.ESTORNO_PLENO IS NOT NULL THEN X.VALOR_FATURA * -1 ELSE X.VALOR_FATURA END)
                    - (CASE WHEN X.ESTORNO_PLENO IS NOT NULL THEN Y.VALOR_FATURA * -1 ELSE Y.VALOR_FATURA END)
                    ) AS VALOR_AJUSTADO
                FROM {{ this }} X
                INNER JOIN {{ this }} Y 
                    ON X.DOCUMENTO_ESTORNO_AJUSTE = Y.DOCUMENTO_CALCULO
                WHERE 
                    X.ESTORNO_AJUSTE = 'X'
                    AND X.VALOR_FATURA = X.VALOR_CONTABIL
                    AND Y.ESTORNO_PLENO IS NULL
            ) sub
            WHERE ORDEM = 1
            AND VALOR_CONTABIL <> VALOR_AJUSTADO
        ) AS x
        WHERE 
            a.DOCUMENTO_CALCULO = x.DOCUMENTO_CALCULO
            AND a.DOCUMENTO_IMPRESSAO = x.DOCUMENTO_IMPRESSAO
            AND x.ORDEM = 1
    {% endset %}
    {% do run_query(update_query) %}
    
{% endmacro %}