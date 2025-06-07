with erdk as (
    select
        mandt,
        opbel,
        budat,
        exbel,
        ergrd,
        ztipo,
        icreason,
        total_amnt,
        fikey,
        nrzas,
        zzdataapr,
        faedn,
        erdat,
        creation_time,
        ernam,
        aedat,
        aenam,
        intopbel,
        regpolit,
        invoiced
    from
        {{ ref('stg_erdk') }}
),

erchc as (
    select
        mandt,
        opbel,
        belnr
    from
        {{ ref('stg_erchc') }}
),

erch as (
    select
        mandt,
        belnr,
        billing_period,
        vkont,
        gpartner,
        vertrag,
        ableinh,
        belegart,
        zzorigdoc,
        sc_belnr_h,
        begabrpe,
        endabrpe,
        sc_belnr_n,
        stornodat,
        bcreason,
        txjcd,
        zuorddaa,
        adatsoll,
        eroetim,
        erdat as erdat_erch,
        ernam as ernam_erch,
        aedat as aedat_erch,
        aenam as aenam_erch,
        belnralt
    from
        {{ ref('stg_erch') }}
),

ever as (
    select
        mandt,
        vertrag,
        anlage
    from
        {{ ref('stg_ever') }}
),

ettifn as (
    select
        anlage,
        operand,
        bis,
        belnr
    from
        {{ ref('stg_ettifn') }}
),

ultima_execucao as (
    select
        ultima_execucao
    from
        {{ ref('stg_int_ultima_exec') }}
),

dados_faturamento_base as (
    select
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
        a.erdat as data_criacao_impressao_raw,
        a.creation_time as hora_criacao,
        a.ernam as usuario_criacao,
        a.aedat as data_modificacao_impressao_raw,
        a.aenam as usuario_modificacao,
        c.eroetim,
        c.erdat_erch,
        c.ernam_erch,
        c.aedat_erch,
        c.aenam_erch,
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
        erdk a
    inner join erchc b on a.mandt = b.mandt and a.opbel = b.opbel
    inner join erch c on b.mandt = c.mandt and b.belnr = c.belnr
    left join ever d on c.mandt = d.mandt and c.vertrag = d.vertrag
    left join ettifn e on d.anlage = e.anlage and e.operand = 'FL_MINIMO' and c.endabrpe = e.bis and c.belnr = e.belnr
    where
        a.mandt = {{ mc_mandante(var('source_param')) }}
        and a.erdat >= (select ultima_execucao from ultima_execucao)
        and a.erdat <= TO_CHAR(CURRENT_DATE(), 'YYYYMMDD')
        and a.invoiced = 'X'
),

faturamento_transformado as (
    select distinct
        SUBSTR(data_competencia, 1, 6) as mes_competencia,
        LEFT(billing_period, 4) || SUBSTR(billing_period, 6, 2) as mes_referencia,
        documento_calculo,
        documento_impressao,
        case when fatura <> ' ' then fatura end as fatura,
        case when anlage <> ' ' then anlage end as instalacao,
        vkont as conta_contrato,
        gpartner as parceiro_negocio,
        vertrag as contrato,
        ableinh as unidade_leitura,
        SUBSTR(ableinh, 3, 2) as etapa,
        motivo_criacao_impressao,
        tipo_impressao,
        belegart as tipo_calculo,
        case when zzorigdoc <> ' ' then zzorigdoc end as origem_documento,
        case when zzorigdoc in ('IP', 'RS', 'FR', 'DS', 'CL') then 'X' end as cnr,
        estorno_pleno,
        case when sc_belnr_h <> ' ' then 'X' end as estorno_ajuste,
        fatura_virtual,
        minimo,
        case when begabrpe <> '00000000' then TO_DATE(begabrpe, 'YYYYMMDD') end as inicio_calculo,
        case when endabrpe <> '00000000' then TO_DATE(endabrpe, 'YYYYMMDD') end as fim_calculo,
        contrapartida as documento_estorno_pleno,
        case when data_estorno_pleno <> '00000000' then TO_DATE(data_estorno_pleno, 'YYYYMMDD') end as data_estorno_pleno,
        motivo_estorno_impressao as motivo_estorno_pleno,
        case when sc_belnr_n <> ' ' then sc_belnr_n else sc_belnr_h end as documento_estorno_ajuste,
        case when stornodat <> '00000000' then TO_DATE(stornodat, 'YYYYMMDD') end as data_estorno_ajuste,
        case when bcreason <> ' ' then bcreason end as motivo_estorno_ajuste,
        valor_total as valor_fatura,
        chave_reconciliacao,
        formulario_pagamento,
        txjcd as domicilio_fiscal,
        case when data_competencia <> '00000000' then TO_DATE(data_competencia, 'YYYYMMDD') end as data_competencia,
        case when zuorddaa <> '00000000' then TO_DATE(zuorddaa, 'YYYYMMDD') end as data_atribuicao_calculo,
        case when data_apresentacao <> '00000000' then TO_DATE(data_apresentacao, 'YYYYMMDD') end as data_apresentacao,
        case when data_vencimento_original <> '00000000' then TO_DATE(data_vencimento_original, 'YYYYMMDD') end as data_vencimento_original,
        case when adatsoll <> '00000000' then TO_DATE(adatsoll, 'YYYYMMDD') end as data_previsao_leitura,
        case when data_criacao_impressao_raw <> '00000000' then TO_TIMESTAMP_NTZ(data_criacao_impressao_raw || hora_criacao, 'YYYYMMDDHH24MISS') end as data_criacao_impressao,
        case when usuario_criacao <> ' ' then usuario_criacao end as usuario_criacao_impressao,
        case when data_modificacao_impressao_raw <> '00000000' then TO_DATE(data_modificacao_impressao_raw, 'YYYYMMDD') end as data_modificacao_impressao,
        case when usuario_modificacao <> ' ' then usuario_modificacao end as usuario_modificacao_impressao,
        case when erdat_erch <> '00000000' and eroetim <> ' ' then TO_TIMESTAMP_NTZ(erdat_erch || ' ' || eroetim, 'YYYYMMDD HH24MI') when erdat_erch <> '00000000' then TO_DATE(erdat_erch, 'YYYYMMDD') end as data_criacao_calculo,
        case when ernam_erch <> ' ' then ernam_erch end as usuario_criacao_calculo,
        case when aedat_erch <> '00000000' then TO_DATE(aedat_erch, 'YYYYMMDD') end as data_modificacao_calculo,
        case when aenam_erch <> ' ' then aenam_erch end as usuario_modificacao_calculo,
        case when belnralt <> ' ' then belnralt end as documento_calculo_anterior,
        case when estrutura_regional_politica <> ' ' then estrutura_regional_politica end as estrutura_regional_politica
    from
        dados_faturamento_base
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
        faturamento_transformado
)

select * from final
