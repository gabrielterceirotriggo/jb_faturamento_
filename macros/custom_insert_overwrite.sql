{% macro get_incremental_custom_insert_overwrite_sql(arg_dict) %}

  {% do return(macro_custom_insert_overwrite(arg_dict["target_relation"], arg_dict["temp_relation"], arg_dict["unique_key"], arg_dict["dest_columns"], arg_dict["incremental_predicates"])) %}

{% endmacro %}


{% macro macro_custom_insert_overwrite(target_relation, temp_relation, unique_key, dest_columns, incremental_predicates) %}

    {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute="name")) -%}

    insert overwrite into {{ target_relation }} ({{ dest_cols_csv }})
    (
        select {{ dest_cols_csv }}
        from {{ temp_relation }}
    );

    {{ log('Tabela '~ target_relation ~' atualizada utilizando a estratégia insert overwrite', info=True) }}
{% endmacro %}