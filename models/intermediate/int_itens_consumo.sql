with documentos_faturamento as (
    select
        mandt,
        doc_calculo,
        doc_impressao,
        tipo_calculo,
        tipo_documento,
        estorno,
        mes_competencia
    from
        {{ ref ('int_documentos_faturamento') }}
),

dberdlb as (
    select
        mandt,
        printdoc,
        billdoc,
        billdocline,
        hvorg,
        xtotal_amnt,
        txjcd,
        nettobtr,
        sttax
    from
        {{ ref ('stg_dberdlb_fat') }}
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
        n_abrmenge
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

dberchz5 as (
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
        n_abrmenge
    from
        {{ ref('stg_dberchz5_fat') }}
),

dberchz7 as (
    select
        mandt,
        belnr,
        belzeile,
        zonennr,
        preisbtr,
        nettobtr
    from
        {{ ref('stg_dberchz7_fat') }}
),

itens_consumo_base_tipo1 as (
    select
        df.mes_competencia,
        df.doc_calculo as documento_calculo,
        df.doc_impressao as documento_impressao,
        df.tipo_calculo,
        df.tipo_documento,
        dz1.belzeile,
        dz1.branche as setor_industrial,
        dz1.tariftyp as categoria_tarifa,
        dz1.temp_area as subclasse,
        dz1.belzart,
        dz1.linesort,
        dz3.zonennr as escalao,
        null as tipo_imposto,
        dz3.preisbtr as preco,
        dlb.nettobtr as receita,
        dlb.sttax as base_imposto,
        0 as aliquota,
        dlb.hvorg as operacao,
        dz1.tvorg as sub_operacao,
        dlb.txjcd as domicilio_fiscal,
        df.estorno,
        case
            when COALESCE(dz1.ab, '00000000') <> '00000000' then TO_DATE(dz1.ab, 'YYYYMMDD')
        end as inicio_calculo,
        case
            when COALESCE(dz1.bis, '00000000') <> '00000000' then TO_DATE(dz1.bis, 'YYYYMMDD')
        end as fim_calculo,
        case
            when
                df.tipo_calculo = 'CM'
                and (
                    ((COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) > 0 and dz3.nettobtr < 0)
                    or (
                        (COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) < 0
                        and dz3.nettobtr > 0
                    )
                )
                then (COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) * -1
            else COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)
        end as consumo
    from
        documentos_faturamento as df
    left join dberdlb as dlb
        on
            df.mandt = dlb.mandt
            and df.doc_impressao = dlb.printdoc
            and df.doc_calculo = dlb.billdoc
    left join dberchz1 as dz1
        on
            dlb.mandt = dz1.mandt
            and dlb.billdoc = dz1.belnr
            and dlb.billdocline = dz1.belzeile
    left join dberchz3 as dz3
        on
            dz1.mandt = dz3.mandt
            and dz1.belnr = dz3.belnr
            and dz1.belzeile = dz3.belzeile
    where
        dlb.xtotal_amnt = 'X'
        and df.mandt = {{ mc_mandante() }}
),

itens_consumo_base_tipo2 as (
    select
        df.mes_competencia,
        df.doc_calculo as documento_calculo,
        df.doc_impressao as documento_impressao,
        df.tipo_calculo,
        df.tipo_documento,
        dz5.belzeile,
        dz5.branche as setor_industrial,
        dz5.tariftyp as categoria_tarifa,
        dz5.temp_area as subclasse,
        dz5.belzart,
        dz5.linesort,
        dz7.zonennr as escalao,
        null as tipo_imposto,
        dz7.preisbtr as preco,
        dlb.nettobtr as receita,
        dlb.sttax as base_imposto,
        0 as aliquota,
        dlb.hvorg as operacao,
        dz5.tvorg as sub_operacao,
        dlb.txjcd as domicilio_fiscal,
        df.estorno,
        case
            when COALESCE(dz5.ab, '00000000') <> '00000000' then TO_DATE(dz5.ab, 'YYYYMMDD')
        end as inicio_calculo,
        case
            when COALESCE(dz5.bis, '00000000') <> '00000000' then TO_DATE(dz5.bis, 'YYYYMMDD')
        end as fim_calculo,
        case
            when
                df.tipo_calculo = 'CM'
                and (
                    (COALESCE(dz5.v_abrmenge, 0) + COALESCE(dz5.n_abrmenge, 0)) > 0 and COALESCE(dz7.nettobtr, 0) < 0)
                    or (
                        (COALESCE(dz5.v_abrmenge, 0) + COALESCE(dz5.n_abrmenge, 0)) < 0
                        and COALESCE(dz7.nettobtr, 0) > 0
                    )
                then (COALESCE(dz5.v_abrmenge, 0) + COALESCE(dz5.n_abrmenge, 0)) * -1
            else COALESCE(dz5.v_abrmenge, 0) + COALESCE(dz5.n_abrmenge, 0)
        end as consumo
    from
        documentos_faturamento as df
    left join dberdlb as dlb
        on
            df.mandt = dlb.mandt
            and df.doc_impressao = dlb.printdoc
            and df.doc_calculo = dlb.billdoc
    left join dberchz5 as dz5
        on
            dlb.mandt = dz5.mandt
            and dlb.billdoc = dz5.belnr
            and dlb.billdocline = dz5.belzeile
    left join dberchz7 as dz7
        on
            dz5.mandt = dz7.mandt
            and dz5.belnr = dz7.belnr
            and dz5.belzeile = dz7.belzeile
    where
        dlb.xtotal_amnt = 'X'
        and df.mandt = {{ mc_mandante() }}
),

itens_consumo_transformados_tipo1 as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        tipo_documento,
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
        preco,
        base_imposto,
        aliquota,
        operacao,
        domicilio_fiscal,
        estorno,
        case when estorno = 'X' then consumo * -1 else consumo end as consumo,
        case when estorno = 'X' then receita * -1 else receita end as receita,
        case when sub_operacao = ' ' then null else sub_operacao end
            as sub_operacao
    from
        itens_consumo_base_tipo1
    where
        belzart is not null
),

itens_consumo_transformados_tipo2 as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        tipo_documento,
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
        preco,
        base_imposto,
        aliquota,
        operacao,
        domicilio_fiscal,
        estorno,
        case when estorno = 'X' then consumo * -1 else consumo end as consumo,
        case when estorno = 'X' then receita * -1 else receita end as receita,
        case when sub_operacao = ' ' then null else sub_operacao end
            as sub_operacao
    from
        itens_consumo_base_tipo2
    where
        belzart is not null
),

itens_consumo_unificados as (
    select * from itens_consumo_transformados_tipo1
    union all
    select * from itens_consumo_transformados_tipo2
),

final as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        tipo_calculo,
        tipo_documento,
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
        domicilio_fiscal,
        estorno
    from
        itens_consumo_unificados
)

select * from final
