with erdk as (
    select
        mandt,
        opbel,
        erdat,
        creation_time,
        aedat,
        ergrd,
        ableinh,
        regpolit,
        ernam,
        aenam,
        budat,
        faedn,
        total_amnt,
        partner,
        vkont,
        exbel,
        billing_period,
        fikey,
        invoiced,
        intopbel,
        icreason,
        nrzas,
        zzdataapr,
        ztipo
    from
        {{ ref ('stg_erdk') }}
),

ultima_execucao as (
    select ultima_execucao
    from
        {{ ref('stg_int_ultima_exec') }}
),

documentos_impressao_filtrados as (
    select
        mandt,
        opbel as documento_impressao,
        erdat as data_criacao,
        creation_time as hora_criacao,
        aedat as data_modificacao,
        ergrd as motivo_criacao,
        ableinh as unidade_leitura,
        regpolit as estrutura_regional_politica,
        ernam as usuario_criacao,
        aenam as usuario_modificacao,
        budat as data_competencia,
        faedn as data_vencimento,
        total_amnt as valor_total,
        partner as parceiro_negocio,
        vkont as conta_contrato,
        exbel as fatura,
        billing_period as mes_referencia,
        fikey as chave_reconciliacao,
        intopbel,
        icreason as motivo_estorno_impressao,
        nrzas as formulario_pagamento,
        zzdataapr as data_apresentacao,
        ztipo as tipo_impressao
    from
        erdk
    where
        mandt = {{ mc_mandante(var('source_param')) }}
        and erdat >= (select ultima_execucao from ultima_execucao)
        and erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        and invoiced = 'X'
),

dados_impressao_transformados as (
    select
        mandt,
        documento_impressao,
        motivo_criacao as motivo_criacao_impressao,
        usuario_criacao,
        conta_contrato,
        data_criacao,
        hora_criacao,
        parceiro_negocio,
        valor_total,
        chave_reconciliacao,
        case
            when COALESCE(fatura, ' ') <> ' ' then fatura
        end as fatura,
        case
            when COALESCE(tipo_impressao, ' ') <> ' ' then tipo_impressao
        end as tipo_impressao,
        case
            when data_criacao <> '00000000'
                then
                    TRY_TO_TIMESTAMP(
                        data_criacao || ' ' || hora_criacao, 'YYYYMMDD HH24MISS'
                    )
        end as data_criacao_impressao,
        case
            when data_modificacao <> '00000000'
                then
                    TRY_TO_TIMESTAMP(
                        data_modificacao || ' ' || hora_criacao,
                        'YYYYMMDD HH24MISS'
                    )
        end as data_modificacao_impressao,
        case
            when COALESCE(usuario_modificacao, ' ') <> ' ' then usuario_modificacao
        end as usuario_modificacao,
        case
            when COALESCE(data_competencia, '00000000') <> '00000000'
                then TO_DATE(data_competencia, 'YYYYMMDD')
        end as data_competencia,
        case
            when COALESCE(data_vencimento, '00000000') <> '00000000'
                then TO_DATE(data_vencimento, 'YYYYMMDD')
        end as data_vencimento_original,
        case
            when COALESCE(data_apresentacao, '00000000') <> '00000000'
                then TO_DATE(data_apresentacao, 'YYYYMMDD')
        end as data_apresentacao,
        case
            when COALESCE(intopbel, ' ') <> ' ' then intopbel
        end as contrapartida,
        case
            when COALESCE(motivo_estorno_impressao, ' ') <> ' ' then motivo_estorno_impressao
        end as motivo_estorno_impressao,
        case
            when COALESCE(formulario_pagamento, ' ') <> ' ' then formulario_pagamento
        end as formulario_pagamento,
        case
            when
                COALESCE(estrutura_regional_politica, ' ') <> ' '
                then estrutura_regional_politica
        end as estrutura_regional_politica,
        case
            when COALESCE(unidade_leitura, ' ') <> ' ' then unidade_leitura
        end as unidade_leitura,
        case
            when motivo_criacao = '04' then 'X'
        end as estorno_pleno,
        case
            when tipo_impressao = 'FV' then 'X'
        end as fatura_virtual
    from
        documentos_impressao_filtrados
),

final as (
    select
        mandt,
        documento_impressao,
        motivo_criacao_impressao,
        usuario_criacao,
        conta_contrato,
        data_criacao,
        hora_criacao,
        parceiro_negocio,
        valor_total,
        chave_reconciliacao,
        fatura,
        tipo_impressao,
        data_criacao_impressao,
        data_modificacao_impressao,
        usuario_modificacao,
        data_competencia,
        data_vencimento_original,
        data_apresentacao,
        contrapartida,
        motivo_estorno_impressao,
        formulario_pagamento,
        estrutura_regional_politica,
        unidade_leitura,
        estorno_pleno,
        fatura_virtual
    from
        dados_impressao_transformados
)

select * from final
