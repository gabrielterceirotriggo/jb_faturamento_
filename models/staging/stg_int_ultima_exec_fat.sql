select ultima_carga as ultima_execucao
from
    {{ source('PROD','TAB_CONTROLE_CARGAS') }}
where tabela = 'FATURAMENTO'
