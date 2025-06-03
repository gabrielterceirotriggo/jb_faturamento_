{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'merge_insert_only',
    unique_key = ['mes_competencia', 'documento_calculo', 'documento_impressao']
  )
}}

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
    t.flag,
    CURRENT_TIMESTAMP() as data_dados
FROM {{ ref('itens_faturamento_delta') }} AS t

