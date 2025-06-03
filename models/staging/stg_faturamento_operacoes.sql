SELECT
	mandt,
	operacao,
	sub_operacao,
	bloco
FROM
    {{ mc_source_eqtl(var('source_param'),'FATURAMENTO_OPERACOES')}}
    