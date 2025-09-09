{% macro roda_merge(tabela) %}
    {% set commands %}
        CALL {{var('database_raw')}}.{{var('source_orig')}}.PRC_{{tabela}}_DELTA({{get_days_since()}});
    {% endset %}

    {% if var('source_param') == 'EQTL_MA' or var('source_param') == 'EQTL_PA' or var('source_param') == 'EQTL_PI' or var('source_param') == 'EQTL_AL' %}
        {% do run_query(commands) %}
        {{ log("Procedure PRC_" ~ tabela ~ "_DELTA rodou com sucesso para " ~ get_days_since() ~ " dias", info=True) }}
    {% else %}
        {{ log("Não há procedure para esta empresa.", info=True) }}
    {% endif %}
{% endmacro %}