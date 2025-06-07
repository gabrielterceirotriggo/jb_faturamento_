-- depends_on: {{ ref('int_docs_dups_ord_fat') }}

{{
  config(
    materialized='view',
    description='This model serves as a trigger to execute operational macros (atualiza_ordem, vlr_cont_delta) immediately after the int_docs_dups_ord_fat model is built. It exists to break a dependency cycle that would occur if these hooks were placed directly on the parent model. It does not transform data.',
    tags=['operations']
  )
}}

{{
  config(
    post_hook = [
      "{{ atualiza_ordem() }}",
      "{{ vlr_cont_delta() }}"
    ]
  )
}}

/*
  The SELECT statement is trivial and lightweight. Its only purpose is to
  create a valid database object (a view) so that dbt has a node in the
  DAG to which it can attach the post-hooks.
*/
select 1 as operation_status