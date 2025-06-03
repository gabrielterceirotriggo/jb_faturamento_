WITH int_precalc_delta AS (
    SELECT
        mes_competencia,
        "period" as mes_referencia,
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
        estorno_pleno,
        estorno_ajuste,
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        documento_estorno_pleno,
        data_estorno_pleno,
        motivo_estorno_pleno,
        documento_estorno_ajuste,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
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
        estrutura_regional_politica,
    FROM
        {{ ref ('int_precalc_delta')}}
),

ETTIFN AS (
    SELECT
        mandt,
        anlage,
        operand,
        saison,
        ab,
        ablfdnr,
        bis,
        belnr,
        mbelnr,
        mauszug,
        altbis,
        inaktiv,
        manaend,
        tarifart,
        kondigr,
        wert1,
        wert2,
        string1,
        string2,
        string3,
        string4,
        ersatzwert,
        betrag,
        waers
    FROM
        {{ ref ('stg_ettifn')}}
)
SELECT
    int_precalc_delta.mes_competencia,
    int_precalc_delta.mes_referencia,
    int_precalc_delta.documento_calculo,
    int_precalc_delta.documento_impressao,
    int_precalc_delta.fatura,
    int_precalc_delta.instalacao,
    int_precalc_delta.conta_contrato,
    int_precalc_delta.parceiro_negocio,
    int_precalc_delta.contrato,
    int_precalc_delta.unidade_leitura,
    int_precalc_delta.etapa,
    int_precalc_delta.motivo_criacao_impressao,
    int_precalc_delta.tipo_impressao,
    int_precalc_delta.tipo_calculo,
    int_precalc_delta.origem_documento,
    int_precalc_delta.cnr,
    NULL AS estornado,
    int_precalc_delta.estorno_pleno,
    int_precalc_delta.estorno_ajuste,
    NULL AS reversao,
    CASE 
        WHEN ETTIFN.anlage IS NOT NULL AND int_precalc_delta.estorno_ajuste = 'X' THEN 'X'
        ELSE NULL
    END AS cancelamento,
    int_precalc_delta.fatura_virtual,
    int_precalc_delta.minimo,
    int_precalc_delta.inicio_calculo,
    int_precalc_delta.fim_calculo,
    DATEDIFF('DAY', int_precalc_delta.inicio_calculo, int_precalc_delta.fim_calculo) + 1 AS quantidade_dias,
    CASE 
        WHEN int_precalc_delta.documento_estorno_pleno <> ' ' THEN
            int_precalc_delta.documento_estorno_pleno
        ELSE 
            NULL
    END AS documento_estorno_pleno,
    int_precalc_delta.data_estorno_pleno,
    CASE 
        WHEN int_precalc_delta.motivo_estorno_pleno = ' ' THEN
            NULL
        ELSE 
            int_precalc_delta.motivo_estorno_pleno
    END AS motivo_estorno_pleno,
    CASE 
        WHEN int_precalc_delta.documento_estorno_ajuste <> ' ' THEN
            int_precalc_delta.documento_estorno_ajuste
        ELSE 
            NULL
    END AS documento_estorno_ajuste,
    int_precalc_delta.data_estorno_ajuste,
    int_precalc_delta.motivo_estorno_ajuste,
    int_precalc_delta.valor_fatura,
    int_precalc_delta.valor_fatura AS valor_contabil,
    int_precalc_delta.chave_reconciliacao,
    CASE 
        WHEN int_precalc_delta.formulario_pagamento <> ' ' THEN
            int_precalc_delta.formulario_pagamento
        ELSE 
            NULL
    END AS formulario_pagamento,
    int_precalc_delta.domicilio_fiscal,
    int_precalc_delta.data_competencia,
    int_precalc_delta.data_atribuicao_calculo,
    int_precalc_delta.data_apresentacao,
    int_precalc_delta.data_vencimento_original,
    int_precalc_delta.data_previsao_leitura,
    int_precalc_delta.data_criacao_impressao,
    int_precalc_delta.usuario_criacao_impressao,
    int_precalc_delta.data_modificacao_impressao,
    int_precalc_delta.usuario_modificacao_impressao,
    int_precalc_delta.data_criacao_calculo,
    int_precalc_delta.usuario_criacao_calculo,
    int_precalc_delta.data_modificacao_calculo,
    int_precalc_delta.usuario_modificacao_calculo,
    int_precalc_delta.documento_calculo_anterior,
    int_precalc_delta.estrutura_regional_politica
FROM 
    int_precalc_delta
LEFT OUTER JOIN 
    ETTIFN
    ON ETTIFN.MANDT IN (401)
    AND ETTIFN.ANLAGE = int_precalc_delta.INSTALACAO
    AND ETTIFN.OPERAND = 'FL_SEM_NF'
    AND ETTIFN.AB <= TO_CHAR(int_precalc_delta.fim_calculo, 'YYYYMMDD')
    AND ETTIFN.BIS >= TO_CHAR(int_precalc_delta.fim_calculo, 'YYYYMMDD')
