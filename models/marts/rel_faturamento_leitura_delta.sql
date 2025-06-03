
WITH faturamento_delta AS (
SELECT
    mes_competencia,
	mes_referencia,
	documento_calculo,
	documento_impressao,
	fatura,
	instalacao,
	conta_contrato,
	parceiro_negocio,
	contrato,
	unidade_leitura,
	etapa,
	setor_industrial,
	grupo,
	categoria_tarifa,
	cliente_livre,
	subclasse,
	motivo_criacao_impressao,
	tipo_impressao,
	tipo_calculo,
	origem_documento,
	cnr,
	estornado,
	estorno_pleno,
	estorno_ajuste,
	reversao,
	cancelamento,
	fatura_virtual,
	minimo,
	documento_estorno_pleno,
	data_estorno_pleno,
	motivo_estorno_pleno,
	documento_estorno_ajuste,
	data_estorno_ajuste,
	motivo_estorno_ajuste,
	valor_fatura,
	valor_contabil,
	consumo_faturado,
	consumo_medido,
	eusd,
	eusdb,
	icms,
	icms_subvencao,
	pis,
	cofins,
	cip,
	retencao,
	receita_bandeiras,
	receita_consumo_faturado,
	tarifa,
	preco,
	correcao_monetaria,
	creditos,
	estornos,
	juros,
	multas,
	parcelamentos,
	outros_lancamentos,
	chave_reconciliacao,
	formulario_pagamento,
	domicilio_fiscal,
	inicio_calculo,
	fim_calculo,
	quantidade_dias,
	data_competencia,
	data_atribuicao_calculo,
	data_apresentacao,
	data_vencimento_original,
	data_previsao_leitura,
	data_criacao_impressao,
	usuario_criacao_impressao,
	data_modificacao_impressao,
	usuario_modificacao_impressao,
	data_criacao_calculo,
	usuario_criacao_calculo,
	data_modificacao_calculo,
	usuario_modificacao_calculo,
	documento_calculo_anterior,
	estrutura_regional_politica,
	ordem_faturamento
FROM
    {{ ref('faturamento_delta')}}
),

DBERCHZ2 AS (
SELECT
	mandt,
	belnr,
	belzeile,
	equnr,
	geraet,
	matnr,
	zwnummer,
	indexnr,
	ablesgr,
	ablesgrv,
	atim,
	atimva,
	adatmax,
	atimmax,
	thgdatum,
	zuorddat,
	regrelsort,
	ablbelnr,
	logiknr,
	logikzw,
	istablart,
	istablartva,
	extpkz,
	begprog,
	endeprog,
	ablhinw,
	qdproc,
	mrconnect,
	v_zwstand,
	n_zwstand,
	v_zwstndab,
	n_zwstndab,
	v_zwstvor,
	n_zwstvor,
	v_zwstdiff,
	n_zwstdiff,
	data_dados
FROM
    {{ ref ('stg_dberchz2')}}
),

Q_LEITURA_L AS (
SELECT
    faturamento_delta.documento_calculo,
    DBERCHZ2.ablbelnr AS id_leitura
FROM
    faturamento_delta
LEFT OUTER JOIN
    DBERCHZ2
ON
    DBERCHZ2.belnr = faturamento_delta.documento_calculo
WHERE
    DBERCHZ2.mandt IN (401, 402, 403, 404)
)

SELECT
	documento_calculo,
	id_leitura
FROM
	Q_LEITURA_L
WHERE
	Q_LEITURA_L.id_leitura <> ' '

