{% macro update_reversao() %}
    {% set update_query %}
        UPDATE
            {{ this }} AS a
        SET
            REVERSAO = 'X'
        FROM (
            SELECT DISTINCT 
                A.MES_COMPETENCIA, 
                A.DOCUMENTO_CALCULO, 
                A.DOCUMENTO_IMPRESSAO
            FROM 
                {{ ref('int_estornados_delta') }} A
            LEFT JOIN 
                {{ this }} B
                ON A.DOCUMENTO_ESTORNO_PLENO = B.DOCUMENTO_IMPRESSAO
            WHERE 
                A.ESTORNO_PLENO = 'X'
                AND (B.DOCUMENTO_ESTORNO_AJUSTE IS NOT NULL OR B.ESTORNO_AJUSTE = 'X')
        ) AS x
        WHERE 
            a.MES_COMPETENCIA = x.MES_COMPETENCIA
            AND a.DOCUMENTO_CALCULO = x.DOCUMENTO_CALCULO
            AND a.DOCUMENTO_IMPRESSAO = x.DOCUMENTO_IMPRESSAO
    {% endset %}
    {% do run_query(update_query) %}
    {{ log("Macro update_reversao rodou com sucesso", info=True) }}
{% endmacro %}

