{{
  config(
    materialized = 'incremental',
    incrementa_strategy= 'delete+insert',
    unique_key = ['documento_calculo', 'id_leitura'],
    )
}}
select
    documento_calculo,
    id_leitura
from
    {{ ref('rel_faturamento_leitura_delta') }}
