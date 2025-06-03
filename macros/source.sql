{% macro mc_source(source_param, table_name) %}
    {% set source_param = var('source_param') %} 

    {% if source_param == 'EQTL_MA' %}
        {{ source('CCS_MA', table_name) }}
    {% elif source_param == 'EQTL_PA' %}
        {{ source('CCS_PA', table_name) }}
    {% elif source_param == 'EQTL_PI' %}
        {{ source('CCS_PI', table_name) }}
    {% elif source_param == 'EQTL_AL' %}
        {{ source('CCS_AL', table_name) }}
    {% else %}
        {% do log("Destino inválido para source_param: " ~ source_param) %}
    {% endif %}
{% endmacro %}