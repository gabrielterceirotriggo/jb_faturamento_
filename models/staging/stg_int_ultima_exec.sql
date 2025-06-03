select ultima_execucao
from
    {{ mc_source_eqtl(var('source_param'),'INT_ULTIMA_EXECUCAO') }}
