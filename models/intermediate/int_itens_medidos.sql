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
        when dberchz1.bis <> '00000000' then TO_DATE(dberchz1.bis, 'YYYYMMDD')
    end as fim_calculo,
    case
        when
            int_documentos_faturamento.tipo_calculo = 'CM'
            and (
                (
                    (dberchz1.v_abrmenge + dberchz1.n_abrmenge) > 0
                    and dberchz3.nettobtr < 0
                )
                or
                (
                    (dberchz1.v_abrmenge + dberchz1.n_abrmenge) < 0
                    and dberchz3.nettobtr > 0
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
left outer join
    {{ ref('stg_zfatt057_ophist') }} as zfatt057_ophist
    on
        dberchz1.belzart = zfatt057_ophist.belzart
        and dberchz1.ein01 = zfatt057_ophist.operand
where
    zfatt057_ophist.ez_abrmenge_flag = 'X'
    and dberdlb.xtotal_amnt <> 'X'
