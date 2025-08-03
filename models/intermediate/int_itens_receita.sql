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

itens_receita_base as (
    select
        df.mes_competencia,
        df.doc_calculo,
        df.doc_impressao,
        df.estorno,
        d.belzart,
        d.sbasw,
        d.linesort,
        d.ab,
        d.bis,
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
        d.xtotal_amnt = 'X'
),

itens_receita_transformados as (
    select
        mes_competencia,
        doc_calculo as documento_calculo,
        doc_impressao as documento_impressao,
        null as belzeile,
        null as categoria_tarifa,
        null as setor_industrial,
        null as subclasse,
        belzart,
        '000' as escalao,
        sbasw as base_imposto,
        estorno,
        case
            when linesort = ' ' then null
            else linesort
        end as linesort,
        try_to_date(ab, 'YYYYMMDD') as inicio_calculo,
        try_to_date(bis, 'YYYYMMDD') as fim_calculo,
        case
            when ktosl = ' ' then null
            else ktosl
        end as tipo_imposto,
        case
            when estorno = 'X' then nettobtr * -1
            else nettobtr
        end as receita,
        CAST(null as NUMBER) as consumo,
        CAST(null as NUMBER) as preco,
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
        itens_receita_base
),

final as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        belzeile,
        categoria_tarifa,
        setor_industrial,
        subclasse,
        belzart,
        escalao,
        base_imposto,
        estorno,
        linesort,
        inicio_calculo,
        fim_calculo,
        tipo_imposto,
        receita,
        consumo,
        preco,
        aliquota,
        operacao,
        sub_operacao,
        domicilio_fiscal
    from
        itens_receita_transformados
)

select * from final 
