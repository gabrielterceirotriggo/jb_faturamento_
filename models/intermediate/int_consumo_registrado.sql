with calculo_delta as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        estorno_ajuste,
        estorno_pleno,
        cnr
    from
        {{ ref ('int_calculo_delta') }}
),

dberchz2 as (
    select
        mandt,
        belnr,
        belzeile,
        logikzw,
        v_zwstdiff,
        n_zwstdiff,
        ablbelnr
    from
        {{ ref('stg_dberchz2_fat') }}
),

dberchz1 as (
    select
        mandt,
        belnr,
        belzeile,
        belzart,
        bis,
        v_abrmenge,
        n_abrmenge
    from
        {{ ref('stg_dberchz1_fat') }}
),

etdz as (
    select
        mandt,
        logikzw,
        bis,
        ab,
        massread,
        zwfakt
    from
        {{ ref ('stg_etdz') }}
),

ezuz as (
    select
        mandt,
        logikzw,
        bis,
        ab,
        logiknr2,
        abrfakt
    from
        {{ ref ('stg_ezuz') }}
),

egerh as (
    select
        mandt,
        logiknr,
        bis,
        ab,
        kombinat,
        equnr
    from
        {{ ref ('stg_egerh') }}
),

te835t as (
    select
        mandt,
        spras,
        belzart,
        text30
    from
        {{ ref('stg_te835t_fat') }}
),

dados_leitura_base as (
    select
        d2.mandt,
        cd.mes_competencia,
        cd.documento_calculo,
        cd.documento_impressao,
        d2.logikzw,
        d1.bis,
        d1.belzart,
        d1.v_abrmenge,
        d1.n_abrmenge,
        d2.v_zwstdiff,
        d2.n_zwstdiff,
        d2.ablbelnr as id_leitura,
        cd.estorno_ajuste,
        cd.estorno_pleno,
        cd.cnr
    from
        calculo_delta as cd
    left outer join
        dberchz2 as d2
        on
            d2.mandt = {{ mc_mandante(var('source_param')) }}
            and cd.documento_calculo = d2.belnr
            and COALESCE(d2.ablbelnr, ' ') <> ' '
    left outer join
        dberchz1 as d1
        on
            d2.mandt = d1.mandt
            and d2.belnr = d1.belnr
            and d2.belzeile = d1.belzeile
),

enriquecimento_constante_medidor as (
    select
        dlb.mandt,
        dlb.mes_competencia,
        dlb.documento_calculo,
        dlb.documento_impressao,
        dlb.belzart,
        etdz.zwfakt as constante_medidor,
        dlb.v_abrmenge,
        dlb.n_abrmenge,
        dlb.n_zwstdiff,
        dlb.v_zwstdiff,
        dlb.id_leitura,
        dlb.logikzw,
        dlb.bis,
        dlb.estorno_ajuste,
        dlb.estorno_pleno,
        dlb.cnr
    from
        dados_leitura_base as dlb
    left outer join
        etdz
        on
            dlb.mandt = etdz.mandt
            and dlb.logikzw = etdz.logikzw
            and dlb.bis >= etdz.ab
            and dlb.bis <= etdz.bis
    where
        etdz.massread = 'KWH'
        and dlb.mandt = {{ mc_mandante(var('source_param')) }}
),

enriquecimento_fator_calculo as (
    select
        ecm.mandt,
        ecm.mes_competencia,
        ecm.documento_calculo,
        ecm.documento_impressao,
        ecm.belzart,
        ecm.constante_medidor,
        ecm.v_abrmenge,
        ecm.n_abrmenge,
        ecm.v_zwstdiff,
        ecm.n_zwstdiff,
        ecm.id_leitura,
        ezz.abrfakt as fator_calculo,
        ecm.bis,
        ezz.logiknr2,
        ecm.estorno_ajuste,
        ecm.estorno_pleno,
        ecm.cnr
    from
        enriquecimento_constante_medidor as ecm
    left outer join
        ezuz as ezz
        on
            ecm.mandt = ezz.mandt
            and ecm.logikzw = ezz.logikzw
            and ecm.bis >= ezz.ab
            and ecm.bis <= ezz.bis
    where
        ecm.mandt = {{ mc_mandante(var('source_param')) }}
),

identificacao_equipamento as (
    select
        efc.mandt,
        efc.mes_competencia,
        efc.documento_calculo,
        efc.documento_impressao,
        efc.belzart,
        efc.constante_medidor,
        efc.v_abrmenge,
        efc.n_abrmenge,
        efc.v_zwstdiff,
        efc.n_zwstdiff,
        efc.id_leitura,
        efc.fator_calculo,
        efc.estorno_ajuste,
        eg.equnr,
        efc.estorno_pleno,
        efc.cnr,
        efc.bis,
        efc.logiknr2
    from
        enriquecimento_fator_calculo as efc
    left outer join
        egerh as eg
        on
            efc.mandt = eg.mandt
            and efc.logiknr2 = eg.logiknr
            and efc.bis >= eg.ab
            and efc.bis <= eg.bis
            and eg.kombinat = 'W'
    where
        efc.mandt = {{ mc_mandante(var('source_param')) }}
),

calculo_consumo_bruto as (
    select
        ie.mandt,
        ie.mes_competencia,
        ie.documento_calculo,
        ie.documento_impressao,
        ie.fator_calculo,
        ie.equnr,
        ie.estorno_pleno,
        ie.belzart,
        case
            when ie.estorno_ajuste = 'X' or ie.cnr = 'X'
                then
                    (ie.v_abrmenge + ie.n_abrmenge)
            else
                (ie.v_zwstdiff + ie.n_zwstdiff)
                * ie.constante_medidor
                * COALESCE(ie.fator_calculo, 1)
        end as consumo_registrado_dberchz2
    from
        identificacao_equipamento as ie
    left outer join
        te835t as t8
        on
            ie.mandt = t8.mandt
            and ie.belzart = t8.belzart
    where
        t8.spras = 'P'
        and t8.mandt = {{ mc_mandante(var('source_param')) }}
        and (t8.text30 not like '% RV' or t8.belzart = 'ZRCARV')
        and t8.text30 not like '%Gerado%'
        and t8.text30 not like '%Reativo Exced%'
),

consumo_agregado_por_tipo as (
    select
        mandt,
        mes_competencia,
        documento_calculo,
        documento_impressao,
        fator_calculo,
        equnr,
        estorno_pleno,
        case
            when
                SUM(
                    case
                        when belzart = 'ZRCAT'
                            then consumo_registrado_dberchz2
                        else 0
                    end
                ) <> 0
                then
                    SUM(
                        case
                            when belzart = 'ZRCAT'
                                then consumo_registrado_dberchz2
                            else 0
                        end
                    )
            else
                SUM(
                    case
                        when belzart in ('ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV')
                            then consumo_registrado_dberchz2
                        else 0
                    end
                )
        end as consumo_registrado_dberchz2
    from
        calculo_consumo_bruto
    group by
        mandt,
        mes_competencia,
        documento_calculo,
        documento_impressao,
        fator_calculo,
        equnr,
        estorno_pleno
),

consumo_filtrado as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        consumo_registrado_dberchz2,
        estorno_pleno
    from
        consumo_agregado_por_tipo
    where
        (fator_calculo is null and equnr is null)
        or
        (fator_calculo is not null and equnr is not null)
),

consumo_final_ajustado as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        case
            when estorno_pleno = 'X'
                then SUM(consumo_registrado_dberchz2) * -1
            else
                SUM(consumo_registrado_dberchz2)
        end as consumo_registrado
    from
        consumo_filtrado
    group by
        mes_competencia,
        documento_calculo,
        documento_impressao,
        estorno_pleno
),

final as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        consumo_registrado
    from
        consumo_final_ajustado
)

select * from final
