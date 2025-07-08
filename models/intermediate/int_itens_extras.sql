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
        txjcd
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
        tvorg
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

itens_extras_faturamento_base as (
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
                df.tipo_calculo = 'CM' and (
                    ((COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) > 0 and COALESCE(dz3.nettobtr, 0) < 0)
                    or (
                        (COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) < 0
                        and COALESCE(dz3.nettobtr, 0) > 0
                    )
                )
                then (COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)) * -1
            else COALESCE(dz1.v_abrmenge, 0) + COALESCE(dz1.n_abrmenge, 0)
        end as consumo,
        case
            when COALESCE(dz1.tvorg, ' ') = ' ' then null
            else dz1.tvorg
        end as sub_operacao
    from
        documentos_faturamento as df
    left outer join
        dberdlb as dlb
        on df.doc_impressao = dlb.printdoc and df.doc_calculo = dlb.billdoc
    left outer join
        dberchz1 as dz1
        on dlb.billdoc = dz1.belnr and dlb.billdocline = dz1.belzeile
    left outer join
        dberchz3 as dz3
        on dz1.belnr = dz3.belnr and dz1.belzeile = dz3.belzeile
    where
        dz1.belzart in (
            'ZGSAT', 'ZGSNP', 'ZGSFP', 'ZGSRV', 'ZGSIT', 'ZPCAFP', 'ZPCANP',
            'ZPGFP', 'ZPGNP', 'ZPCAT', 'ZPGAT', 'ZDR1', 'ZDR2', 'ZDR3', 'ZDR4',
            'ZDR5', 'ZDR6', 'ZUR1', 'ZUR2', 'ZUR3', 'ZEUSD', 'ZRAMAL', 'ZEUSDB',
            'ZDCFP', 'ZDCFPL', 'ZDCGER', 'ZDCMFP', 'ZDCMNP', 'ZDCNP', 'ZDCNPL',
            'ZDCOMP', 'ZDCONL', 'ZDCONT', 'ZDCT'
        )
),

itens_extras_transformados as (
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
        preco,
        base_imposto,
        aliquota,
        estorno,
        operacao,
        domicilio_fiscal,
        case
            when estorno = 'X' then consumo * -1
            else consumo
        end as consumo,
        case
            when estorno = 'X' then receita * -1
            else receita
        end as receita,
        case
            when sub_operacao = ' ' then null
            else sub_operacao
        end as sub_operacao
    from
        itens_extras_faturamento_base
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
        preco,
        base_imposto,
        aliquota,
        estorno,
        consumo,
        receita,
        operacao,
        sub_operacao,
        domicilio_fiscal
    from
        itens_extras_transformados
)

select * from final
