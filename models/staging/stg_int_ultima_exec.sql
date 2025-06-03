SELECT
    ultima_execucao
FROM
    {{ mc_source_eqtl(var('source_param'),'INT_ULTIMA_EXECUCAO')}}
