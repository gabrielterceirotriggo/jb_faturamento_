SELECT
    mandt,
	ablbelnr,
	anlage,
	adat,
	aplicacao,
	parcelas,
	fat_compl,
	ernam,
	erdat,
	tipo_devol,
	fat_aberta,
	data_dados    
FROM
    {{ mc_source(var('source_param'),'ZCFAT_IRREG_CAB')}}
