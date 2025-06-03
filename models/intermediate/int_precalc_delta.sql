-- WITH dia_inicial AS (
--     SELECT 
--         REPLACE(ULTIMA_CARGA, '-', ' ') AS dia_ini
--     FROM 
--         {{ ('stg_tab_controle_cargas') }}
--     WHERE 
--         tabela = 'FATURAMENTO'
-- ),

WITH base AS (
    SELECT
        /*+ PARALLEL (A,6) ORDERED USE_NL (B) USE_NL(C) USE_NL(D) USE_NL(E) INDEX(ETTIFN-~Z01) */
        A.MANDT,
        A.OPBEL DOCUMENTO_IMPRESSAO,
        B.BELNR DOCUMENTO_CALCULO,
        A.BUDAT DATA_COMPETENCIA,
        C.BILLING_PERIOD AS "PERIOD",
        A.EXBEL FATURA,
        D.ANLAGE,
        C.VKONT,
        C.GPARTNER,
        C.VERTRAG,
        C.ABLEINH,
        A.ERGRD MOTIVO_CRIACAO_IMPRESSAO,
        A.ZTIPO TIPO_IMPRESSAO,
        C.BELEGART,
        C.ZZORIGDOC,
        CASE
            WHEN A.ERGRD = '04' THEN
                'X'
            ELSE 
                NULL
        END ESTORNO_PLENO,
        C.SC_BELNR_H,
        CASE
            WHEN A.ZTIPO = 'FV' THEN 
                'X'
            ELSE 
                NULL
        END FATURA_VIRTUAL,
        CASE
            WHEN E.BELNR IS NOT NULL THEN 
                'X'
            ELSE 
                NULL
        END MINIMO,
        C.BEGABRPE,
        C.ENDABRPE,
        CASE
            WHEN A.INTOPBEL <> ' ' THEN 
                A.INTOPBEL
            ELSE 
                NULL
        END CONTRAPARTIDA,
        CASE
            WHEN A.ERGRD = '04' THEN 
                A.BUDAT
            ELSE 
                NULL
        END DATA_ESTORNO_PLENO,
        A.ICREASON MOTIVO_ESTORNO_IMPRESSAO,
        C.SC_BELNR_N,
        C.STORNODAT,
        C.BCREASON,
        A.TOTAL_AMNT VALOR_TOTAL,
        A.FIKEY CHAVE_RECONCILIACAO,
        A.NRZAS FORMULARIO_PAGAMENTO,
        C.TXJCD,
        C.ZUORDDAA,
        A.ZZDATAAPR DATA_APRESENTACAO,
        A.FAEDN DATA_VENCIMENTO_ORIGINAL,
        C.ADATSOLL,
        A.ERDAT DATA_CRIACAO_IMPRESSAO,
        A.CREATION_TIME HORA_CRIACAO,
        A.ERNAM USUARIO_CRIACAO,
        A.AEDAT DATA_MODIFICACAO_IMPRESSAO,
        A.AENAM USUARIO_MODIFICACAO,
        C.EROETIM,
        C.ERDAT,
        C.ERNAM,
        C.AEDAT,
        C.AENAM,
        C.BELNRALT,
        A.REGPOLIT ESTRUTURA_REGIONAL_POLITICA
    FROM
        {{ ref('stg_erdk')}} A
        INNER JOIN {{ ref('stg_erchc')}} B
            ON A.MANDT = B.MANDT
            AND A.OPBEL = B.OPBEL
        INNER JOIN {{ ref('stg_erch')}} C
            ON B.MANDT = C.MANDT 
            AND B.BELNR = C.BELNR
        LEFT JOIN {{ ref('stg_ever')}} D
            ON C.MANDT = D.MANDT
            AND C.VERTRAG = D.VERTRAG
        LEFT JOIN {{ ref('stg_ettifn')}} E
            ON D.ANLAGE = E.ANLAGE
            AND E.OPERAND = 'FL_MINIMO'
            AND E.BIS = C.ENDABRPE
            AND C.BELNR = E.BELNR
        WHERE
            A.MANDT IN (401, 402, 403, 404)
            AND a.erdat  >=  (SELECT ultima_execucao FROM {{ ref('stg_int_ultima_exec') }})
            AND a.erdat  <=  TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
            AND a.invoiced = 'X'
            --'{{ var("dia_fim") }}'
)

SELECT
    SUBSTR(DATA_COMPETENCIA, 1, 6) AS mes_competencia,
    LEFT("PERIOD", 4) || RIGHT("PERIOD", 2) AS "period",
    DOCUMENTO_CALCULO,
    DOCUMENTO_IMPRESSAO,
    CASE
        WHEN FATURA != ' ' THEN 
            FATURA
        ELSE 
            NULL
    END AS FATURA,
    CASE
        WHEN ANLAGE != ' ' THEN 
            ANLAGE
        ELSE 
            NULL
    END AS INSTALACAO,
    VKONT AS CONTA_CONTRATO,
    GPARTNER AS PARCEIRO_NEGOCIO,
    VERTRAG AS CONTRATO,
    ABLEINH AS UNIDADE_LEITURA,
    SUBSTR(ABLEINH, 3, 2) AS ETAPA,
    MOTIVO_CRIACAO_IMPRESSAO,
    TIPO_IMPRESSAO,
    BELEGART AS TIPO_CALCULO,
    CASE 
        WHEN ZZORIGDOC <> ' ' THEN 
            ZZORIGDOC 
        ELSE 
            NULL 
    END AS ORIGEM_DOCUMENTO,
    CASE 
        WHEN ZZORIGDOC IN ('ip', 'rs', 'fr', 'ds', 'cl') THEN 
            'X' 
        ELSE 
            NULL 
    END AS CNR,
    ESTORNO_PLENO,
    CASE 
        WHEN SC_BELNR_H = ' ' THEN 
            NULL 
        ELSE 
            'X' 
    END AS estorno_ajuste,
    FATURA_VIRTUAL,
    MINIMO,
    CASE
        WHEN BEGABRPE <> '00000000' THEN 
            TO_DATE(BEGABRPE, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS inicio_calculo,
    CASE
        WHEN ENDABRPE <> '00000000' THEN 
            TO_DATE(ENDABRPE, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS fim_calculo,
    CONTRAPARTIDA AS DOCUMENTO_ESTORNO_PLENO,
    CASE
        WHEN DATA_ESTORNO_PLENO <> '00000000' THEN 
            TO_DATE(DATA_ESTORNO_PLENO, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_ESTORNO_PLENO,
    motivo_estorno_impressao AS MOTIVO_ESTORNO_PLENO,
    CASE 
        WHEN SC_BELNR_N <> ' ' THEN 
            SC_BELNR_N 
        ELSE 
            SC_BELNR_H 
    END AS DOCUMENTO_ESTORNO_AJUSTE,
    CASE
        WHEN STORNODAT <> '00000000' THEN 
            TO_DATE(STORNODAT, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_ESTORNO_AJUSTE,
    CASE
        WHEN BCREASON <> ' ' THEN 
            BCREASON
        ELSE 
            NULL 
    END AS MOTIVO_ESTORNO_AJUSTE,
    VALOR_TOTAL AS VALOR_FATURA,
    CHAVE_RECONCILIACAO,
    FORMULARIO_PAGAMENTO,
    TXJCD AS domicilio_fiscal,
    CASE
        WHEN DATA_COMPETENCIA <> '00000000' THEN 
            TO_DATE(DATA_COMPETENCIA, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_COMPETENCIA,
    CASE
        WHEN ZUORDDAA <> '00000000' THEN 
            TO_DATE(ZUORDDAA, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_ATRIBUICAO_CALCULO,
    CASE
        WHEN DATA_APRESENTACAO <> '00000000' THEN 
            TO_DATE(DATA_APRESENTACAO, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_APRESENTACAO,
    CASE
        WHEN DATA_VENCIMENTO_ORIGINAL <> '00000000' THEN 
            TO_DATE(DATA_VENCIMENTO_ORIGINAL, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_VENCIMENTO_ORIGINAL,
    CASE
        WHEN ADATSOLL <> '00000000' THEN 
            TO_DATE(ADATSOLL, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_PREVISAO_LEITURA,
    CASE
        WHEN DATA_CRIACAO_IMPRESSAO <> '00000000' THEN 
            TO_DATE(DATA_CRIACAO_IMPRESSAO || ' ' || HORA_CRIACAO, 'YYYYMMDD HH24MISS')
        ELSE 
            NULL 
    END AS DATA_CRIACAO_IMPRESSAO,
    CASE
        WHEN USUARIO_CRIACAO <> ' ' THEN 
            USUARIO_CRIACAO
        ELSE 
            NULL 
    END AS USUARIO_CRIACAO_IMPRESSAO,
    CASE
        WHEN DATA_MODIFICACAO_IMPRESSAO <> '00000000' THEN 
            TO_DATE(DATA_MODIFICACAO_IMPRESSAO, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_MODIFICACAO_IMPRESSAO,
    CASE
        WHEN USUARIO_MODIFICACAO <> ' ' THEN 
            USUARIO_MODIFICACAO
        ELSE 
            NULL 
    END AS usuario_modificacao_impressao,
    CASE 
        WHEN ERDAT <> '00000000' AND EROETIM <> ' ' THEN 
            TO_DATE(ERDAT || ' ' || EROETIM, 'YYYYMMDD HH24MI')
        WHEN ERDAT <> '00000000' THEN 
            TO_DATE(ERDAT, 'YYYYMMDD')
        ELSE 
            NULL
    END DATA_CRIACAO_CALCULO,
    CASE
        WHEN ERNAM <> ' ' THEN 
            ERNAM
        ELSE 
            NULL 
    END AS USUARIO_CRIACAO_CALCULO,
    CASE
        WHEN AEDAT <> '00000000' THEN 
            TO_DATE(AEDAT, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS DATA_MODIFICACAO_CALCULO,
    CASE
        WHEN AENAM <> ' ' THEN 
            AENAM
        ELSE 
            NULL 
    END AS USUARIO_MODIFICACAO_CALCULO,
    CASE
        WHEN BELNRALT <> ' ' THEN 
            BELNRALT
        ELSE 
            NULL 
    END AS DOCUMENTO_CALCULO_ANTERIOR,
    CASE
        WHEN ESTRUTURA_REGIONAL_POLITICA <> ' ' THEN 
            ESTRUTURA_REGIONAL_POLITICA
        ELSE 
            NULL 
    END AS ESTRUTURA_REGIONAL_POLITICA
FROM
    base
