select
    documento_calculo,
    id_leitura
from
    {{ ref('rel_faturamento_leitura_delta') }}
