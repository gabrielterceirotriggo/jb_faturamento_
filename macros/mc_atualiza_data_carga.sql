{% macro atualiza_data_carga() %}
    {% set commands %}
        UPDATE {{ source('PROD', 'TAB_CONTROLE_CARGAS') }}
        SET ULTIMA_CARGA = CURRENT_TIMESTAMP()
        WHERE TABELA = 'FATURAMENTO';
    {% endset %}

    {% do run_query(commands) %}

    {{ log("Macro atualiza_data_carga rodou com sucesso", info=True) }}
{% endmacro %}