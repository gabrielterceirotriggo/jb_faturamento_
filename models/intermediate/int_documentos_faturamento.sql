WITH 
-- dia_inicial AS (
--     SELECT 
--         REPLACE(ULTIMA_CARGA, '-', ' ') AS dia_ini
--     FROM 
--         {{ ('stg_tab_controle_cargas') }}
--     WHERE 
--         tabela = 'FATURAMENTO'
-- ),

calculos AS (
    SELECT
        A.MANDT,
        B.BELNR AS DOC_CALCULO,
        A.OPBEL AS DOC_IMPRESSAO,
        C.BELEGART AS TIPO_CALCULO,
        CASE 
            WHEN C.ZZORIGDOC <> ' ' THEN C.ZZORIGDOC 
            ELSE NULL 
        END AS TIPO_DOCUMENTO,
        CASE 
            WHEN A.ERGRD = '04' THEN 'X' 
            ELSE NULL 
        END AS ESTORNO,
        CASE 
            WHEN A.BUDAT <> '00000000' THEN A.BUDAT 
            ELSE NULL 
        END AS MES_COMPETENCIA
    FROM 
        {{ ref('stg_erdk') }} A 
    INNER JOIN 
        {{ ref('stg_erchc') }} B 
        ON (A.MANDT = B.MANDT) AND (A.OPBEL = B.OPBEL)
    INNER JOIN 
        {{ ref('stg_erch') }} C 
        ON (B.MANDT = C.MANDT) AND (B.BELNR = C.BELNR)
    WHERE 
        -- A.MANDT IN (401, 402, 403, 404)
        -- AND 
        A.INVOICED = 'X'
        AND A.ERGRD <> '04'
        AND A.ERDAT >= (SELECT ultima_execucao FROM {{ ref('stg_int_ultima_exec') }})
        AND A.ERDAT <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        --alterado para homologacao
        -- AND A.ERDAT >= (SELECT dia_ini FROM dia_inicial)
        -- AND A.ERDAT <= '{{ var("dia_fim") }}'
),

ESTORNOS_PLENOS AS (
SELECT
    /*+ PARALLEL (A, 6)*/
    A.MANDT,
    B.BELNR AS DOC_CALCULO,
    A.OPBEL AS DOC_IMPRESSAO,
    C.BELEGART AS TIPO_CALCULO,
    CASE
        WHEN C.ZZORIGDOC <> ' ' THEN C.ZZORIGDOC
        ELSE NULL
    END TIPO_DOCUMENTO,
    CASE
        WHEN A.ERGRD = '04' THEN 'X'
        ELSE NULL
    END ESTORNO,
    CASE
        WHEN A.BUDAT <> '00000000' THEN SUBSTR(A.BUDAT, 0, 6)
        ELSE NULL
    END MES_COMPETENCIA
FROM
    {{ ref ('stg_erdk') }} A
    INNER JOIN {{ ref ('stg_erchc')}} B ON (A.MANDT = B.MANDT)
    AND (B.OPBEL = A.INTOPBEL)
    INNER JOIN {{ ref ('stg_erch')}} C ON (B.MANDT = C.MANDT)
    AND B.BELNR = C.BELNR
WHERE
    A.INVOICED = 'X'
    AND A.ERGRD = '04'
    AND A.ERDAT >= (SELECT ultima_execucao FROM {{ ref('stg_int_ultima_exec') }})
    AND A.ERDAT <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
    --alterado para homologacao
    -- AND A.ERDAT >= (SELECT dia_ini FROM dia_inicial)
    -- AND A.ERDAT <= '{{ var("dia_fim") }}'
    --
    --AND A.OPBEL in ('300082143436')
),

UNIAO AS (
SELECT 
    mandt,
    doc_calculo,
    doc_impressao,
    tipo_calculo,
    tipo_documento,
    TO_VARCHAR(estorno) as estorno,
    mes_competencia
FROM
    calculos
UNION ALL
SELECT 
    mandt,
    doc_calculo,
    doc_impressao,
    tipo_calculo,
    tipo_documento,
    TO_VARCHAR(estorno) as estorno,
    mes_competencia
FROM
    ESTORNOS_PLENOS
)

SELECT
    mandt,
    doc_calculo,
    doc_impressao,
    tipo_calculo,
    tipo_documento,
    estorno,
    mes_competencia
FROM 
    UNIAO