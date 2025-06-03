SELECT
	documento_calculo,
	id_leitura
FROM
    {{ ref('rel_faturamento_leitura_delta')}}

