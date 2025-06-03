with int_precalc_delta as (
    select
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
        estrutura_regional_politica
    from
        {{ ref ('int_precalc_delta') }}
),

ettifn as (
    select
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
    from
        {{ ref ('stg_ettifn') }}
)

select
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
    null as estornado,
    int_precalc_delta.estorno_pleno,
    int_precalc_delta.estorno_ajuste,
    null as reversao,
    int_precalc_delta.fatura_virtual,
    int_precalc_delta.minimo,
    int_precalc_delta.inicio_calculo,
    int_precalc_delta.fim_calculo,
    int_precalc_delta.data_estorno_pleno,
    int_precalc_delta.data_estorno_ajuste,
    int_precalc_delta.motivo_estorno_ajuste,
    int_precalc_delta.valor_fatura,
    int_precalc_delta.valor_fatura as valor_contabil,
    int_precalc_delta.chave_reconciliacao,
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
    int_precalc_delta.estrutura_regional_politica,
    case
        when
            ettifn.anlage is not null and int_precalc_delta.estorno_ajuste = 'X'
            then 'X'
    end as cancelamento,
    DATEDIFF(
        'DAY', int_precalc_delta.inicio_calculo, int_precalc_delta.fim_calculo
    )
    + 1 as quantidade_dias,
    case
        when int_precalc_delta.documento_estorno_pleno <> ' '
            then
                int_precalc_delta.documento_estorno_pleno
    end as documento_estorno_pleno,
    case
        when int_precalc_delta.motivo_estorno_pleno = ' '
            then
                null
        else
            int_precalc_delta.motivo_estorno_pleno
    end as motivo_estorno_pleno,
    case
        when int_precalc_delta.documento_estorno_ajuste <> ' '
            then
                int_precalc_delta.documento_estorno_ajuste
    end as documento_estorno_ajuste,
    case
        when int_precalc_delta.formulario_pagamento <> ' '
            then
                int_precalc_delta.formulario_pagamento
    end as formulario_pagamento
from
    int_precalc_delta
left outer join
    ettifn
    on
        ettifn.mandt in (401)
        and int_precalc_delta.instalacao = ettifn.anlage
        and ettifn.operand = 'FL_SEM_NF'
        and ettifn.ab <= TO_CHAR(int_precalc_delta.fim_calculo, 'YYYYMMDD')
        and ettifn.bis >= TO_CHAR(int_precalc_delta.fim_calculo, 'YYYYMMDD')
