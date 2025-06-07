{% macro select_itens() %}
  select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart,
        linesort,
        escalao,
        inicio_calculo,
        fim_calculo,
        tipo_imposto,
        consumo,
        preco,
        receita,
        base_imposto,
        aliquota,
        operacao,
        sub_operacao,
        domicilio_fiscal
    from
{% endmacro %}