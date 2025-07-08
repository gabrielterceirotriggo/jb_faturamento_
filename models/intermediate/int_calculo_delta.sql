with precalc_delta as (
    select
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
        estorno_pleno,
        estorno_ajuste,
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        documento_estorno_pleno as raw_documento_estorno_pleno,
        data_estorno_pleno,
        motivo_estorno_pleno as raw_motivo_estorno_pleno,
        documento_estorno_ajuste as raw_documento_estorno_ajuste,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        chave_reconciliacao,
        formulario_pagamento as raw_formulario_pagamento,
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
        ab,
        bis
    from
        {{ ref ('stg_ettifn_fat') }}
),

enriquecimento_dados_precalc as (
    select
        pd.mes_competencia,
        pd.mes_referencia,
        pd.documento_calculo,
        pd.documento_impressao,
        pd.fatura,
        pd.instalacao,
        pd.conta_contrato,
        pd.parceiro_negocio,
        pd.contrato,
        pd.unidade_leitura,
        pd.etapa,
        pd.motivo_criacao_impressao,
        pd.tipo_impressao,
        pd.tipo_calculo,
        pd.origem_documento,
        pd.cnr,
        pd.estorno_pleno,
        pd.estorno_ajuste,
        pd.fatura_virtual,
        pd.minimo,
        pd.inicio_calculo,
        pd.fim_calculo,
        pd.raw_documento_estorno_pleno,
        pd.data_estorno_pleno,
        pd.raw_motivo_estorno_pleno,
        pd.raw_documento_estorno_ajuste,
        pd.data_estorno_ajuste,
        pd.motivo_estorno_ajuste,
        pd.valor_fatura,
        pd.chave_reconciliacao,
        pd.raw_formulario_pagamento,
        pd.domicilio_fiscal,
        pd.data_competencia,
        pd.data_atribuicao_calculo,
        pd.data_apresentacao,
        pd.data_vencimento_original,
        pd.data_previsao_leitura,
        pd.data_criacao_impressao,
        pd.usuario_criacao_impressao,
        pd.data_modificacao_impressao,
        pd.usuario_modificacao_impressao,
        pd.data_criacao_calculo,
        pd.usuario_criacao_calculo,
        pd.data_modificacao_calculo,
        pd.usuario_modificacao_calculo,
        pd.documento_calculo_anterior,
        pd.estrutura_regional_politica,
        e.anlage as ettifn_anlage
    from
        precalc_delta as pd
    left outer join
        ettifn as e
        on
            e.mandt = {{ mc_mandante(var('source_param')) }}
            and pd.instalacao = e.anlage
            and e.operand = 'FL_SEM_NF'
            and e.ab <= TO_CHAR(pd.fim_calculo, 'YYYYMMDD')
            and e.bis >= TO_CHAR(pd.fim_calculo, 'YYYYMMDD')
),

transformacoes_calculadas as (
    select distinct
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
        null as estornado,
        estorno_pleno,
        estorno_ajuste,
        null as reversao,
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        data_estorno_pleno,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        valor_fatura as valor_contabil,
        chave_reconciliacao,
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
        case
            when
                ettifn_anlage is not null and estorno_ajuste = 'X'
                then 'X'
        end as cancelamento,
        DATEDIFF(
            'DAY', inicio_calculo, fim_calculo
        )
        + 1 as quantidade_dias,
        case
            when raw_documento_estorno_pleno <> ' '
                then
                    raw_documento_estorno_pleno
        end as documento_estorno_pleno,
        case
            when raw_motivo_estorno_pleno = ' '
                then
                    null
            else
                raw_motivo_estorno_pleno
        end as motivo_estorno_pleno,
        case
            when raw_documento_estorno_ajuste <> ' '
                then
                    raw_documento_estorno_ajuste
        end as documento_estorno_ajuste,
        case
            when raw_formulario_pagamento <> ' '
                then
                    raw_formulario_pagamento
        end as formulario_pagamento
    from
        enriquecimento_dados_precalc
),

final as (
    select
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
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        data_estorno_pleno,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        valor_contabil,
        chave_reconciliacao,
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
        cancelamento,
        quantidade_dias,
        documento_estorno_pleno,
        motivo_estorno_pleno,
        documento_estorno_ajuste,
        formulario_pagamento
    from
        transformacoes_calculadas
)

select * from final
