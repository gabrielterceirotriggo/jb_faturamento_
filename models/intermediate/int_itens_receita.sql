with q_itens_receita as (
    select
        int_documentos_faturamento.mes_competencia,
        int_documentos_faturamento.doc_calculo as documento_calculo,
        int_documentos_faturamento.doc_impressao as documento_impressao,
        null as belzeile,
        null as categoria_tarifa,
        null as setor_industrial,
        null as subclasse,
        int_documentos_faturamento.tipo_calculo,
        int_documentos_faturamento.tipo_documento,
        dberdl.belzart,
        '000' as escalao,
        dberdl.sbasw as base_imposto,
        int_documentos_faturamento.estorno,
        case
            when dberdl.linesort = ' ' then null
            else dberdl.linesort
        end as linesort,
        case
            when dberdl.ab <> '00000000' then TO_DATE(dberdl.ab, 'YYYYMMDD')
        end as inicio_calculo,
        case
            when dberdl.bis <> '00000000' then TO_DATE(dberdl.bis, 'YYYYMMDD')
        end as fim_calculo,
        case
            when dberdl.ktosl = ' ' then null
            else dberdl.ktosl
        end as tipo_imposto,
        case
            when
                int_documentos_faturamento.estorno = 'X'
                then dberdl.nettobtr * -1
            else dberdl.nettobtr
        end as receita,
        --dberdl.nettobtr AS receita,
        CAST(null as NUMBER) as consumo,
        CAST(null as NUMBER) as preco,
        case
            when dberdl.stprz = ' ' then 0
            else TRY_CAST(LTRIM(dberdl.stprz, ' ') as NUMBER(10, 3)) / 1000
        end as aliquota,
        case
            when dberdl.hvorg = ' ' then null
            else dberdl.hvorg
        end as operacao,
        case
            when dberdl.tvorg = ' ' then null
            else dberdl.tvorg
        end as sub_operacao,
        case
            when dberdl.txjcd = ' ' then null
            else dberdl.txjcd
        end as domicilio_fiscal
    from
        {{ ref('int_documentos_faturamento') }} as int_documentos_faturamento
    left outer join
        {{ ref('stg_dberdl') }} as dberdl
        on
            int_documentos_faturamento.doc_impressao = dberdl.printdoc
    where
        dberdl.xtotal_amnt = 'X'
)

select * from q_itens_receita
