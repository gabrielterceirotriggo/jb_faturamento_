with
-- dia_inicial AS (
--     SELECT 
--         --REPLACE(ULTIMA_CARGA, '-', ' ') AS dia_ini
--         '20250214' AS dia_ini
--     FROM 
--         {{ ('stg_tab_controle_cargas') }}
--     WHERE 
--         tabela = 'FATURAMENTO'
-- ),

ccs_std_equatorial as (
    select
        a.mandt,
        a.opbel as documento_impressao,
        a.erdat as data_criacao,
        a.creation_time as hora_criacao,
        a.aedat as data_modificacao,
        a.ergrd as motivo_criacao,
        a.ableinh as unidade_leitura,
        a.regpolit as estrutura_regional_politica,
        a.ernam as usuario_criacao,
        a.aenam as usuario_modificacao,
        a.budat as data_competencia,
        a.faedn as data_vencimento,
        a.total_amnt as valor_total,
        a.partner as parceiro_negocio,
        a.vkont as conta_contrato,
        a.exbel as fatura,
        a.billing_period as mes_referencia,
        a.fikey as chave_reconciliacao,
        a.stokz,
        a.intopbel,
        a.icreason as motivo_estorno_impressao,
        a.nrzas as formulario_pagamento,
        a.zzdataapr as data_apresentacao,
        a.ztipo as tipo_impressao
    from {{ ref ('stg_erdk') }} as a
    where
        a.mandt = {{ mc_mandante(var('source_param')) }}
        and a.erdat
        >= (select ultima_execucao from {{ ref('stg_int_ultima_exec') }})
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        and a.invoiced = 'X'
)

select
    ccs_std_equatorial.mandt,
    ccs_std_equatorial.documento_impressao,
    ccs_std_equatorial.motivo_criacao as motivo_criacao_impressao,
    ccs_std_equatorial.usuario_criacao,
    ccs_std_equatorial.conta_contrato,
    ccs_std_equatorial.data_criacao,
    ccs_std_equatorial.hora_criacao,
    ccs_std_equatorial.parceiro_negocio,
    ccs_std_equatorial.valor_total,
    ccs_std_equatorial.chave_reconciliacao,
    case
        when ccs_std_equatorial.fatura <> ' '
            then
                ccs_std_equatorial.fatura
    end as fatura,
    case
        when ccs_std_equatorial.tipo_impressao <> ' '
            then
                ccs_std_equatorial.tipo_impressao
    end as tipo_impressao,
    case
        when ccs_std_equatorial.data_criacao <> '00000000'
            then
                TO_DATE(
                    ccs_std_equatorial.data_criacao
                    || ' '
                    || ccs_std_equatorial.hora_criacao,
                    'YYYYMMDD HH24MISS'
                )
    end as data_criacao_impressao,
    case
        when ccs_std_equatorial.data_modificacao <> '00000000'
            then
                TO_DATE(
                    ccs_std_equatorial.data_modificacao
                    || ' '
                    || ccs_std_equatorial.hora_criacao,
                    'YYYYMMDD HH24MISS'
                )
    end as data_modificacao_impressao,
    case
        when ccs_std_equatorial.usuario_modificacao <> ' '
            then
                ccs_std_equatorial.usuario_modificacao
    end as usuario_modificacao,
    case
        when ccs_std_equatorial.data_competencia <> '00000000'
            then
                TO_DATE(ccs_std_equatorial.data_competencia, 'YYYYMMDD')
    end as data_competencia,
    case
        when ccs_std_equatorial.data_vencimento <> '00000000'
            then
                TO_DATE(ccs_std_equatorial.data_vencimento, 'YYYYMMDD')
    end as data_vencimento_original,
    case
        when ccs_std_equatorial.data_apresentacao <> '00000000'
            then
                TO_DATE(ccs_std_equatorial.data_apresentacao, 'YYYYMMDD')
    end as data_apresentacao,
    case
        when ccs_std_equatorial.intopbel <> ' '
            then
                ccs_std_equatorial.intopbel
    end as contrapartida,
    case
        when ccs_std_equatorial.motivo_estorno_impressao <> ' '
            then
                ccs_std_equatorial.motivo_estorno_impressao
    end as motivo_estorno_impressao,
    case
        when ccs_std_equatorial.formulario_pagamento <> ' '
            then
                ccs_std_equatorial.formulario_pagamento
    end as formulario_pagamento,
    case
        when ccs_std_equatorial.estrutura_regional_politica <> ' '
            then
                ccs_std_equatorial.estrutura_regional_politica
    end as estrutura_regional_politica,
    case
        when ccs_std_equatorial.unidade_leitura <> ' '
            then
                ccs_std_equatorial.unidade_leitura
    end as unidade_leitura,
    case
        when ccs_std_equatorial.motivo_criacao = '04'
            then
                'X'
    end as estorno_pleno,
    case
        when ccs_std_equatorial.tipo_impressao = 'FV'
            then
                'X'
    end as fatura_virtual
from
    ccs_std_equatorial
