{%- macro colunas_faturamento_pial(empresa) -%}
  {%- if empresa == 'eqtl_pi' or empresa == 'eqtl_al' or empresa == 'eqtl_ap' -%}
    , 
    null as documento_fatura,
    null as data_situacao_fatura,
    null as data_alt_situacao_fatura
  {%- endif -%}
{%- endmacro -%}