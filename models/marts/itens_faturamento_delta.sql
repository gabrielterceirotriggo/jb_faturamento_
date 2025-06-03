with int_itens_consumo as (
    select
        tic.mes_competencia,
        tic.documento_calculo,
        tic.documento_impressao,
        tic.tipo_calculo,
        tic.tipo_documento,
        tic.belzeile as linha,
        tic.setor_industrial,
        tic.categoria_tarifa,
        tic.subclasse,
        tic.belzart as item_documento,
        tic.linesort as item_ordenacao,
        tic.escalao,
        tic.inicio_calculo,
        tic.fim_calculo,
        tic.tipo_imposto,
        tic.consumo,
        tic.preco,
        -- Não tinha na tabela
        tic.receita,
        tic.base_imposto,
        tic.aliquota,
        tic.operacao,
        tic.sub_operacao,
        tic.domicilio_fiscal,
        tic.estorno,
        'C' as flag
    from
        {{ ref ('int_itens_consumo') }} as tic
),

itens_receita as (
    select
        mes_competencia,
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
        {{ ref ('int_itens_receita') }}
),

itens_medidos as (
    select
        mes_competencia,
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
        {{ ref ('int_itens_medidos') }}
),

itens_extras as (
    select
        mes_competencia,
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
                    'ZDR1',
                    'ZDR2',
                    'ZDR3',
                    'ZDR4',
                    'ZDR5',
                    'ZDR6',
                    'ZUR1',
                    'ZUR2',
                    'ZUR3',
                    'ZEUSD',
                    'ZEUSDB',
                    'ZRAMAL'
                )
                then 'D'
            else 'E'
        end as flag
    from
        {{ ref ('int_itens_extras') }}
),

itens_extras_receita as (
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
        {{ ref ('int_itens_extras_receita') }}
),

uniao as (
    select
        LEFT(mes_competencia, 6) as mes_competencia,
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
    from int_itens_consumo
    union all
    select
        LEFT(mes_competencia, 6) as mes_competencia,
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
    from itens_receita
    union all
    select
        LEFT(mes_competencia, 6) as mes_competencia,
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
    from itens_medidos
    union all
    select
        LEFT(mes_competencia, 6) as mes_competencia,
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
    from itens_extras
    union all
    select
        LEFT(mes_competencia, 6) as mes_competencia,
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
    from itens_extras_receita
)

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
    uniao
