WITH q_itens_receita AS (
SELECT
    int_documentos_faturamento.mes_competencia,
    int_documentos_faturamento.doc_calculo as documento_calculo,
    int_documentos_faturamento.doc_impressao as documento_impressao,
    NULL AS belzeile,
    NULL AS categoria_tarifa,
    NULL AS setor_industrial,
    NULL AS subclasse,
    int_documentos_faturamento.tipo_calculo,
    int_documentos_faturamento.tipo_documento,
    dberdl.belzart,
    CASE 
        WHEN dberdl.linesort = ' ' THEN NULL 
        ELSE dberdl.linesort 
    END AS linesort,
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
    CASE 
        WHEN int_documentos_faturamento.estorno = 'X' THEN dberdl.nettobtr * -1 
        ELSE dberdl.nettobtr 
    END receita,
    CAST(NULL AS NUMBER) as consumo,
    CAST(NULL AS NUMBER) as preco,
    --dberdl.nettobtr AS receita,
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
    int_documentos_faturamento.estorno
FROM
    {{ ref('int_documentos_faturamento')}} int_documentos_faturamento
LEFT OUTER JOIN
    {{ ref('stg_dberdl')}} dberdl
ON
    int_documentos_faturamento.doc_impressao = dberdl.printdoc
WHERE 
    dberdl.xtotal_amnt = 'X'
)

select * from q_itens_receita

