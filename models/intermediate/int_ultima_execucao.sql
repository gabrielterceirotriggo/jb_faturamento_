-- depends_on: {{ ref('int_docs_dups_ord_fat') }}

{{
  config(
    pre_hook = [
      "{{ atualiza_ordem() }}",
      "{{ vlr_cont_delta() }}"
    ]
  )
}}

select TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') as ultima_execucao
