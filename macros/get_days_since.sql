{% macro get_days_since() %}

    {% set date_query %}
        SELECT ultima_execucao
        FROM {{ ref('stg_int_ultima_exec_fat') }}
    {% endset %}

    {% set query_result = run_query(date_query) %}

    {% if execute and query_result %}
        {% set date_string = query_result.rows[0][0] %}
        {% set start_date = modules.datetime.datetime.strptime(date_string, '%Y%m%d').date() %}
        {% set today_date = modules.datetime.date.today() %}
        
        {# This correctly calculates the days as an integer #}
        {% set days = (today_date - start_date).days %}

        {# Use the most robust method for addition #}
        {% set final_days = (days | int) + 1 %}

        {{ return(final_days) }}

    {% else %}
        {# Return a default for parsing #}
        {{ return(1) }}
    {% endif %}

{% endmacro %}