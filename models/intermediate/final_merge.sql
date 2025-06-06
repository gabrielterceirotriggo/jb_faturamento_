--depends_on: {{ ref('int_docs_dups_ord_fat') }}
{{
  config(
    post_hook = ["{{atualiza_ordem()}}","{{vlr_cont_delta()}}"],
    )
}}

select 1 as done