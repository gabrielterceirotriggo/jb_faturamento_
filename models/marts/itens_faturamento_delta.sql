with int_itens_consumo as (
    SELECT    
        tic.mes_competencia,
        tic.documento_calculo,
        tic.documento_impressao,
        tic.tipo_calculo,
        tic.tipo_documento,
        tic.belzeile AS linha,
        tic.setor_industrial,
        tic.categoria_tarifa,
        tic.subclasse,
        tic.belzart AS item_documento,
        tic.linesort AS item_ordenacao,
        tic.escalao,
        tic.inicio_calculo,
        tic.fim_calculo,
        tic.tipo_imposto,
        tic.CONSUMO,
        tic.preco,
        -- Não tinha na tabela
        tic.RECEITA,
        tic.base_imposto,
        tic.ALIQUOTA,
        tic.operacao,
        tic.SUB_OPERACAO,
        tic.domicilio_fiscal,
        tic.estorno,
        'C' AS flag
    FROM
        {{ ref ('int_itens_consumo')}} tic
),

itens_receita as (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    belzeile AS linha,
    setor_industrial,
    categoria_tarifa,
    subclasse,
    belzart AS item_documento,
    linesort AS item_ordenacao,
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
FROM
    {{ ref ('int_itens_receita')}}
),

itens_medidos as (
SELECT
	mes_competencia,
    documento_calculo,
    documento_impressao,
    belzeile AS linha,
    setor_industrial,
    categoria_tarifa,
    subclasse,
    belzart AS item_documento,
    linesort AS item_ordenacao,
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
FROM
    {{ ref ('int_itens_medidos')}}    
),

itens_extras as (
    SELECT
        mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile AS linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart AS item_documento,
        linesort AS item_ordenacao,
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
        CASE
            WHEN belzart IN ('ZDR1', 'ZDR2', 'ZDR3', 'ZDR4', 'ZDR5', 'ZDR6', 'ZUR1', 'ZUR2', 'ZUR3', 'ZEUSD', 'ZEUSDB', 'ZRAMAL') THEN 'D'
        ELSE 'E'
    END AS flag
    FROM
        {{ ref ('int_itens_extras')}}
),

itens_extras_receita as (
SELECT    
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
FROM
    {{ ref ('int_itens_extras_receita')}}
),

uniao AS (
SELECT 
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
FROM int_itens_consumo
UNION ALL
SELECT 
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
FROM itens_receita
UNION ALL
SELECT 
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
FROM itens_medidos
UNION ALL
SELECT 
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
FROM itens_extras
UNION ALL
SELECT 
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
FROM itens_extras_receita
)

SELECT
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
FROM
	uniao