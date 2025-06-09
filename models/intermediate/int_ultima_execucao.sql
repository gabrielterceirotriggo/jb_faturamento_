--depends_on: {{ ref('int_docs_dups_ord_fat') }}
{{
  config(
    pre_hook = [
      "{{ atualiza_ordem() }}",
      "{{ vlr_cont_delta() }}"
    ]
  )
}}

with obter_data_execucao as (
    select to_char(current_date(), 'YYYYMMDD') as ultima_execucao
),

final as (
    select ultima_execucao
    from obter_data_execucao
)

select * from final
