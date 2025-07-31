{% macro atualiza_ordem() %}
   {% set comandos %}
        DELETE FROM {{ ref('int_ordem_faturamento') }} A
        WHERE A.DOCUMENTO_IMPRESSAO IN
        (SELECT DOCUMENTO_IMPRESSAO FROM {{ this }} A);

        INSERT INTO {{ ref('int_ordem_faturamento') }}
        SELECT MES_COMPETENCIA,
                MES_REFERENCIA,
                DOCUMENTO_CALCULO,
                DOCUMENTO_IMPRESSAO,
                TIPO_CALCULO,
                RNK
        FROM {{ this }};

        MERGE INTO {{ ref('faturamento') }} C
        USING {{ ref('int_ordem_faturamento') }} B
        ON (
            C.MES_COMPETENCIA = B.MES_COMPETENCIA
        AND C.MES_REFERENCIA = B.MES_REFERENCIA
        AND C.DOCUMENTO_CALCULO = B.DOCUMENTO_CALCULO
        AND C.DOCUMENTO_IMPRESSAO = B.DOCUMENTO_IMPRESSAO
        AND C.TIPO_CALCULO = B.TIPO_CALCULO
        )
        WHEN MATCHED THEN UPDATE SET C.ORDEM_FATURAMENTO = B.RNK;
        
   {% endset %}
   {% do run_query(comandos) %}
   {{ log("Macro atualiza_ordem rodou com sucesso", info=True) }}
{% endmacro %}