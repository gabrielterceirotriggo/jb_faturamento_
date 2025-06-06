{%- macro colunas_faturamento_pial(empresa) -%}
  {%- if empresa == 'EQTL_PI' or empresa == 'EQTL_AL' -%}
    , 
    null as documento_fatura,
    null as data_situacao_fatura,
    null as data_alt_situacao_fatura
  {%- endif -%}
{%- endmacro -%}