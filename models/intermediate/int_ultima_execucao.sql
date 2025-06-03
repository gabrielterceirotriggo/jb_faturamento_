with int_ultima_exec as (
    select TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') as ultima_execucao
    from
        {{ ref('faturamento') }}
    limit 1
)

select ultima_execucao from int_ultima_exec
