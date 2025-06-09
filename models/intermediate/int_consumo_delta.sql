with calculo_delta as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        mes_referencia
    from
        {{ ref ('int_calculo_delta') }}
),

itens_faturamento as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        item_documento,
        flag,
        consumo,
        receita,
        tipo_imposto,
        operacao,
        sub_operacao,
        item_ordenacao,
        preco
    from
        {{ ref ('itens_faturamento') }}
),

faturamento_operacoes as (
    select
        operacao,
        sub_operacao,
        bloco
    from
        {{ ref ('stg_faturamento_operacoes') }}
),

dados_consumo_calculados as (
    select
        cd.mes_competencia,
        cd.documento_calculo,
        cd.documento_impressao,
        itf.linha,
        itf.setor_industrial,
        itf.categoria_tarifa,
        itf.subclasse,
        itf.flag,
        itf.item_documento,
        case
            when cd.mes_referencia >= '202311'
                then
                    case
                        when
                            itf.flag = 'C'
                            and itf.item_documento in (
                                'ZEAT',
                                'ZBXE',
                                'ZEANP',
                                'ZEAIT',
                                'ZEAFP',
                                'ZCMFNP',
                                'ZIPFTE', 'ZEARV', 'ZEMFUP', 'ZTUSNP', 'ZTUSFP',
                                'ZEAFPC',
                                'ZEAITC',
                                'ZEANPC',
                                'ZEARVC',
                                'ZEATC',
                                'ZBXEC'
                            ) then itf.consumo
                        else 0
                    end
                    -
                    case
                        when
                            itf.flag = 'C'
                            and itf.item_documento in (
                                'ZEGAT', 'ZEGFP', 'ZEGIT', 'ZEGNP', 'ZEGRV'
                            ) then itf.consumo
                        else 0
                    end
            when
                itf.flag = 'C'
                and itf.item_documento in (
                    'ZEAT', 'ZBXE', 'ZEANP', 'ZEAIT', 'ZEAFP', 'ZCMFNP',
                    'ZIPFTE', 'ZEARV', 'ZEMFUP', 'ZTUSNP', 'ZTUSFP'
                ) then itf.consumo
            else 0
        end as consumo_faturado,
        case
            when
                itf.flag = 'M'
                and itf.item_documento in (
                    'ZRCAT', 'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV'
                )
                then itf.consumo
            else 0
        end as consumo_medido,
        case
            when
                itf.flag = 'D' and itf.item_documento = 'ZEUSD'
                then itf.receita
            else 0
        end as eusd,
        case
            when
                itf.flag = 'D' and itf.item_documento = 'ZEUSDB'
                then itf.receita
            else 0
        end as eusdb,
        case
            when
                itf.flag = 'R' and itf.tipo_imposto = 'MW2'
                then itf.receita
            else 0
        end as icms,
        case
            when
                itf.flag = 'R'
                and (
                    itf.operacao = 'ZBXR'
                    or (
                        itf.item_ordenacao = 'ZBTB'
                        and itf.tipo_imposto = 'MW2'
                    )
                )
                then itf.receita
            else 0
        end as icms_subvencao,
        case
            when
                itf.flag = 'R' and itf.tipo_imposto = 'PIS'
                then itf.receita
            else 0
        end as pis,
        case
            when
                itf.flag = 'R' and itf.tipo_imposto = 'COF'
                then itf.receita
            else 0
        end as cofins,
        case
            when
                itf.flag = 'R'
                and itf.operacao in ('CIP1', 'CIP2', 'CIP3', 'CIP4')
                then itf.receita
            else 0
        end as cip,
        case
            when itf.item_documento = 'WHTAX' then itf.receita else 0
        end as retencao,
        case
            when itf.item_ordenacao in ('ZDAM', 'ZDVM') then itf.receita else 0
        end as receita_bandeiras,
        case
            when cd.mes_referencia >= '202311'
                then
                    case
                        when itf.item_ordenacao in (
                            'ZEAT',
                            'ZBXE',
                            'ZBXT',
                            'ZEFP',
                            'ZENP',
                            'ZTFP',
                            'ZTNP',
                            'ZMFB',
                            'ZMUE',
                            'ZMUT',
                            'ZEIP',
                            'ZTIP',
                            'ZTAT',
                            'ZTRV',
                            'ZERV',
                            'ZEIT',
                            'ZTIT',
                            'ZCRI',
                            'ZEGN',
                            'ZEGR',
                            'ZEGI',
                            'ZEGF',
                            'ZEGT',
                            'ZTGN',
                            'ZTGR',
                            'ZTGI',
                            'ZTGF',
                            'ZTGT',
                            'ZBEC',
                            'ZEFC',
                            'ZEIC',
                            'ZENC',
                            'ZECR',
                            'ZEAC',
                            'ZTFC',
                            'ZTIC', 'ZTNC', 'ZTCR', 'ZTAC'
                        ) then itf.receita else 0
                    end
            when itf.item_ordenacao in (
                'ZEAT', 'ZBXE', 'ZBXT', 'ZEFP', 'ZENP', 'ZTFP', 'ZTNP',
                'ZMFB', 'ZMUE', 'ZMUT', 'ZEIP', 'ZTIP', 'ZTAT', 'ZTRV',
                'ZERV', 'ZEIT', 'ZTIT', 'ZCRI'
            ) then itf.receita
            else 0
        end as receita_consumo_faturado,
        case
            when itf.item_ordenacao in (
                'ZEAT', 'ZEFP', 'ZENP', 'ZTFP', 'ZTNP', 'ZMFB', 'ZMUE', 'ZMUT',
                'ZEIP', 'ZTIP', 'ZTAT', 'ZTRV', 'ZERV', 'ZEIT', 'ZTIT', 'ZCRI'
            ) then itf.preco else 0
        end as tarifa,
        case
            when
                itf.flag = 'R' and fo.bloco = 'CORRECAO MONETARIA'
                then itf.receita
            else 0
        end as correcao_monetaria,
        case
            when itf.flag = 'R' and fo.bloco = 'CREDITO' then itf.receita else 0
        end as creditos,
        case
            when itf.flag = 'R' and fo.bloco = 'ESTORNO' then itf.receita else 0
        end as estornos,
        case
            when itf.flag = 'R' and fo.bloco = 'JUROS' then itf.receita else 0
        end as juros,
        case
            when itf.flag = 'R' and fo.bloco = 'MULTA' then itf.receita else 0
        end as multas,
        case
            when
                itf.flag = 'R' and fo.bloco = 'PARCELAMENTO'
                then itf.receita
            else 0
        end as parcelamentos
    from
        calculo_delta as cd
    inner join
        itens_faturamento as itf
        on
            cd.mes_competencia = itf.mes_competencia
            and cd.documento_calculo = itf.documento_calculo
            and cd.documento_impressao = itf.documento_impressao
    left outer join
        faturamento_operacoes as fo
        on
            itf.operacao = fo.operacao
            and itf.sub_operacao = fo.sub_operacao
),

consumo_agregado as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        sum(consumo_faturado) as consumo_faturado,
        case
            when
                sum(case
                    when flag = 'M' and item_documento in ('ZRCAT')
                        then consumo_medido
                    else 0
                end) <> 0
                then
                    sum(case
                        when
                            flag = 'M' and item_documento in ('ZRCAT')
                            then consumo_medido
                        else 0
                    end)
            else
                sum(case
                    when
                        flag = 'M'
                        and item_documento in (
                            'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV'
                        )
                        then consumo_medido
                    else 0
                end)
        end as consumo_medido,
        sum(eusd) as eusd,
        sum(eusdb) as eusdb,
        sum(icms) as icms,
        sum(icms_subvencao) as icms_subvencao,
        sum(pis) as pis,
        sum(cofins) as cofins,
        sum(cip) as cip,
        sum(retencao) as retencao,
        sum(receita_bandeiras) as receita_bandeiras,
        sum(receita_consumo_faturado) as receita_consumo_faturado,
        sum(correcao_monetaria) as correcao_monetaria,
        sum(creditos) as creditos,
        sum(estornos) as estornos,
        sum(juros) as juros,
        sum(multas) as multas,
        sum(parcelamentos) as parcelamentos
    from
        dados_consumo_calculados
    group by
        mes_competencia,
        documento_calculo,
        documento_impressao
),

tarifa_agregada as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        sum(tarifa) as tarifa
    from
        (
            select distinct
                mes_competencia,
                documento_calculo,
                documento_impressao,
                tarifa
            from
                dados_consumo_calculados
        )
    group by
        mes_competencia,
        documento_calculo,
        documento_impressao
),

metadados_faturamento_recentes as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        setor_industrial,
        categoria_tarifa,
        subclasse
    from
        dados_consumo_calculados
    qualify row_number() over (
        partition by
            mes_competencia,
            documento_calculo,
            documento_impressao
        order by
            coalesce(cast(linha as int), 0) desc
    ) = 1
),

final as (
    select
        mfr.mes_competencia,
        mfr.documento_calculo,
        mfr.documento_impressao,
        mfr.setor_industrial,
        mfr.categoria_tarifa,
        mfr.subclasse,
        ca.consumo_faturado,
        ca.consumo_medido,
        ca.eusd,
        ca.eusdb,
        ca.icms,
        ca.icms_subvencao,
        ca.pis,
        ca.cofins,
        ca.cip,
        ca.retencao,
        ca.receita_bandeiras,
        ca.receita_consumo_faturado,
        ta.tarifa,
        ca.correcao_monetaria,
        ca.creditos,
        ca.estornos,
        ca.juros,
        ca.multas,
        ca.parcelamentos
    from
        metadados_faturamento_recentes as mfr
    left outer join
        consumo_agregado as ca
        on
            mfr.mes_competencia = ca.mes_competencia
            and mfr.documento_calculo = ca.documento_calculo
            and mfr.documento_impressao = ca.documento_impressao
    left outer join
        tarifa_agregada as ta
        on
            mfr.mes_competencia = ta.mes_competencia
            and mfr.documento_calculo = ta.documento_calculo
            and mfr.documento_impressao = ta.documento_impressao
)

select * from final
