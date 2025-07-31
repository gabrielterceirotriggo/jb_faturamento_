{%- macro mc_mandante() -%}
    {%- if var('source_param') == 'eqtl_ma' -%}
        '401'
    {%- elif var('source_param') == 'eqtl_pa' -%}
        '402'
    {%- elif var('source_param') == 'eqtl_pi' -%}
        '404'
    {%- elif var('source_param') == 'eqtl_al' -%}
        '403'
    {%- elif var('source_param') == 'eqtl_ap' -%}
        '405'
    {%- elif var('source_param') == 'eqtl_rs' -%}
        '406'
    {%- elif var('source_param') == 'eqtl_rs_eqz' -%}
        '406'
    {%- else -%}
        {%- do log("mandante") -%}
    {%- endif -%}
{%- endmacro -%}