SELECT 
    MAX(mes_competencia) AS max_mes
FROM 
    {{ ref('itens_faturamento_delta') }}