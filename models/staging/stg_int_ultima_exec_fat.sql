select ultima_carga
from
    {{ source('PROD','TAB_CONTROLE_CARGAS') }}
where tabela = 'FATURAMENTO'
