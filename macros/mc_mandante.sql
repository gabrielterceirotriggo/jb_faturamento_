{%- macro mc_mandante() -%}
    {%- if var('source_param') == 'EQTL_MA' -%}
        '401'
    {%- elif var('source_param') == 'EQTL_PA' -%}
        '402'
    {%- elif var('source_param') == 'EQTL_PI' -%}
        '404'
    {%- elif var('source_param') == 'EQTL_AL' -%}
        '403'
    {%- elif var('source_param') == 'EQTL_AP' -%}
        '405'
    {%- elif var('source_param') == 'EQTL_RS' -%}
        '406'
    {%- elif var('source_param') == 'EQTL_RS_EQZ' -%}
        '506'
    {%- else -%}
        {%- do log("mandante") -%}
    {%- endif -%}
{%- endmacro -%}