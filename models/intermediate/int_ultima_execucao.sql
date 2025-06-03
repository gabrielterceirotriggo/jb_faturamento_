WITH int_ultima_exec AS (
    SELECT 
        TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') AS ultima_execucao
    FROM
        {{ ref('faturamento') }}
    LIMIT 1
)

SELECT ultima_execucao FROM int_ultima_exec