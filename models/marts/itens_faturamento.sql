
{{
    config(
        materialized='incremental'
    )
}}


-- WITH 
-- int_max_mes_competencia AS (
--     SELECT max_mes
--     FROM {{ ref('int_max_mes_competencia') }}
-- )
SELECT
    t.mes_competencia,
    t.documento_calculo,
    t.documento_impressao,
    t.linha,
    t.setor_industrial,
    t.categoria_tarifa,
    t.subclasse,
    t.item_documento,
    t.item_ordenacao,
    t.escalao,
    t.inicio_calculo,
    t.fim_calculo,
    t.tipo_imposto,
    t.consumo,
    t.preco,
    t.receita,
    t.base_imposto,
    t.aliquota,
    t.operacao,
    t.sub_operacao,
    t.domicilio_fiscal,
    t.flag
FROM {{ ref('itens_faturamento_delta') }} AS t

