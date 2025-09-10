{{
  config(
    materialized = 'incremental',
    incremental_strategy= 'merge_insert_only',
    unique_key = ['documento_calculo', 'id_leitura'],
    )
}}
select
    documento_calculo,
    id_leitura,
    current_timestamp() as data_dados
from
    {{ ref('rel_faturamento_leitura_delta') }}
