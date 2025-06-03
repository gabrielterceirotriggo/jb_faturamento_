with int_documentos_faturamento as (
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
        printdocline,
        billdoc,
        billdocline,
        hvorg,
        bukrs,
        xtotal_amnt,
        vertrag,
        abpopbel,
        sparte,
        txjcd,
        mwskz,
        nettobtr,
        sttax,
        ztipo,
        zordem,
        data_dados
    from
        {{ ref ('stg_dberdlb') }}
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

dberchz3 as (
    select
        mandt,
        belnr,
        belzeile,
        zonennr,
        preisbtr,
        n_nettobtr_l,
        nettobtr,
        data_dados
    from
        {{ ref('stg_dberchz3') }}
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
        n_abrmenge,
        data_dados
    from
        {{ ref('stg_dberchz5') }}
),

dberchz7 as (
    select
        mandt,
        belnr,
        belzeile,
        mwskz,
        ermwskz,
        nettobtr,
        twaers,
        preistuf,
        preistyp,
        preis,
        preiszus,
        vonzone,
        biszone,
        zonennr,
        preisbtr,
        mngbasis,
        preigkl,
        urpreis,
        preiadd,
        preifakt,
        opmult,
        txdat_kk,
        prctr,
        kostl,
        ps_psp_pnr,
        aufnr,
        paobjnr,
        paobjnr_s,
        gsber,
        aperiodic,
        grossgroup,
        bruttozeile,
        bupla,
        line_class,
        preisart,
        segment,
        v_nettobtr_l,
        n_nettobtr_l,
        data_dados
    from
        {{ ref('stg_dberchz7') }}
),

q_itens_consumo as (
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
        -- Não tinha na tabela
        dberdlb.hvorg as operacao,
        dberchz1.tvorg as sub_operacao,
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
                int_documentos_faturamento.tipo_calculo = 'CM'
                and (
                    (
                        (dberchz1.v_abrmenge + dberchz1.n_abrmenge) > 0
                        and dberchz3.nettobtr < 0
                    )
                    or (
                        (dberchz1.v_abrmenge + dberchz1.n_abrmenge) < 0
                        and dberchz3.nettobtr > 0
                    )
                )
                then (dberchz1.v_abrmenge + dberchz1.n_abrmenge) * -1
            else dberchz1.v_abrmenge + dberchz1.n_abrmenge
        end as consumo
    from
        int_documentos_faturamento
    left join dberdlb
        on
            int_documentos_faturamento.mandt = dberdlb.mandt
            and int_documentos_faturamento.doc_impressao = dberdlb.printdoc
            and int_documentos_faturamento.doc_calculo = dberdlb.billdoc
    left join dberchz1
        on
            dberdlb.mandt = dberchz1.mandt
            and dberdlb.billdoc = dberchz1.belnr
            and dberdlb.billdocline = dberchz1.belzeile
    left join dberchz3
        on
            dberchz1.mandt = dberchz3.mandt
            and dberchz1.belnr = dberchz3.belnr
            and dberchz1.belzeile = dberchz3.belzeile
    where
        dberdlb.xtotal_amnt = 'X'
        --AND int_documentos_faturamento.MANDT IN (401, 402, 403, 404)
),

q_itens_consumo2 as (
    select
        int_documentos_faturamento.mes_competencia,
        int_documentos_faturamento.doc_calculo as documento_calculo,
        int_documentos_faturamento.doc_impressao as documento_impressao,
        int_documentos_faturamento.tipo_calculo,
        int_documentos_faturamento.tipo_documento,
        dberchz5.belzeile,
        dberchz5.branche as setor_industrial,
        dberchz5.tariftyp as categoria_tarifa,
        dberchz5.temp_area as subclasse,
        dberchz5.belzart,
        dberchz5.linesort,
        dberchz7.zonennr as escalao,
        null as tipo_imposto,
        dberchz7.preisbtr as preco,
        dberdlb.nettobtr as receita,
        dberdlb.sttax as base_imposto,
        0 as aliquota,
        -- Não tinha na tabela
        dberdlb.hvorg as operacao,
        dberchz5.tvorg as sub_operacao,
        dberdlb.txjcd as domicilio_fiscal,
        int_documentos_faturamento.estorno,
        case
            when dberchz5.ab <> '00000000' then TO_DATE(dberchz5.ab, 'YYYYMMDD')
        end as inicio_calculo,
        case
            when
                dberchz5.bis <> '00000000'
                then TO_DATE(dberchz5.bis, 'YYYYMMDD')
        end as fim_calculo,
        case
            when
                int_documentos_faturamento.tipo_calculo = 'CM'
                and (
                    (
                        (dberchz5.v_abrmenge + dberchz5.n_abrmenge) > 0
                        and dberchz7.nettobtr < 0
                    )
                    or (
                        (dberchz5.v_abrmenge + dberchz5.n_abrmenge) < 0
                        and dberchz7.nettobtr > 0
                    )
                )
                then (dberchz5.v_abrmenge + dberchz5.n_abrmenge) * -1
            else dberchz5.v_abrmenge + dberchz5.n_abrmenge
        end as consumo
    from
        int_documentos_faturamento
    left join dberdlb
        on
            int_documentos_faturamento.mandt = dberdlb.mandt
            and int_documentos_faturamento.doc_impressao = dberdlb.printdoc
            and int_documentos_faturamento.doc_calculo = dberdlb.billdoc
    left join dberchz5
        on
            dberdlb.mandt = dberchz5.mandt
            and dberdlb.billdoc = dberchz5.belnr
            and dberdlb.billdocline = dberchz5.belzeile
    left join dberchz7
        on
            dberchz5.mandt = dberchz7.mandt
            and dberchz5.belnr = dberchz7.belnr
            and dberchz5.belzeile = dberchz7.belzeile
    where
        dberdlb.xtotal_amnt = 'X'
        --AND int_documentos_faturamento.MANDT IN (401, 402, 403, 404)
),

final1 as (
    select
        q_itens_consumo.mes_competencia,
        q_itens_consumo.documento_calculo,
        q_itens_consumo.documento_impressao,
        q_itens_consumo.tipo_calculo,
        q_itens_consumo.tipo_documento,
        q_itens_consumo.belzeile,
        q_itens_consumo.setor_industrial,
        q_itens_consumo.categoria_tarifa,
        q_itens_consumo.subclasse,
        q_itens_consumo.belzart,
        q_itens_consumo.linesort,
        -- Não tinha na tabela
        q_itens_consumo.escalao,
        q_itens_consumo.inicio_calculo,
        q_itens_consumo.fim_calculo,
        q_itens_consumo.tipo_imposto,
        q_itens_consumo.preco,
        q_itens_consumo.base_imposto,
        -- Não tinha na tabela
        q_itens_consumo.aliquota,
        q_itens_consumo.operacao,
        q_itens_consumo.domicilio_fiscal,
        q_itens_consumo.estorno,
        case
            when q_itens_consumo.estorno = 'X'
                then q_itens_consumo.consumo * -1
            else q_itens_consumo.consumo
        end as consumo,
        case
            when q_itens_consumo.estorno = 'X'
                then q_itens_consumo.receita * -1
            else q_itens_consumo.receita
        end as receita,
        case
            when q_itens_consumo.sub_operacao = ' ' then null
            else q_itens_consumo.sub_operacao
        end as sub_operacao
    from
        q_itens_consumo
),

final2 as (
    select
        q_itens_consumo2.mes_competencia,
        q_itens_consumo2.documento_calculo,
        q_itens_consumo2.documento_impressao,
        q_itens_consumo2.tipo_calculo,
        q_itens_consumo2.tipo_documento,
        q_itens_consumo2.belzeile,
        q_itens_consumo2.setor_industrial,
        q_itens_consumo2.categoria_tarifa,
        q_itens_consumo2.subclasse,
        q_itens_consumo2.belzart,
        q_itens_consumo2.linesort,
        -- Não tinha na tabela
        q_itens_consumo2.escalao,
        q_itens_consumo2.inicio_calculo,
        q_itens_consumo2.fim_calculo,
        q_itens_consumo2.tipo_imposto,
        q_itens_consumo2.preco,
        q_itens_consumo2.base_imposto,
        -- Não tinha na tabela
        q_itens_consumo2.aliquota,
        q_itens_consumo2.operacao,
        q_itens_consumo2.domicilio_fiscal,
        q_itens_consumo2.estorno,
        case
            when q_itens_consumo2.estorno = 'X'
                then q_itens_consumo2.consumo * -1
            else q_itens_consumo2.consumo
        end as consumo,
        case
            when q_itens_consumo2.estorno = 'X'
                then q_itens_consumo2.receita * -1
            else q_itens_consumo2.receita
        end as receita,
        case
            when q_itens_consumo2.sub_operacao = ' ' then null
            else q_itens_consumo2.sub_operacao
        end as sub_operacao
    from
        q_itens_consumo2
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
    final1
union all
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
    final2
