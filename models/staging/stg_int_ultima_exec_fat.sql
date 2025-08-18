{# select TO_CHAR(ultima_carga, 'YYYYMMDD') as ultima_execucao
from
    {{ source('PROD','TAB_CONTROLE_CARGAS') }}
where tabela = 'FATURAMENTO' #}

select '20250701' as ultima_execucao