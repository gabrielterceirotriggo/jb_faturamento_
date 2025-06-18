{%- macro mc_mandante(source_param) -%}
    {%- if source_param == 'EQTL_MA' -%}
        '401'
    {%- elif source_param == 'EQTL_PA' -%}
        '402'
    {%- elif source_param == 'EQTL_PI' -%}
        '404'
    {%- elif source_param == 'EQTL_AL' -%}
        '403'
    {%- elif source_param == 'EQTL_RS' -%}
        '450'
    {%- elif source_param == 'EQTL_AP' -%}
        '405'
    {%- else -%}
        {%- do log("Compania inválida para source_param: " ~ source_param) -%}
    {%- endif -%}
{%- endmacro -%}