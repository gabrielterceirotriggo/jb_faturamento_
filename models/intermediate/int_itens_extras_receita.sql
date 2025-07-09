with documentos_faturamento as (
    select
        mes_competencia,
        doc_calculo,
        doc_impressao,
        estorno
    from
        {{ ref('int_documentos_faturamento') }}
),

dberdl as (
    select
        printdoc,
        belzart,
        sbasw,
        linesort,
        ab,
        bis,
        ktosl,
        nettobtr,
        stprz,
        hvorg,
        tvorg,
        txjcd,
        xtotal_amnt
    from
        {{ ref('stg_dberdl_fat') }}
),

itens_faturamento_impostos_base as (
    select
        df.mes_competencia,
        df.doc_calculo as documento_calculo,
        df.doc_impressao as documento_impressao,
        d.belzart,
        d.linesort,
        d.ab,
        d.bis,
        d.sbasw,
        df.estorno,
        d.ktosl,
        d.nettobtr,
        d.stprz,
        d.hvorg,
        d.tvorg,
        d.txjcd
    from
        documentos_faturamento as df
    left outer join
        dberdl as d
        on df.doc_impressao = d.printdoc
    where
        COALESCE(d.xtotal_amnt, ' ') <> 'X'
        and d.linesort in (
            'ZDR1', 'ZDR2', 'ZDR3', 'ZDR4', 'ZDR5',
            'ZDR6', 'ZUR1', 'ZUR2', 'ZUR3', 'ZDES'
        )
),

itens_faturamento_impostos_transformados as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        null as belzeile,
        null as setor_industrial,
        null as categoria_tarifa,
        null as subclasse,
        belzart,
        '000' as escalao,
        sbasw as base_imposto,
        estorno,
        case
            when linesort = ' ' then null
            else linesort
        end as linesort,
        case
            when COALESCE(ab, '00000000') <> '00000000' then TO_DATE(ab, 'YYYYMMDD')
        end as inicio_calculo,
        case
            when COALESCE(bis, '00000000') <> '00000000' then TO_DATE(bis, 'YYYYMMDD')
        end as fim_calculo,
        case
            when ktosl = ' ' then null
            else ktosl
        end as tipo_imposto,
        CAST(null as NUMBER) as consumo,
        CAST(null as NUMBER) as preco,
        case
            when estorno = 'x' then nettobtr * -1
            else nettobtr
        end as receita,
        case
            when COALESCE(stprz, ' ') = ' ' then 0
            else TO_NUMBER(REPLACE(stprz, ',', '.'), 10, 3)
        end as aliquota,
        case
            when hvorg = ' ' then null
            else hvorg
        end as operacao,
        case
            when tvorg = ' ' then null
            else tvorg
        end as sub_operacao,
        case
            when txjcd = ' ' then null
            else txjcd
        end as domicilio_fiscal
    from
        itens_faturamento_impostos_base
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
        escalao,
        base_imposto,
        estorno,
        linesort,
        inicio_calculo,
        fim_calculo,
        tipo_imposto,
        consumo,
        preco,
        receita,
        aliquota,
        operacao,
        sub_operacao,
        domicilio_fiscal
    from
        itens_faturamento_impostos_transformados
)

select * from final
