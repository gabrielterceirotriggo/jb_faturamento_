select
    mandt,
    operacao,
    sub_operacao,
    bloco
from
    {{ mc_source_eqtl(var('source_param'),'FATURAMENTO_OPERACOES') }}
