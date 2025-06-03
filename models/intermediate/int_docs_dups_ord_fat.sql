{# {{
  config(
    post_hook = ["{{atualiza_ordem()}}","{{vlr_cont_delta()}}"],
    )
}} #}
SELECT MES_COMPETENCIA,
      MES_REFERENCIA,
      DOCUMENTO_CALCULO,
      DOCUMENTO_IMPRESSAO,
      TIPO_CALCULO,
      RNK, 
      COUNT(*) QTD
FROM {{ ref('int_ordem_faturamento') }}
GROUP BY
      MES_COMPETENCIA,
      MES_REFERENCIA,
      DOCUMENTO_CALCULO,
      DOCUMENTO_IMPRESSAO,
      TIPO_CALCULO,
      RNK  
HAVING COUNT(*) > 1