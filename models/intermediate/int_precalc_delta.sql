-- WITH dia_inicial AS (
--     SELECT 
--         REPLACE(ULTIMA_CARGA, '-', ' ') AS dia_ini
--     FROM 
--         {{ ('stg_tab_controle_cargas') }}
--     WHERE 
--         tabela = 'FATURAMENTO'
-- ),

with base as (
    select
        /*+ PARALLEL (A,6) ORDERED USE_NL (B) USE_NL(C) USE_NL(D) USE_NL(E) INDEX(ETTIFN-~Z01) */
        a.mandt,
        a.opbel as documento_impressao,
        b.belnr as documento_calculo,
        a.budat as data_competencia,
        c.billing_period,
        a.exbel as fatura,
        d.anlage,
        c.vkont,
        c.gpartner,
        c.vertrag,
        c.ableinh,
        a.ergrd as motivo_criacao_impressao,
        a.ztipo as tipo_impressao,
        c.belegart,
        c.zzorigdoc,
        c.sc_belnr_h,
        c.begabrpe,
        c.endabrpe,
        a.icreason as motivo_estorno_impressao,
        c.sc_belnr_n,
        c.stornodat,
        c.bcreason,
        a.total_amnt as valor_total,
        a.fikey as chave_reconciliacao,
        a.nrzas as formulario_pagamento,
        c.txjcd,
        c.zuorddaa,
        a.zzdataapr as data_apresentacao,
        a.faedn as data_vencimento_original,
        c.adatsoll,
        a.erdat as data_criacao_impressao,
        a.creation_time as hora_criacao,
        a.ernam as usuario_criacao,
        a.aedat as data_modificacao_impressao,
        a.aenam as usuario_modificacao,
        c.eroetim,
        c.erdat,
        c.ernam,
        c.aedat,
        c.aenam,
        c.belnralt,
        a.regpolit as estrutura_regional_politica,
        case
            when a.ergrd = '04'
                then
                    'X'
        end as estorno_pleno,
        case
            when a.ztipo = 'FV'
                then
                    'X'
        end as fatura_virtual,
        case
            when e.belnr is not null
                then
                    'X'
        end as minimo,
        case
            when a.intopbel <> ' '
                then
                    a.intopbel
        end as contrapartida,
        case
            when a.ergrd = '04'
                then
                    a.budat
        end as data_estorno_pleno
    from
        {{ ref('stg_erdk') }} as a
    inner join {{ ref('stg_erchc') }} as b
        on
            a.mandt = b.mandt
            and a.opbel = b.opbel
    inner join {{ ref('stg_erch') }} as c
        on
            b.mandt = c.mandt
            and b.belnr = c.belnr
    left join {{ ref('stg_ever') }} as d
        on
            c.mandt = d.mandt
            and c.vertrag = d.vertrag
    left join {{ ref('stg_ettifn') }} as e
        on
            d.anlage = e.anlage
            and e.operand = 'FL_MINIMO'
            and c.endabrpe = e.bis
            and c.belnr = e.belnr
    where
        --a.mandt in (401, 402, 403, 404)
        --and 
        a.erdat
        >= (select ultima_execucao from {{ ref('stg_int_ultima_exec') }})
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        and a.invoiced = 'X'
--'{{ var("dia_fim") }}'
)

select distinct
    documento_calculo,
    documento_impressao,
    vkont as conta_contrato,
    gpartner as parceiro_negocio,
    vertrag as contrato,
    ableinh as unidade_leitura,
    motivo_criacao_impressao,
    tipo_impressao,
    belegart as tipo_calculo,
    estorno_pleno,
    fatura_virtual,
    minimo,
    contrapartida as documento_estorno_pleno,
    motivo_estorno_impressao as motivo_estorno_pleno,
    valor_total as valor_fatura,
    chave_reconciliacao,
    formulario_pagamento,
    txjcd as domicilio_fiscal,
    SUBSTR(data_competencia, 1, 6) as mes_competencia,
    LEFT(billing_period, 4) || SUBSTR(billing_period, 6, 2) as mes_referencia,
    case
        when fatura <> ' '
            then
                fatura
    end as fatura,
    case
        when anlage <> ' '
            then
                anlage
    end as instalacao,
    SUBSTR(ableinh, 3, 2) as etapa,
    case
        when zzorigdoc <> ' '
            then
                zzorigdoc
    end as origem_documento,
    case
        when zzorigdoc in ('ip', 'rs', 'fr', 'ds', 'cl')
            then
                'X'
    end as cnr,
    case
        when sc_belnr_h = ' '
            then
                null
        else
            'X'
    end as estorno_ajuste,
    case
        when begabrpe <> '00000000'
            then
                TO_DATE(begabrpe, 'YYYYMMDD')
    end as inicio_calculo,
    case
        when endabrpe <> '00000000'
            then
                TO_DATE(endabrpe, 'YYYYMMDD')
    end as fim_calculo,
    case
        when data_estorno_pleno <> '00000000'
            then
                TO_DATE(data_estorno_pleno, 'YYYYMMDD')
    end as data_estorno_pleno,
    case
        when sc_belnr_n <> ' '
            then
                sc_belnr_n
        else
            sc_belnr_h
    end as documento_estorno_ajuste,
    case
        when stornodat <> '00000000'
            then
                TO_DATE(stornodat, 'YYYYMMDD')
    end as data_estorno_ajuste,
    case
        when bcreason <> ' '
            then
                bcreason
    end as motivo_estorno_ajuste,
    case
        when data_competencia <> '00000000'
            then
                TO_DATE(data_competencia, 'YYYYMMDD')
    end as data_competencia,
    case
        when zuorddaa <> '00000000'
            then
                TO_DATE(zuorddaa, 'YYYYMMDD')
    end as data_atribuicao_calculo,
    case
        when data_apresentacao <> '00000000'
            then
                TO_DATE(data_apresentacao, 'YYYYMMDD')
    end as data_apresentacao,
    case
        when data_vencimento_original <> '00000000'
            then
                TO_DATE(data_vencimento_original, 'YYYYMMDD')
    end as data_vencimento_original,
    case
        when adatsoll <> '00000000'
            then
                TO_DATE(adatsoll, 'YYYYMMDD')
    end as data_previsao_leitura,
    case
        when data_criacao_impressao <> '00000000'
            then
                TO_DATE(
                    data_criacao_impressao || ' ' || hora_criacao,
                    'YYYYMMDD HH24MISS'
                )
    end as data_criacao_impressao,
    case
        when usuario_criacao <> ' '
            then
                usuario_criacao
    end as usuario_criacao_impressao,
    case
        when data_modificacao_impressao <> '00000000'
            then
                TO_DATE(data_modificacao_impressao, 'YYYYMMDD')
    end as data_modificacao_impressao,
    case
        when usuario_modificacao <> ' '
            then
                usuario_modificacao
    end as usuario_modificacao_impressao,
    case
        when erdat <> '00000000' and eroetim <> ' '
            then
                TO_DATE(erdat || ' ' || eroetim, 'YYYYMMDD HH24MI')
        when erdat <> '00000000'
            then
                TO_DATE(erdat, 'YYYYMMDD')
    end as data_criacao_calculo,
    case
        when ernam <> ' '
            then
                ernam
    end as usuario_criacao_calculo,
    case
        when aedat <> '00000000'
            then
                TO_DATE(aedat, 'YYYYMMDD')
    end as data_modificacao_calculo,
    case
        when aenam <> ' '
            then
                aenam
    end as usuario_modificacao_calculo,
    case
        when belnralt <> ' '
            then
                belnralt
    end as documento_calculo_anterior,
    case
        when estrutura_regional_politica <> ' '
            then
                estrutura_regional_politica
    end as estrutura_regional_politica
from
    base
