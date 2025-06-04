--depends_on: {{ ref('faturamento') }}

select TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') as ultima_execucao
