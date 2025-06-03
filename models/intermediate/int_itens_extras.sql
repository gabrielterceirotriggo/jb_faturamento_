with q_itens_extras as (
    select
        int_documentos_faturamento.mes_competencia,
        int_documentos_faturamento.doc_calculo as documento_calculo,
        int_documentos_faturamento.doc_impressao as documento_impressao,
        int_documentos_faturamento.tipo_calculo,
        int_documentos_faturamento.tipo_documento,
        dberchz1.belzeile,
        dberchz1.branche as setor_industrial,
        dberchz1.tariftyp as categoria_tarifa,
        dberchz1.temp_area as subclasse,
        dberchz1.belzart,
        dberchz1.linesort,
        dberchz3.zonennr as escalao,
        null as tipo_imposto,

        dberchz3.preisbtr as preco,

        dberdlb.nettobtr as receita,

        dberdlb.sttax as base_imposto,

        0 as aliquota,
        dberdlb.hvorg as operacao,
        dberdlb.txjcd as domicilio_fiscal,
        int_documentos_faturamento.estorno,
        case
            when dberchz1.ab <> '00000000' then TO_DATE(dberchz1.ab, 'YYYYMMDD')
        end as inicio_calculo,

        case
            when
                dberchz1.bis <> '00000000'
                then TO_DATE(dberchz1.bis, 'YYYYMMDD')
        end as fim_calculo,

        case
            when
                int_documentos_faturamento.tipo_calculo = 'CM' and (
                    (
                        (dberchz1.v_abrmenge + dberchz1.n_abrmenge) > 0
                        and dberchz3.n_nettobtr_l < 0
                    )
                    or (
                        (dberchz1.v_abrmenge + dberchz1.n_abrmenge) < 0
                        and dberchz3.n_nettobtr_l > 0
                    )
                )
                then (dberchz1.v_abrmenge + dberchz1.n_abrmenge) * -1
            else dberchz1.v_abrmenge + dberchz1.n_abrmenge
        end as consumo,
        case
            when dberchz1.tvorg = ' ' then null
            else dberchz1.tvorg
        end as sub_operacao
    from
        {{ ref('int_documentos_faturamento') }} as int_documentos_faturamento
    left outer join
        {{ ref('stg_dberdlb') }} as dberdlb
        on
            int_documentos_faturamento.doc_impressao = dberdlb.printdoc
            and int_documentos_faturamento.doc_calculo = dberdlb.billdoc
    left outer join
        {{ ref('stg_dberchz1') }} as dberchz1
        on
            dberdlb.billdoc = dberchz1.belnr
            and dberdlb.billdocline = dberchz1.belzeile
    left outer join
        {{ ref('stg_dberchz3') }} as dberchz3
        on
            dberchz1.belnr = dberchz3.belnr
            and dberchz1.belzeile = dberchz3.belzeile
    where
        dberchz1.belzart in (
            'ZGSAT', 'ZGSNP', 'ZGSFP', 'ZGSRV', 'ZGSIT', 'ZPCAFP', 'ZPCANP',
            'ZPGFP', 'ZPGNP', 'ZPCAT', 'ZPGAT', 'ZDR1', 'ZDR2', 'ZDR3', 'ZDR4',
            'ZDR5', 'ZDR6', 'ZUR1', 'ZUR2', 'ZUR3', 'ZEUSD', 'ZRAMAL', 'ZEUSDB',
            'ZDCFP', 'ZDCFPL', 'ZDCGER', 'ZDCMFP', 'ZDCMNP', 'ZDCNP', 'ZDCNPL',
            'ZDCOMP', 'ZDCONL', 'ZDCONT', 'ZDCT'
        )
)

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

    estorno,
    case
        when estorno = 'X' then consumo * -1
        else consumo
    end as consumo,
    case
        when estorno = 'X' then receita * -1
        else receita
    end as receita,

    case
        when operacao = ' ' then null
        else operacao
    end as operacao,

    case
        when sub_operacao = ' ' then null
        else sub_operacao
    end as sub_operacao,
    case
        when domicilio_fiscal = ' ' then null
        else domicilio_fiscal
    end as domicilio_fiscal
from
    q_itens_extras
