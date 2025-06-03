SELECT 
    int_documentos_faturamento.mes_competencia,
    int_documentos_faturamento.doc_calculo AS documento_calculo,
    int_documentos_faturamento.doc_impressao AS documento_impressao,
    int_documentos_faturamento.tipo_calculo,
    int_documentos_faturamento.tipo_documento,
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
    null AS tipo_imposto,
    CASE 
        WHEN int_documentos_faturamento.tipo_calculo = 'CM' 
            AND (
                ((dberchz1.v_abrmenge + dberchz1.n_abrmenge) > 0 AND dberchz3.nettobtr < 0) 
                OR 
                ((dberchz1.v_abrmenge + dberchz1.n_abrmenge) < 0 AND dberchz3.nettobtr > 0)
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
    {{ ref('stg_dberdlb')}} as dberdlb
ON 
    int_documentos_faturamento.doc_impressao = dberdlb.printdoc
    and int_documentos_faturamento.doc_calculo = dberdlb.billdoc
LEFT OUTER JOIN
    {{ ref('stg_dberchz1')}} dberchz1
ON
    dberchz1.belnr = dberdlb.billdoc
    and dberchz1.belzeile = dberdlb.billdocline
LEFT OUTER JOIN
    {{ ref('stg_dberchz3')}} dberchz3
ON
    dberchz1.belnr = dberchz3.belnr
    and dberchz1.belzeile = dberchz3.belzeile
LEFT OUTER JOIN
    {{ ref('stg_zfatt057_ophist')}} zfatt057_ophist
ON
    dberchz1.belzart = zfatt057_ophist.belzart
    and dberchz1.ein01 = zfatt057_ophist.operand
WHERE 
    zfatt057_ophist.ez_abrmenge_flag = 'X'
    and dberdlb.xtotal_amnt <> 'X'
