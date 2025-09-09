{% macro roda_merge(tabela) %}
    {% set commands %}
        CALL {{var('database_raw')}}.{{var('source_orig')}}.PRC_{{tabela}}_DELTA({{get_days_since()}});
    {% endset %}

    {% do run_query(commands) %}

    {{ log("Procedure PRC_" ~ tabela ~ "_DELTA rodou com sucesso para " ~ get_days_since() ~ " dias", info=True) }}
{% endmacro %}