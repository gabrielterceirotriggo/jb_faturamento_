{% macro atualiza_ordem() %}
    {% set update_query %}
        UPDATE
            {{ this }} AS C
        SET
            C.ORDEM_FATURAMENTO = B.RNK
        FROM
            (
                WITH BASE AS (
                    SELECT
                        B.MES_COMPETENCIA, 
                        B.MES_REFERENCIA,
                        B.DOCUMENTO_CALCULO,
                        B.DOCUMENTO_IMPRESSAO,
                        B.TIPO_CALCULO,
                        ROW_NUMBER() OVER (
                        PARTITION BY B.CONTA_CONTRATO, B.TIPO_CALCULO, B.MES_REFERENCIA
                        ORDER BY b.data_criacao_impressao ASC
                    ) RNK
                    FROM
                    (
                        select 
                            a.mes_referencia, a.conta_contrato
                        from
                            {{ this }} a
                        where 1=1
                        and a.cnr is null
                        and a.tipo_calculo in ('CP', 'CF', 'CS')
                        and a.ordem_faturamento is null
                        group by a.mes_referencia, a.conta_contrato
                    ) c left join {{ this }} b on c.conta_contrato = b.conta_contrato and c.mes_referencia = b.mes_referencia
                    )

                    SELECT
                        MES_COMPETENCIA, 
                        MES_REFERENCIA,
                        DOCUMENTO_CALCULO,
                        DOCUMENTO_IMPRESSAO,
                        TIPO_CALCULO,
                        RNK
                    FROM
                        BASE
                    WHERE 
                        RNK = 1
            ) B
        WHERE
            C.MES_COMPETENCIA = B.MES_COMPETENCIA
            AND C.MES_REFERENCIA = B.MES_REFERENCIA
            AND C.DOCUMENTO_CALCULO = B.DOCUMENTO_CALCULO
            AND C.DOCUMENTO_IMPRESSAO = B.DOCUMENTO_IMPRESSAO
            AND C.TIPO_CALCULO = B.TIPO_CALCULO
    {% endset %}
    {% do run_query(update_query) %}
{% endmacro %}
        