WITH 
-- dia_inicial AS (
--     SELECT 
--         --REPLACE(ULTIMA_CARGA, '-', ' ') AS dia_ini
--         '20250214' AS dia_ini
--     FROM 
--         {{ ('stg_tab_controle_cargas') }}
--     WHERE 
--         tabela = 'FATURAMENTO'
-- ),

CCS_STD_EQUATORIAL AS (
    SELECT 
        A.MANDT,
        A.OPBEL DOCUMENTO_IMPRESSAO,
        A.ERDAT DATA_CRIACAO,
        A.CREATION_TIME HORA_CRIACAO,
        A.AEDAT DATA_MODIFICACAO,
        A.ERGRD MOTIVO_CRIACAO,
        A.ABLEINH UNIDADE_LEITURA,
        A.REGPOLIT ESTRUTURA_REGIONAL_POLITICA,
        A.ERNAM USUARIO_CRIACAO,
        A.AENAM USUARIO_MODIFICACAO,
        A.BUDAT DATA_COMPETENCIA,
        A.FAEDN DATA_VENCIMENTO,
        A.TOTAL_AMNT VALOR_TOTAL,
        A.PARTNER PARCEIRO_NEGOCIO,
        A.VKONT CONTA_CONTRATO,
        A.EXBEL FATURA,
        A.BILLING_PERIOD MES_REFERENCIA,
        A.FIKEY CHAVE_RECONCILIACAO,
        A.STOKZ STOKZ,
        A.INTOPBEL INTOPBEL,
        A.ICREASON MOTIVO_ESTORNO_IMPRESSAO,
        A.NRZAS FORMULARIO_PAGAMENTO,
        A.ZZDATAAPR DATA_APRESENTACAO,
        A.ZTIPO TIPO_IMPRESSAO
    FROM {{ ref ('stg_erdk')}} A
    WHERE
        A.MANDT IN (401, 402, 403, 404)
        AND a.erdat  >=  (SELECT ultima_execucao FROM {{ ref('stg_int_ultima_exec') }})
        AND a.erdat  <=  TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        AND a.invoiced = 'X'

        --Trecho abaixo esta comentado apenas para homologação
        -- AND A.ERDAT >= (SELECT dia_ini FROM dia_inicial)
        -- AND A.ERDAT <= '{{ var("dia_fim") }}'
        -- AND A.INVOICED = 'X'
)

SELECT
    mandt,
    CASE
        WHEN CCS_STD_EQUATORIAL.FATURA <> ' ' THEN
            CCS_STD_EQUATORIAL.FATURA
        ELSE
            NULL
    END AS fatura,
    documento_impressao,
    motivo_criacao as motivo_criacao_impressao,
    CASE
        WHEN CCS_STD_EQUATORIAL.tipo_impressao <> ' ' THEN
            CCS_STD_EQUATORIAL.tipo_impressao
        ELSE
            NULL
    END AS tipo_impressao,
    CASE 
        WHEN CCS_STD_EQUATORIAL.data_criacao <> '00000000' THEN 
            TO_DATE(CCS_STD_EQUATORIAL.data_criacao || ' ' || HORA_CRIACAO, 'YYYYMMDD HH24MISS')
        ELSE 
            NULL 
    END AS data_criacao_impressao,
    usuario_criacao,
    CASE
        WHEN ccs_std_equatorial.data_modificacao <> '00000000' THEN 
            TO_DATE(ccs_std_equatorial.data_modificacao || ' ' || HORA_CRIACAO, 'YYYYMMDD HH24MISS')
        ELSE 
            NULL 
    END AS data_modificacao_impressao,
    CASE
        WHEN CCS_STD_EQUATORIAL.usuario_modificacao <> ' ' THEN
            CCS_STD_EQUATORIAL.usuario_modificacao
        ELSE
            NULL
    END AS usuario_modificacao,
    CASE
        WHEN ccs_std_equatorial.data_competencia <> '00000000' THEN 
            TO_DATE(ccs_std_equatorial.data_competencia, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS data_competencia,
    CASE
        WHEN ccs_std_equatorial.data_vencimento <> '00000000' THEN 
            TO_DATE(ccs_std_equatorial.data_vencimento, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS data_vencimento_original,
    CASE
        WHEN ccs_std_equatorial.data_apresentacao <> '00000000' THEN 
            TO_DATE(ccs_std_equatorial.data_apresentacao, 'YYYYMMDD')
        ELSE 
            NULL 
    END AS data_apresentacao,
    conta_contrato,
    data_criacao,
    hora_criacao,
    parceiro_negocio,
    valor_total,
    chave_reconciliacao,
    CASE
        WHEN CCS_STD_EQUATORIAL.intopbel <> ' ' THEN
            CCS_STD_EQUATORIAL.intopbel
        ELSE
            NULL
    END AS contrapartida,
    CASE
        WHEN CCS_STD_EQUATORIAL.motivo_estorno_impressao <> ' ' THEN
            CCS_STD_EQUATORIAL.motivo_estorno_impressao
        ELSE
            NULL
    END AS motivo_estorno_impressao,
    CASE
        WHEN CCS_STD_EQUATORIAL.formulario_pagamento <> ' ' THEN
            CCS_STD_EQUATORIAL.formulario_pagamento
        ELSE
            NULL
    END AS formulario_pagamento,
    CASE
        WHEN CCS_STD_EQUATORIAL.estrutura_regional_politica <> ' ' THEN
            CCS_STD_EQUATORIAL.estrutura_regional_politica
        ELSE
            NULL
    END AS estrutura_regional_politica,
    CASE
        WHEN CCS_STD_EQUATORIAL.unidade_leitura <> ' ' THEN
            CCS_STD_EQUATORIAL.unidade_leitura
        ELSE
            NULL
    END AS unidade_leitura,
    CASE
        WHEN CCS_STD_EQUATORIAL.motivo_criacao = '04' THEN 
            'X'
        ELSE NULL
    END AS estorno_pleno,
    CASE
        WHEN CCS_STD_EQUATORIAL.tipo_impressao = 'FV' THEN
            'X'
        ELSE NULL
    END AS fatura_virtual
FROM
    CCS_STD_EQUATORIAL
