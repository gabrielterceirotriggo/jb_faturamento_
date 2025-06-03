with int_calculo_delta as (
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
        cancelamento,
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        quantidade_dias,
        documento_estorno_pleno,
        data_estorno_pleno,
        motivo_estorno_pleno,
        documento_estorno_ajuste,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        valor_contabil,
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
        {{ ref ('int_calculo_delta') }}
),

dberchz2 as (
    select
        mandt,
        belnr,
        belzeile,
        ablbelnr,
        logikzw,
        v_zwstdiff,
        n_zwstdiff,
        data_dados
    from
        {{ ref('stg_dberchz2') }}
),

dberchz1 as (
    select
        mandt,
        belnr,
        belzeile,
        belzart,
        branche,
        tvorg,
        linesort,
        ab,
        bis,
        tariftyp,
        temp_area,
        v_abrmenge,
        n_abrmenge,
        data_dados
    from
        {{ ref('stg_dberchz1') }}
),

etdz as (
    select
        mandt,
        equnr,
        zwnummer,
        bis,
        ab,
        logikzw,
        spartyp,
        zwkenn,
        kennziff,
        zwart,
        zwfakt,
        stanzvor,
        stanznac,
        zwtyp,
        bliwirk,
        massread,
        anzerg,
        kzmessw,
        ueberver,
        steuergrp,
        nablesen,
        pruefkl,
        temp_area,
        pr_area_ai,
        calor_area,
        hoekorr,
        thgber,
        kzahle,
        kzahlt,
        gas_prs_ar,
        crgpress,
        erdat,
        ernam,
        aedat,
        aenam,
        massbill,
        gewkey,
        zspanns,
        zstroms,
        zspannp,
        zstromp,
        intsizeid,
        touperiod,
        vee_code,
        data_dados
    from
        {{ ref ('stg_etdz') }}
),

ezuz as (
    select
        mandt,
        logikzw,
        bis,
        zuart,
        logiknr2,
        ab,
        messdrck,
        abrfakt,
        progt,
        attribut,
        erdat,
        ernam,
        aedat,
        aenam
    from
        {{ ref ('stg_ezuz') }}
),

egerh as (
    select
        mandt,
        equnr,
        bis,
        ab,
        kombinat,
        logiknr,
        zwgruppe,
        einbdat,
        ausbdat,
        gerwechs,
        devloc,
        devgrp,
        wgruppe,
        ppm_meter,
        primwnr1,
        sekwnr1,
        primwnr2,
        sekwnr2,
        lossdtgroup,
        rating,
        p_voltage,
        s_voltage,
        ams,
        amcg_cap_grp,
        msg_attr_id,
        cap_act_grp,
        einbzeit,
        ausbzeit,
        zeitzone,
        data_dados
    from
        {{ ref ('stg_egerh') }}
),

te835t as (
    select
        mandt,
        spras,
        belzart,
        text30,
        data_dados
    from
        {{ ref('stg_te835t') }}
),

q1_0 as (
    select
        db2.mandt,
        tcd.mes_competencia,
        tcd.documento_calculo,
        tcd.documento_impressao,
        --não tinha na tabela
        db2.logikzw,
        db1.bis,
        db1.belzart,
        db1.v_abrmenge,
        db1.n_abrmenge,
        --não tinha na tabela
        db2.v_zwstdiff,
        db2.n_zwstdiff,
        db2.ablbelnr as id_leitura,
        tcd.estorno_ajuste,
        tcd.estorno_pleno,
        tcd.cnr
    from
        int_calculo_delta as tcd
    left outer join
        dberchz2 as db2
        on
            db2.mandt in (401, 402, 403, 404)
            and tcd.documento_calculo = db2.belnr
            and db2.ablbelnr <> ' '
    left outer join
        dberchz1 as db1
        on
            db2.mandt = db1.mandt
            and db2.belnr = db1.belnr
            and db2.belzeile = db1.belzeile
),

q1_1 as (
    select
        q1_0.belzart,
        q1_0.bis,
        q1_0.cnr,
        etdz.zwfakt as constante_medidor,
        q1_0.documento_calculo,
        q1_0.documento_impressao,
        q1_0.estorno_ajuste,
        q1_0.estorno_pleno,
        q1_0.id_leitura,
        q1_0.logikzw,
        q1_0.mandt,
        q1_0.mes_competencia,
        q1_0.n_abrmenge,
        q1_0.n_zwstdiff,
        q1_0.v_abrmenge,
        q1_0.v_zwstdiff
    from
        q1_0
    left outer join
        etdz
        on
            q1_0.mandt = etdz.mandt
            and q1_0.logikzw = etdz.logikzw
            and q1_0.bis >= etdz.ab
            and q1_0.bis <= etdz.bis
    where
        etdz.massread = 'KWH'
        and q1_0.mandt in (401, 402, 403, 404)
),

q1_2 as (
    select
        q1_1.mandt,
        q1_1.mes_competencia,
        q1_1.documento_calculo,
        q1_1.documento_impressao,
        q1_1.belzart,
        q1_1.constante_medidor,
        q1_1.v_abrmenge,
        q1_1.n_abrmenge,
        q1_1.v_zwstdiff,
        q1_1.n_zwstdiff,
        q1_1.id_leitura,
        ezuz.abrfakt as fator_calculo,
        q1_1.bis,
        ezuz.logiknr2,
        q1_1.estorno_ajuste,
        q1_1.estorno_pleno,
        q1_1.cnr
    from
        q1_1
    left outer join
        ezuz
        on
            q1_1.mandt = ezuz.mandt
            and q1_1.logikzw = ezuz.logikzw
            and q1_1.bis >= ezuz.ab
            and q1_1.bis <= ezuz.bis
),

q1_3 as (
    select
        q1_2.mandt,
        q1_2.mes_competencia,
        q1_2.documento_calculo,
        q1_2.documento_impressao,
        q1_2.belzart,
        q1_2.constante_medidor,
        q1_2.v_abrmenge,
        q1_2.n_abrmenge,
        q1_2.v_zwstdiff,
        q1_2.n_zwstdiff,
        q1_2.id_leitura,
        q1_2.fator_calculo,
        q1_2.estorno_ajuste,
        egerh.equnr,
        q1_2.estorno_pleno,
        q1_2.cnr
    from
        q1_2
    left outer join
        egerh
        on
            q1_2.mandt = egerh.mandt
            and q1_2.logiknr2 = egerh.logiknr
            and q1_2.bis >= egerh.ab
            and q1_2.bis <= egerh.bis
            and egerh.kombinat = 'W'
),

q1_4 as (
    select
        q1_3.mandt,
        q1_3.mes_competencia,
        q1_3.documento_calculo,
        q1_3.documento_impressao,
        q1_3.fator_calculo,
        q1_3.equnr,
        q1_3.estorno_pleno,
        q1_3.belzart,
        case
            when q1_3.estorno_ajuste = 'X' or q1_3.cnr = 'X'
                then
                    (q1_3.v_abrmenge + q1_3.n_abrmenge)
            else
                (q1_3.v_zwstdiff + q1_3.n_zwstdiff)
                * q1_3.constante_medidor
                * COALESCE(q1_3.fator_calculo, 1)
        end as consumo_registrado_dberchz2
    from
        q1_3
    left outer join
        te835t
        on
            q1_3.belzart = te835t.belzart
    where
        te835t.spras = 'P'
        and te835t.mandt in (401, 402, 403, 404)
        and (te835t.text30 not like '% RV' or te835t.belzart = 'ZRCARY')
        and te835t.text30 not like '%Gerado'
        and te835t.text30 not like '%Reativo Exced'
),

case as (
    select
        q1_4.mandt,
        q1_4.mes_competencia,
        q1_4.documento_calculo,
        q1_4.documento_impressao,
        q1_4.fator_calculo,
        q1_4.equnr,
        q1_4.estorno_pleno,
        case
            when
                SUM(
                    case
                        when
                            q1_4.belzart in ('ZRCAT')
                            then q1_4.consumo_registrado_dberchz2
                        else 0
                    end
                )
                <> 0
                then
                    SUM(
                        case
                            when
                                q1_4.belzart in ('ZRCAT')
                                then q1_4.consumo_registrado_dberchz2
                            else 0
                        end
                    )
            else
                SUM(
                    case
                        when
                            q1_4.belzart in (
                                'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV'
                            )
                            then q1_4.consumo_registrado_dberchz2
                        else 0
                    end
                )
        end as consumo_registrado_dberchz2
    from
        q1_4
    group by
        q1_4.mandt,
        q1_4.mes_competencia,
        q1_4.documento_calculo,
        q1_4.documento_impressao,
        q1_4.fator_calculo,
        q1_4.equnr,
        q1_4.estorno_pleno
),

q2 as (
    select
        mandt,
        mes_competencia,
        documento_calculo,
        documento_impressao,
        consumo_registrado_dberchz2,
        estorno_pleno
    from
        case
    where
        (fator_calculo is null and equnr is null)
        or
        (fator_calculo is not null and equnr is not null)
)

select
    q2.mes_competencia,
    q2.documento_calculo,
    q2.documento_impressao,
    case
        when
            q2.estorno_pleno = 'X'
            then
                SUM(q2.consumo_registrado_dberchz2) * -1
        else
            SUM(q2.consumo_registrado_dberchz2)
    end as consumo_registrado
from
    q2
group by
    q2.mes_competencia,
    q2.documento_calculo,
    q2.documento_impressao,
    q2.estorno_pleno
