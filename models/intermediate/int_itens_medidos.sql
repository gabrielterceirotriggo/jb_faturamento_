with documentos_faturamento as (
    select
        mes_competencia,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        estorno,
        mandt
    from
        {{ ref('int_documentos_faturamento') }}
),

dberdlb as (
    select
        mandt,
        printdoc,
        billdoc,
        billdocline,
        nettobtr,
        sttax,
        hvorg,
        txjcd,
        xtotal_amnt
    from
        {{ ref('stg_dberdlb_fat') }}
),

dberchz1 as (
    select
        mandt,
        belnr,
        belzeile,
        branche,
        tariftyp,
        temp_area,
        belzart,
        linesort,
        ab,
        bis,
        v_abrmenge,
        n_abrmenge,
        tvorg,
        ein01
    from
        {{ ref('stg_dberchz1_fat') }}
),

dberchz3 as (
    select
        mandt,
        belnr,
        belzeile,
        zonennr,
        preisbtr,
        nettobtr
    from
        {{ ref('stg_dberchz3_fat') }}
),

zfatt057_ophist as (
    select
        mandt,
        belzart,
        operand,
        ez_abrmenge_flag
    from
        {{ ref('stg_zfatt057_ophist_fat') }}
),

itens_medidos_base as (
    select
        df.mes_competencia,
        df.doc_calculo,
        df.doc_impressao,
        df.tipo_calculo,
        df.estorno,
        dz1.belzeile,
        dz1.branche,
        dz1.tariftyp,
        dz1.temp_area,
        dz1.belzart,
        dz1.linesort,
        dz3.zonennr,
        dz3.preisbtr,
        dlb.nettobtr,
        dlb.sttax,
        dlb.hvorg,
        dlb.txjcd,
        dz1.ab,
        dz1.bis,
        dz1.v_abrmenge,
        dz1.n_abrmenge,
        dz3.nettobtr as nettobtr_dz3,
        dz1.tvorg
    from
        documentos_faturamento as df
    left outer join dberdlb as dlb
        on df.doc_impressao = dlb.printdoc and df.doc_calculo = dlb.billdoc
    left outer join dberchz1 as dz1
        on dlb.billdoc = dz1.belnr and dlb.billdocline = dz1.belzeile
    left outer join dberchz3 as dz3
        on dz1.belnr = dz3.belnr and dz1.belzeile = dz3.belzeile
    left outer join zfatt057_ophist as zo
        on df.mandt = zo.mandt and dz1.belzart = zo.belzart and dz1.ein01 = zo.operand
    where
        zo.ez_abrmenge_flag = 'X'
        and COALESCE(dlb.xtotal_amnt, ' ') <> 'X'
        and df.mandt = {{ mc_mandante() }}
),

itens_medidos_transformados as (
    select
        mes_competencia,
        doc_calculo as documento_calculo,
        doc_impressao as documento_impressao,
        belzeile,
        branche as setor_industrial,
        tariftyp as categoria_tarifa,
        temp_area as subclasse,
        belzart,
        linesort,
        zonennr as escalao,
        null as tipo_imposto,
        preisbtr as preco,
        nettobtr as receita,
        sttax as base_imposto,
        0 as aliquota,
        hvorg as operacao,
        txjcd as domicilio_fiscal,
        try_to_date(ab, 'YYYYMMDD') as inicio_calculo,
        try_to_date(bis, 'YYYYMMDD') as fim_calculo,
        case
            when
                tipo_calculo = 'CM'
                and (
                    ((COALESCE(v_abrmenge, 0) + COALESCE(n_abrmenge, 0)) > 0 and COALESCE(nettobtr_dz3, 0) < 0)
                    or
                    ((COALESCE(v_abrmenge, 0) + COALESCE(n_abrmenge, 0)) < 0 and COALESCE(nettobtr_dz3, 0) > 0)
                )
                then (COALESCE(v_abrmenge, 0) + COALESCE(n_abrmenge, 0)) * -1
            else COALESCE(v_abrmenge, 0) + COALESCE(n_abrmenge, 0)
        end as consumo_bruto,
        case
            when tvorg = ' ' then null
            else tvorg
        end as sub_operacao,
        case
            when estorno = 'X' then consumo_bruto * -1 else consumo_bruto
        end as consumo
    from
        itens_medidos_base
),

final as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        belzart,
        linesort,
        escalao,
        inicio_calculo,
        fim_calculo,
        tipo_imposto,
        consumo,
        preco,
        receita,
        base_imposto,
        aliquota,
        operacao,
        sub_operacao,
        domicilio_fiscal
    from
        itens_medidos_transformados
)

select * from final
