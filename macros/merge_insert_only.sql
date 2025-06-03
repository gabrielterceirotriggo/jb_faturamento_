{% macro get_incremental_merge_insert_only_sql(arg_dict) %}

  {% do return(merge_insert_only(arg_dict["target_relation"], arg_dict["temp_relation"], arg_dict["unique_key"], arg_dict["dest_columns"], arg_dict["incremental_predicates"])) %}

{% endmacro %}

{% macro merge_insert_only(target_relation, temp_relation, unique_key, dest_columns, incremental_predicates) %}

    {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute="name")) -%}
    {%- set unique_key_list = unique_key if unique_key is sequence and unique_key is not string else [unique_key] -%}
    {%- set uppercase_unique_key_list = [] -%}
    {%- for key in unique_key_list -%}
        {%- do uppercase_unique_key_list.append(key | upper) -%}
    {%- endfor -%}

    merge into {{ target_relation }} as DBT_INTERNAL_DEST
    using {{ temp_relation }} as DBT_INTERNAL_SOURCE
    on
    {% for key in uppercase_unique_key_list -%}
        DBT_INTERNAL_DEST.{{ adapter.quote(key) }} = DBT_INTERNAL_SOURCE.{{ adapter.quote(key) }}
        {%- if not loop.last %} and {% endif -%}
    {%- endfor %}
    when not matched then insert
        ({{ dest_cols_csv }})
    values
        (
        {% for col in dest_columns -%}
            DBT_INTERNAL_SOURCE.{{ adapter.quote(col.name) }}
            {%- if not loop.last %}, {% endif -%}
        {%- endfor %}
        )
  
{% endmacro %}