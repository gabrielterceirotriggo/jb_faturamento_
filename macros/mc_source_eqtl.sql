{% macro mc_source_eqtl(source_param, table_name) %}
    {% if source_param == 'EQTL_MA' %}
        {{ source('EQTL_MA', table_name) }}
    {% elif source_param == 'EQTL_PA' %}
        {{ source('EQTL_PA', table_name) }}
    {% elif source_param == 'EQTL_PI' %}
        {{ source('EQTL_PI', table_name) }}
    {% elif source_param == 'EQTL_AL' %}
        {{ source('EQTL_AL', table_name) }}
    {% elif source_param == 'EQTL_AP' %}
        {{ source('EQTL_AP', table_name) }}
    {% else %}
        {% do log("Destino inválido para source_param: " ~ source_param) %}
    {% endif %}
{% endmacro %}