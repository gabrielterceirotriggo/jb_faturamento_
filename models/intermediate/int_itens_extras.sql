WITH q_itens_extras AS (
    SELECT    
        int_documentos_faturamento.mes_competencia,
        int_documentos_faturamento.doc_calculo AS documento_calculo,
        int_documentos_faturamento.doc_impressao AS documento_impressao,
        int_documentos_faturamento.tipo_calculo AS tipo_calculo,
        int_documentos_faturamento.tipo_documento AS tipo_documento,
        dberchz1.belzeile,
        dberchz1.branche AS setor_industrial,
        dberchz1.tariftyp AS categoria_tarifa,
        dberchz1.temp_area AS subclasse,
        dberchz1.belzart,
        dberchz1.linesort,
        dberchz3.zonennr AS escalao,
        CASE 
            WHEN dberchz1.ab <> '00000000' THEN TO_DATE(dberchz1.ab, 'YYYYMMDD') 
            ELSE NULL 
        END AS inicio_calculo,

        CASE 
            WHEN dberchz1.bis <> '00000000' THEN TO_DATE(dberchz1.bis, 'YYYYMMDD') 
            ELSE NULL 
        END AS fim_calculo,

        NULL AS tipo_imposto,

        CASE 
            WHEN int_documentos_faturamento.tipo_calculo = 'CM' AND (
                ((dberchz1.v_abrmenge + dberchz1.n_abrmenge) > 0 AND dberchz3.n_nettobtr_l < 0) OR 
                ((dberchz1.v_abrmenge + dberchz1.n_abrmenge) < 0 AND dberchz3.n_nettobtr_l > 0)
            ) 
            THEN (dberchz1.v_abrmenge + dberchz1.n_abrmenge) * -1
            ELSE dberchz1.v_abrmenge + dberchz1.n_abrmenge
        END AS consumo,

        dberchz3.preisbtr AS preco,
        dberdlb.nettobtr AS receita,
        dberdlb.sttax AS base_imposto,
        0 AS aliquota,
        dberdlb.hvorg AS operacao,

        CASE 
            WHEN dberchz1.tvorg = ' ' THEN NULL 
            ELSE dberchz1.tvorg 
        END AS sub_operacao,

        dberdlb.txjcd AS domicilio_fiscal,
        int_documentos_faturamento.estorno 
    FROM
        {{ ref('int_documentos_faturamento')}} int_documentos_faturamento
    LEFT OUTER JOIN
        {{ ref('stg_dberdlb')}} AS dberdlb
        ON int_documentos_faturamento.doc_impressao = dberdlb.printdoc
        AND int_documentos_faturamento.doc_calculo = dberdlb.billdoc
    LEFT OUTER JOIN
        {{ ref('stg_dberchz1')}} dberchz1
        ON dberchz1.belnr = dberdlb.billdoc
        AND dberchz1.belzeile = dberdlb.billdocline
    LEFT OUTER JOIN
        {{ ref('stg_dberchz3')}} dberchz3
        ON dberchz1.belnr = dberchz3.belnr
        AND dberchz1.belzeile = dberchz3.belzeile
    WHERE
        DBERCHZ1.BELZART IN (
            'ZGSAT','ZGSNP','ZGSFP','ZGSRV','ZGSIT','ZPCAFP','ZPCANP',
            'ZPGFP','ZPGNP','ZPCAT','ZPGAT','ZDR1','ZDR2','ZDR3','ZDR4',
            'ZDR5','ZDR6','ZUR1','ZUR2','ZUR3','ZEUSD','ZRAMAL','ZEUSDB',
            'ZDCFP','ZDCFPL','ZDCGER','ZDCMFP','ZDCMNP','ZDCNP','ZDCNPL',
            'ZDCOMP','ZDCONL','ZDCONT','ZDCT'
        )
)

SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    tipo_calculo,
    tipo_documento,
    belzeile,
    setor_industrial,
    categoria_tarifa,
    subclasse,
    belzart,
    linesort,
    escalao,
    inicio_calculo,
    fim_calculo,
    tipo_imposto,

    CASE 
        WHEN estorno = 'X' THEN consumo * -1 
        ELSE consumo 
    END AS consumo,

    preco,

    CASE 
        WHEN estorno = 'X' THEN receita * -1 
        ELSE receita 
    END AS receita,

    base_imposto,
    aliquota,
    CASE 
        WHEN operacao = ' ' THEN NULL 
        ELSE operacao 
    END AS operacao,

    CASE 
        WHEN sub_operacao = ' ' THEN NULL 
        ELSE sub_operacao 
    END AS sub_operacao,

    CASE 
        WHEN domicilio_fiscal = ' ' THEN NULL 
        ELSE domicilio_fiscal 
    END AS domicilio_fiscal,
    estorno 
FROM
    q_itens_extras
