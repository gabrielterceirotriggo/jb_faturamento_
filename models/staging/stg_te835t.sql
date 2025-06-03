SELECT
	mandt,
	spras,
	belzart,
	text30,
	data_dados
FROM
    {{ mc_source(var('source_param'),'TE835T')}}
