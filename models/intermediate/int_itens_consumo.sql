WITH int_documentos_faturamento as (
    SELECT
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        estorno,
        mes_competencia
    FROM
        {{ ref ('int_documentos_faturamento') }}
),

DBERDLB AS (
    SELECT
        mandt,
        printdoc,
        printdocline,
        billdoc,    
        billdocline,
        hvorg,
        bukrs,
        xtotal_amnt,
        vertrag,
        abpopbel,
        sparte,
        txjcd,
        mwskz,
        nettobtr,
        sttax,
        ztipo,
        zordem,
        data_dados
    FROM
        {{ ref ('stg_dberdlb')}}
),

dberchz1 AS (
    SELECT
        mandt,
        belnr,
        belzeile,
        belzart,
        branche,
        tvorg,
        linesort,
        ab,
        bis,
        tariftyp,
        temp_area,
        v_abrmenge,
        n_abrmenge,
        data_dados
    FROM 
        {{ ref('stg_dberchz1')}}  
),

dberchz3 AS (
SELECT
	mandt,
	belnr,
	belzeile,
	zonennr,
	preisbtr,
	n_nettobtr_l,
	nettobtr,
	data_dados
FROM
    {{ ref('stg_dberchz3')}}
),

dberchz5 AS (
SELECT
    mandt,
    belnr,
    belzeile,
    belzart,
    branche,
    tvorg,
    linesort,
    ab,
    bis,
    tariftyp,
    temp_area,
    v_abrmenge,
    n_abrmenge,
    data_dados
FROM    
    {{ ref('stg_dberchz5')}}
),

dberchz7 AS (
SELECT
	mandt,
	belnr,
	belzeile,
	mwskz,
	ermwskz,
	nettobtr,
	twaers,
	preistuf,
	preistyp,
	preis,
	preiszus,
	vonzone,
	biszone,
	zonennr,
	preisbtr,
	mngbasis,
	preigkl,
	urpreis,
	preiadd,
	preifakt,
	opmult,
	txdat_kk,
	prctr,
	kostl,
	ps_psp_pnr,
	aufnr,
	paobjnr,
	paobjnr_s,
	gsber,
	aperiodic,
	grossgroup,
	bruttozeile,
	bupla,
	line_class,
	preisart,
	segment,
	v_nettobtr_l,
	n_nettobtr_l,
	data_dados
FROM
    {{ ref('stg_dberchz7')}}
),

Q_ITENS_CONSUMO AS (
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
        dberchz3.ZONENNR AS escalao,
        CASE 
            WHEN dberchz1.AB <> '00000000' THEN TO_DATE(dberchz1.AB, 'YYYYMMDD') 
            ELSE NULL 
        END inicio_calculo,
        CASE
            WHEN dberchz1.BIS <> '00000000' THEN TO_DATE(dberchz1.BIS, 'YYYYMMDD')
            ELSE NULL
        END fim_calculo,
        NULL AS tipo_imposto,
        CASE 
            WHEN int_documentos_faturamento.TIPO_CALCULO = 'CM'
                AND (
                    ((dberchz1.V_ABRMENGE + dberchz1.N_ABRMENGE) > 0 AND DBERCHZ3.NETTOBTR < 0) OR 
                    ((dberchz1.V_ABRMENGE + dberchz1.N_ABRMENGE) < 0 AND DBERCHZ3.NETTOBTR > 0)
                )
            THEN (dberchz1.V_ABRMENGE + dberchz1.N_ABRMENGE) * -1
            ELSE dberchz1.V_ABRMENGE + dberchz1.N_ABRMENGE
        END AS consumo,
        dberchz3.preisbtr AS preco,
        -- Não tinha na tabela
        DBERDLB.nettobtr AS receita,
        DBERDLB.STTAX AS base_imposto,
        0 AS ALIQUOTA,
        DBERDLB.hvorg AS operacao,
        dberchz1.tvorg AS sub_operacao,
        DBERDLB.txjcd AS domicilio_fiscal,
        int_documentos_faturamento.estorno
    FROM 
        int_documentos_faturamento
    LEFT JOIN DBERDLB 
        ON DBERDLB.MANDT = int_documentos_faturamento.MANDT
        AND int_documentos_faturamento.DOC_IMPRESSAO = DBERDLB.PRINTDOC
        AND int_documentos_faturamento.DOC_CALCULO = DBERDLB.BILLDOC
    LEFT JOIN dberchz1
        ON dberchz1.MANDT = DBERDLB.MANDT
        AND dberchz1.BELNR = DBERDLB.BILLDOC
        AND DBERDLB.BILLDOCLINE = dberchz1.BELZEILE
    LEFT JOIN dberchz3 
        ON dberchz1.MANDT = dberchz3.MANDT
        AND dberchz1.BELNR = dberchz3.BELNR
        AND dberchz1.BELZEILE = dberchz3.BELZEILE
    WHERE
        DBERDLB.XTOTAL_AMNT = 'X'
        --AND int_documentos_faturamento.MANDT IN (401, 402, 403, 404)
),

Q_ITENS_CONSUMO2 AS (
    SELECT
        int_documentos_faturamento.mes_competencia,
        int_documentos_faturamento.doc_calculo AS documento_calculo,
        int_documentos_faturamento.doc_impressao AS documento_impressao,
        int_documentos_faturamento.tipo_calculo,
        int_documentos_faturamento.tipo_documento,
        dberchz5.belzeile,
        dberchz5.branche AS setor_industrial,
        dberchz5.tariftyp AS categoria_tarifa,
        dberchz5.temp_area AS subclasse,
        dberchz5.belzart,
        dberchz5.linesort,
        dberchz7.ZONENNR AS escalao,
        CASE 
            WHEN dberchz5.AB <> '00000000' THEN TO_DATE(dberchz5.AB, 'YYYYMMDD') 
            ELSE NULL 
        END inicio_calculo,
        CASE
            WHEN dberchz5.BIS <> '00000000' THEN TO_DATE(dberchz5.BIS, 'YYYYMMDD')
            ELSE NULL
        END fim_calculo,
        NULL AS tipo_imposto,
        CASE 
            WHEN int_documentos_faturamento.TIPO_CALCULO = 'CM'
                AND (
                    ((dberchz5.V_ABRMENGE + dberchz5.N_ABRMENGE) > 0 AND dberchz7.NETTOBTR < 0) OR 
                    ((dberchz5.V_ABRMENGE + dberchz5.N_ABRMENGE) < 0 AND dberchz7.NETTOBTR > 0)
                )
            THEN (dberchz5.V_ABRMENGE + dberchz5.N_ABRMENGE) * -1
            ELSE dberchz5.V_ABRMENGE + dberchz5.N_ABRMENGE
        END AS consumo,
        dberchz7.preisbtr AS preco,
        -- Não tinha na tabela
        DBERDLB.nettobtr AS receita,
        DBERDLB.STTAX AS base_imposto,
        0 AS ALIQUOTA,
        DBERDLB.hvorg AS operacao,
        dberchz5.tvorg AS sub_operacao,
        DBERDLB.txjcd AS domicilio_fiscal,
        int_documentos_faturamento.estorno
    FROM 
        int_documentos_faturamento
    LEFT JOIN DBERDLB 
        ON DBERDLB.MANDT = int_documentos_faturamento.MANDT
        AND int_documentos_faturamento.DOC_IMPRESSAO = DBERDLB.PRINTDOC
        AND int_documentos_faturamento.DOC_CALCULO = DBERDLB.BILLDOC
    LEFT JOIN dberchz5
        ON dberchz5.MANDT = DBERDLB.MANDT
        AND dberchz5.BELNR = DBERDLB.BILLDOC
        AND DBERDLB.BILLDOCLINE = dberchz5.BELZEILE
    LEFT JOIN dberchz7 
        ON dberchz5.MANDT = dberchz7.MANDT
        AND dberchz5.BELNR = dberchz7.BELNR
        AND dberchz5.BELZEILE = dberchz7.BELZEILE
    WHERE
        DBERDLB.XTOTAL_AMNT = 'X'
        --AND int_documentos_faturamento.MANDT IN (401, 402, 403, 404)
),

FINAL1 AS(
SELECT
    Q_ITENS_CONSUMO.mes_competencia,
    Q_ITENS_CONSUMO.documento_calculo,
    Q_ITENS_CONSUMO.documento_impressao,
    Q_ITENS_CONSUMO.tipo_calculo,
    Q_ITENS_CONSUMO.tipo_documento,
    Q_ITENS_CONSUMO.belzeile,
    Q_ITENS_CONSUMO.setor_industrial,
    Q_ITENS_CONSUMO.categoria_tarifa,
    Q_ITENS_CONSUMO.subclasse,
    Q_ITENS_CONSUMO.belzart,
    Q_ITENS_CONSUMO.linesort,
    -- Não tinha na tabela
    Q_ITENS_CONSUMO.escalao,
    Q_ITENS_CONSUMO.inicio_calculo,
    Q_ITENS_CONSUMO.fim_calculo,
    Q_ITENS_CONSUMO.tipo_imposto,
    CASE 
        WHEN Q_ITENS_CONSUMO.ESTORNO = 'X' 
        THEN Q_ITENS_CONSUMO.CONSUMO * -1 
        ELSE Q_ITENS_CONSUMO.CONSUMO 
    END AS CONSUMO,
    Q_ITENS_CONSUMO.preco,
    -- Não tinha na tabela
    CASE 
        WHEN Q_ITENS_CONSUMO.estorno = 'X' 
        THEN Q_ITENS_CONSUMO.RECEITA * -1 
        ELSE Q_ITENS_CONSUMO.RECEITA 
    END AS RECEITA,
    Q_ITENS_CONSUMO.base_imposto,
    Q_ITENS_CONSUMO.ALIQUOTA,
    Q_ITENS_CONSUMO.operacao,
    CASE 
        WHEN Q_ITENS_CONSUMO.SUB_OPERACAO = ' ' THEN NULL
        ELSE Q_ITENS_CONSUMO.SUB_OPERACAO
    END AS SUB_OPERACAO,
    Q_ITENS_CONSUMO.domicilio_fiscal,
    Q_ITENS_CONSUMO.estorno
FROM
    Q_ITENS_CONSUMO
),

FINAL2 AS (
SELECT
    Q_ITENS_CONSUMO2.mes_competencia,
    Q_ITENS_CONSUMO2.documento_calculo,
    Q_ITENS_CONSUMO2.documento_impressao,
    Q_ITENS_CONSUMO2.tipo_calculo,
    Q_ITENS_CONSUMO2.tipo_documento,
    Q_ITENS_CONSUMO2.belzeile,
    Q_ITENS_CONSUMO2.setor_industrial,
    Q_ITENS_CONSUMO2.categoria_tarifa,
    Q_ITENS_CONSUMO2.subclasse,
    Q_ITENS_CONSUMO2.belzart,
    Q_ITENS_CONSUMO2.linesort,
    -- Não tinha na tabela
    Q_ITENS_CONSUMO2.escalao,
    Q_ITENS_CONSUMO2.inicio_calculo,
    Q_ITENS_CONSUMO2.fim_calculo,
    Q_ITENS_CONSUMO2.tipo_imposto,
    CASE 
        WHEN Q_ITENS_CONSUMO2.ESTORNO = 'X' 
        THEN Q_ITENS_CONSUMO2.CONSUMO * -1 
        ELSE Q_ITENS_CONSUMO2.CONSUMO 
    END AS CONSUMO,
    Q_ITENS_CONSUMO2.preco,
    -- Não tinha na tabela
    CASE 
        WHEN Q_ITENS_CONSUMO2.estorno = 'X' 
        THEN Q_ITENS_CONSUMO2.RECEITA * -1 
        ELSE Q_ITENS_CONSUMO2.RECEITA 
    END AS RECEITA,
    Q_ITENS_CONSUMO2.base_imposto,
    Q_ITENS_CONSUMO2.ALIQUOTA,
    Q_ITENS_CONSUMO2.operacao,
    CASE 
        WHEN Q_ITENS_CONSUMO2.SUB_OPERACAO = ' ' THEN NULL
        ELSE Q_ITENS_CONSUMO2.SUB_OPERACAO
    END AS SUB_OPERACAO,
    Q_ITENS_CONSUMO2.domicilio_fiscal,
    Q_ITENS_CONSUMO2.estorno
FROM
    Q_ITENS_CONSUMO2
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
    consumo,
    preco,
    receita,
    base_imposto,
    aliquota,
    operacao,
    sub_operacao,
    domicilio_fiscal,
    estorno
FROM 
    FINAL1
UNION ALL
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
    consumo,
    preco,
    receita,
    base_imposto,
    aliquota,
    operacao,
    sub_operacao,
    domicilio_fiscal,
    estorno
FROM 
    FINAL2