with faturamento_delta as (
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
        setor_industrial,
        grupo,
        categoria_tarifa,
        cliente_livre,
        subclasse,
        motivo_criacao_impressao,
        tipo_impressao,
        tipo_calculo,
        origem_documento,
        cnr,
        estornado,
        estorno_pleno,
        estorno_ajuste,
        reversao,
        cancelamento,
        fatura_virtual,
        minimo,
        documento_estorno_pleno,
        data_estorno_pleno,
        motivo_estorno_pleno,
        documento_estorno_ajuste,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        valor_contabil,
        consumo_faturado,
        consumo_medido,
        eusd,
        eusdb,
        icms,
        icms_subvencao,
        pis,
        cofins,
        cip,
        retencao,
        receita_bandeiras,
        receita_consumo_faturado,
        tarifa,
        preco,
        correcao_monetaria,
        creditos,
        estornos,
        juros,
        multas,
        parcelamentos,
        outros_lancamentos,
        chave_reconciliacao,
        formulario_pagamento,
        domicilio_fiscal,
        inicio_calculo,
        fim_calculo,
        quantidade_dias,
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
        ordem_faturamento
    from
        {{ ref('faturamento_delta') }}
),

dberchz2 as (
    select
        mandt,
        belnr,
        belzeile,
        equnr,
        geraet,
        matnr,
        zwnummer,
        indexnr,
        ablesgr,
        ablesgrv,
        atim,
        atimva,
        adatmax,
        atimmax,
        thgdatum,
        zuorddat,
        regrelsort,
        ablbelnr,
        logiknr,
        logikzw,
        istablart,
        istablartva,
        extpkz,
        begprog,
        endeprog,
        ablhinw,
        qdproc,
        mrconnect,
        v_zwstand,
        n_zwstand,
        v_zwstndab,
        n_zwstndab,
        v_zwstvor,
        n_zwstvor,
        v_zwstdiff,
        n_zwstdiff,
        data_dados
    from
        {{ ref ('stg_dberchz2') }}
),

q_leitura_l as (
    select
        faturamento_delta.documento_calculo,
        dberchz2.ablbelnr as id_leitura
    from
        faturamento_delta
    left outer join
        dberchz2
        on  
            dberchz2.mandt = {{ mc_mandante(var('source_param')) }}
            and faturamento_delta.documento_calculo = dberchz2.belnr
    where
        dberchz2.mandt = {{ mc_mandante(var('source_param')) }}
)

select distinct
    q_leitura_l.documento_calculo,
    q_leitura_l.id_leitura
from
    q_leitura_l
where
    q_leitura_l.id_leitura <> ' '
