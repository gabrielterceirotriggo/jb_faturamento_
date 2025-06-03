select MAX(mes_competencia) as max_mes
from
    {{ ref('itens_faturamento_delta') }}
