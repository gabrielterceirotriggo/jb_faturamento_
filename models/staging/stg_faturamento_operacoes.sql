select
    mandt,
    operacao,
    sub_operacao,
    bloco
from
    {{ source('PROD','FATURAMENTO_OPERACOES') }}
