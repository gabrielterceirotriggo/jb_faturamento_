WITH int_CALCULO_DELTA AS (
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
	inicio_calculo,
	fim_calculo,
	quantidade_dias,
	documento_estorno_pleno,
	data_estorno_pleno,
	motivo_estorno_pleno,
	documento_estorno_ajuste,
	data_estorno_ajuste,
	motivo_estorno_ajuste,
	valor_fatura,
	valor_contabil,
	chave_reconciliacao,
	formulario_pagamento,
	domicilio_fiscal,
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
	estrutura_regional_politica
FROM
    {{ ref ('int_calculo_delta')}}
),

DBERCHZ2 AS (
SELECT
	mandt,
	belnr,
	belzeile,
	ablbelnr,
	logikzw,
	v_zwstdiff,
	n_zwstdiff,
	data_dados
FROM
    {{ ref('stg_dberchz2')}}
),

DBERCHZ1 AS (
SELECT
	mandt,
	belnr,
	belzeile,
	belzart,
	branche,
	tvorg,
	linesort,
	ab,
	bis,
	tariftyp,
	temp_area,
	v_abrmenge,
	n_abrmenge,
	data_dados
FROM
    {{ ref('stg_dberchz1')}}
),

ETDZ AS (
SELECT
	mandt,
	equnr,
	zwnummer,
	bis,
	ab,
	logikzw,
	spartyp,
	zwkenn,
	kennziff,
	zwart,
	zwfakt,
	stanzvor,
	stanznac,
	zwtyp,
	bliwirk,
	massread,
	anzerg,
	kzmessw,
	ueberver,
	steuergrp,
	nablesen,
	pruefkl,
	temp_area,
	pr_area_ai,
	calor_area,
	hoekorr,
	thgber,
	kzahle,
	kzahlt,
	gas_prs_ar,
	crgpress,
	erdat,
	ernam,
	aedat,
	aenam,
	massbill,
	gewkey,
	zspanns,
	zstroms,
	zspannp,
	zstromp,
	intsizeid,
	touperiod,
	vee_code,
	data_dados
FROM
    {{ ref ('stg_etdz')}}
),

EZUZ AS (
SELECT
    mandt,
	logikzw,
	bis,
	zuart,
	logiknr2,
	ab,
	messdrck,
	abrfakt,
	progt,
	attribut,
	erdat,
	ernam,
	aedat,
	aenam
FROM
    {{ ref ('stg_ezuz')}}
),

EGERH AS (
SELECT
	mandt,
	equnr,
	bis,
	ab,
	kombinat,
	logiknr,
	zwgruppe,
	einbdat,
	ausbdat,
	gerwechs,
	devloc,
	devgrp,
	wgruppe,
	ppm_meter,
	primwnr1,
	sekwnr1,
	primwnr2,
	sekwnr2,
	lossdtgroup,
	rating,
	p_voltage,
	s_voltage,
	ams,
	amcg_cap_grp,
	msg_attr_id,
	cap_act_grp,
	einbzeit,
	ausbzeit,
	zeitzone,
	data_dados
FROM
    {{ ref ('stg_egerh')}}
),

TE835T AS (
SELECT
	mandt,
	spras,
	belzart,
	text30,
	data_dados
FROM
    {{ ref('stg_te835t')}}
),

Q1_0 AS (
SELECT
    db2.mandt,
    tcd.mes_competencia,
    tcd.documento_calculo,
    tcd.documento_impressao,
	--não tinha na tabela
	db2.logikzw,
    db1.bis,
    db1.belzart,
    db1.v_abrmenge,
    db1.n_abrmenge,
    --não tinha na tabela
	db2.v_zwstdiff,
	db2.n_zwstdiff,
	db2.ablbelnr as id_leitura,
	tcd.estorno_ajuste,
	tcd.estorno_pleno,
	tcd.cnr
FROM 
    int_calculo_delta tcd
LEFT OUTER JOIN 
    dberchz2 db2
ON 
    db2.mandt IN (401, 402, 403, 404) 
    AND db2.belnr = TCD.documento_calculo
    AND db2.ablbelnr <> ' '
LEFT OUTER JOIN 
    dberchz1 db1
ON 
    db2.mandt = db1.mandt
    AND db2.belnr = db1.belnr
    AND db2.belzeile = db1.belzeile
),

Q1_1 AS (
SELECT
	q1_0.belzart,
	q1_0.bis,
	q1_0.cnr,
	etdz.zwfakt AS constante_medidor,
	q1_0.documento_calculo,
	q1_0.documento_impressao,
	q1_0.estorno_ajuste,
	q1_0.estorno_pleno,
	q1_0.id_leitura,
	q1_0.logikzw,
	q1_0.mandt,
	q1_0.mes_competencia,
	q1_0.n_abrmenge,
	q1_0.n_zwstdiff,
	q1_0.v_abrmenge,
	q1_0.v_zwstdiff
FROM
	q1_0
LEFT OUTER JOIN 
	etdz
ON
	q1_0.mandt = etdz.mandt
	AND q1_0.logikzw = etdz.logikzw
	AND q1_0.bis >= etdz.ab
	AND q1_0.bis <= etdz.bis
WHERE
	etdz.massread = 'KWH'
	AND q1_0.mandt IN (401, 402, 403, 404)
),

Q1_2 AS (
SELECT
	q1_1.mandt,
	q1_1.mes_competencia,
	q1_1.documento_calculo,
	q1_1.documento_impressao,
	q1_1.belzart,
	q1_1.constante_medidor,
	q1_1.v_abrmenge,
	q1_1.n_abrmenge,
	q1_1.v_zwstdiff,
	q1_1.n_zwstdiff,
	q1_1.id_leitura,
	ezuz.abrfakt AS fator_calculo,
	q1_1.bis,
	ezuz.logiknr2,
	q1_1.estorno_ajuste,
	q1_1.estorno_pleno,
	q1_1.cnr
FROM
	q1_1
LEFT OUTER JOIN
	ezuz
ON
	q1_1.mandt = ezuz.mandt
	AND q1_1.logikzw = ezuz.logikzw
	AND q1_1.bis >= ezuz.ab
	AND q1_1.bis <= ezuz.bis
),

Q1_3 AS (
SELECT
	q1_2.mandt,
	q1_2.mes_competencia,
	q1_2.documento_calculo,
	q1_2.documento_impressao,
	q1_2.belzart,
	q1_2.constante_medidor,
	q1_2.v_abrmenge,
	q1_2.n_abrmenge,
	q1_2.v_zwstdiff,
	q1_2.n_zwstdiff,
	q1_2.id_leitura,
	q1_2.fator_calculo,
	q1_2.estorno_ajuste,
	egerh.equnr,
	q1_2.estorno_pleno,
	q1_2.cnr
FROM
	q1_2
LEFT OUTER JOIN
	egerh
ON
	q1_2.mandt = egerh.mandt
	AND q1_2.logiknr2 = egerh.logiknr
	AND q1_2.bis >= egerh.ab
	AND q1_2.bis <= egerh.bis
	AND egerh.kombinat = 'W'
),

Q1_4 AS (
SELECT 
	q1_3.mandt,
	q1_3.mes_competencia,
	q1_3.documento_calculo,
	q1_3.documento_impressao,
	CASE 
		WHEN q1_3.estorno_ajuste = 'X' OR q1_3.cnr = 'X' THEN 
			(q1_3.v_abrmenge + q1_3.n_abrmenge)
		ELSE 
			(q1_3.v_zwstdiff + q1_3.n_zwstdiff) * q1_3.constante_medidor * nvl(q1_3.fator_calculo, 1)
	END consumo_registrado_dberchz2,
	q1_3.fator_calculo,
	q1_3.equnr,
	q1_3.estorno_pleno,
	q1_3.belzart
FROM 
	q1_3
LEFT OUTER JOIN
	te835t
ON
	te835t.spras = 'P'
	AND te835t.mandt IN (401, 402, 403, 404)
	AND (te835t.text30 NOT LIKE '% RV' OR te835t.belzart = 'ZRCARY')
	AND te835t.text30 NOT LIKE '%Gerado'
	AND te835t.text30 NOT LIKE '%Reativo Exced'
),

"CASE" AS (
SELECT
	q1_4.mandt,
	q1_4.mes_competencia,
	q1_4.documento_calculo,
	q1_4.documento_impressao,
	CASE 
		WHEN SUM(CASE WHEN q1_4.belzart IN ('ZRCAT') THEN q1_4.consumo_registrado_dberchz2 ELSE 0 END) <> 0 THEN 
			SUM(CASE WHEN q1_4.belzart IN ('ZRCAT') THEN q1_4.consumo_registrado_dberchz2 ELSE 0 END)
		ELSE 
			SUM(CASE WHEN q1_4.belzart IN ('ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV') THEN q1_4.consumo_registrado_dberchz2 ELSE 0 END)
	END consumo_registrado_dberchz2,
	q1_4.fator_calculo,
	q1_4.equnr,
	q1_4.estorno_pleno
FROM
	q1_4
GROUP BY
	q1_4.mandt,
	q1_4.mes_competencia,
	q1_4.documento_calculo,
	q1_4.documento_impressao,
	q1_4.fator_calculo,
	q1_4.equnr,
	q1_4.estorno_pleno
),

Q2 AS (
SELECT
	mandt,
	mes_competencia,
	documento_calculo,
	documento_impressao,
	consumo_registrado_dberchz2,
	estorno_pleno
FROM
	"CASE"
WHERE 
	(fator_calculo IS NULL AND equnr IS NULL)
	OR
	(fator_calculo IS NOT NULL AND equnr IS NOT NULL)
)

SELECT 
	q2.mes_competencia,
	q2.documento_calculo,
	q2.documento_impressao,
	CASE 
		WHEN 
			q2.estorno_pleno = 'X'
			THEN 
				q2.consumo_registrado_dberchz2 * -1
			ELSE
				q2.consumo_registrado_dberchz2
	END consumo_registrado
FROM 
	q2
GROUP BY 
	q2.mes_competencia,
	q2.documento_calculo,
	q2.documento_impressao,
	q2.consumo_registrado_dberchz2,
	q2.estorno_pleno