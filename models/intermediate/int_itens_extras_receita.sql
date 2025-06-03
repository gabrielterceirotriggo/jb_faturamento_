SELECT    
    int_documentos_faturamento.mes_competencia,
    int_documentos_faturamento.doc_calculo AS documento_calculo,
    int_documentos_faturamento.doc_impressao AS documento_impressao,
    NULL AS linha,
    NULL AS setor_industrial,
    NULL AS categoria_tarifa,
    NULL AS subclasse,
    int_documentos_faturamento.tipo_calculo,
    int_documentos_faturamento.tipo_documento,
    dberdl.belzart AS item_documento,
    CASE 
        WHEN dberdl.linesort = ' ' THEN NULL 
        ELSE dberdl.linesort 
    END AS item_ordenacao,
    '000' AS escalao,
    CASE 
        WHEN dberdl.ab <> '00000000' THEN TO_DATE(dberdl.ab, 'YYYYMMDD') 
        ELSE NULL 
    END AS inicio_calculo,
    CASE 
        WHEN dberdl.bis <> '00000000' THEN TO_DATE(dberdl.bis, 'YYYYMMDD') 
        ELSE NULL 
    END AS fim_calculo,
    CASE 
        WHEN dberdl.ktosl = ' ' THEN NULL 
        ELSE dberdl.ktosl 
    END AS tipo_imposto,
    CAST(NULL AS NUMBER) AS consumo,
    CAST(NULL AS NUMBER) AS preco,
    CASE 
        WHEN int_documentos_faturamento.estorno = 'x' THEN dberdl.nettobtr * -1 
        ELSE dberdl.nettobtr 
    END AS receita,
    dberdl.sbasw AS base_imposto,
    CASE 
        WHEN dberdl.stprz = ' ' THEN 0 
        ELSE TRY_CAST(LTRIM(dberdl.stprz, ' ') AS NUMBER(10,3)) / 1000
    END AS aliquota,
    CASE 
        WHEN dberdl.hvorg = ' ' THEN NULL 
        ELSE dberdl.hvorg 
    END AS operacao,
    CASE 
        WHEN dberdl.tvorg = ' ' THEN NULL 
        ELSE dberdl.tvorg 
    END AS sub_operacao,
    CASE 
        WHEN dberdl.txjcd = ' ' THEN NULL 
        ELSE dberdl.txjcd 
    END AS domicilio_fiscal,
    'D' AS flag,
    int_documentos_faturamento.estorno

FROM
    {{ ref('int_documentos_faturamento') }} int_documentos_faturamento
LEFT OUTER JOIN 
    {{ ref('stg_dberdl') }} dberdl
ON
    dberdl.printdoc = int_documentos_faturamento.doc_impressao
WHERE
    dberdl.XTOTAL_AMNT <> 'X'
    AND dberdl.LINESORT IN ('ZDR1','ZDR2','ZDR3','ZDR4','ZDR5',
        'ZDR6','ZUR1','ZUR2','ZUR3','ZDES')
