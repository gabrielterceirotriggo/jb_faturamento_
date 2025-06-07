with itens_consumo as (
    {{ select_itens() }} {{ ref('int_itens_consumo') }}
),

itens_receita as (
    {{ select_itens() }} {{ ref('int_itens_receita') }}
),

itens_medidos as (
    {{ select_itens() }}  {{ ref('int_itens_medidos') }}
),

itens_extras as (
    {{ select_itens() }}  {{ ref('int_itens_extras') }}
),

itens_extras_receita as (
    {{ select_itens() }}  {{ ref('int_itens_extras_receita') }}
),

itens_unificados as (
    select
        left(mes_competencia, 6) as mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile as linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart as item_documento,
        linesort as item_ordenacao,
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
        domicilio_fiscal,
        'C' as flag
    from
        itens_consumo
    union all
    select
        left(mes_competencia, 6) as mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile as linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart as item_documento,
        linesort as item_ordenacao,
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
        domicilio_fiscal,
        'R' as flag
    from
        itens_receita
    union all
    select
        left(mes_competencia, 6) as mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile as linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart as item_documento,
        linesort as item_ordenacao,
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
        domicilio_fiscal,
        'M' as flag
    from
        itens_medidos
    union all
    select
        left(mes_competencia, 6) as mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile as linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart as item_documento,
        linesort as item_ordenacao,
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
        domicilio_fiscal,
        case
            when
                belzart in (
                    'ZDR1', 'ZDR2', 'ZDR3', 'ZDR4', 'ZDR5', 'ZDR6',
                    'ZUR1', 'ZUR2', 'ZUR3', 'ZEUSD', 'ZEUSDB', 'ZRAMAL'
                )
                then 'D'
            else 'E'
        end as flag
    from
        itens_extras
    union all
    select
        left(mes_competencia, 6) as mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile as linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart as item_documento,
        linesort as item_ordenacao,
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
        domicilio_fiscal,
        'D' as flag
    from
        itens_extras_receita
),

final as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        item_documento,
        item_ordenacao,
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
        domicilio_fiscal,
        flag
    from
        itens_unificados
)

select * from final
