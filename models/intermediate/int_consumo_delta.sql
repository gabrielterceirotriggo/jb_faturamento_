with dt as (
    select
        int_calculo_delta.mes_competencia,
        int_calculo_delta.documento_calculo,
        int_calculo_delta.documento_impressao,
        itens_faturamento.linha,
        itens_faturamento.setor_industrial,
        itens_faturamento.categoria_tarifa,
        itens_faturamento.subclasse,
        itens_faturamento.item_documento,
        itens_faturamento.flag,
        case
            when int_calculo_delta.mes_referencia >= '202311'
                then 
                    case
                        when itens_faturamento.flag = 'C'
                        and itens_faturamento.item_documento in (
                            'ZEAT',
                            'ZBXE',
                            'ZEANP',
	                        'ZEAIT',
                            'ZEAFP',
                            'ZCMFNP',
	                        'ZIPFTE',
                            'ZEARV',
                            'ZEMFUP',
	                        'ZTUSNP',
                            'ZTUSFP',
                            'ZEAFPC',
	                        'ZEAITC',
                            'ZEANPC',
                            'ZEARVC',
	                        'ZEATC',
                            'ZBXEC'
                        ) then itens_faturamento.consumo else 0
                    end
                    -
                    case
                        when itens_faturamento.flag = 'C'
                        and itens_faturamento.item_documento in (
                            'ZEGAT',
                            'ZEGFP',
                            'ZEGIT',
                            'ZEGNP',
                            'ZEGRV'
                        ) then itens_faturamento.consumo else 0
                    end
            else
                case
                    when itens_faturamento.flag = 'C'
                    and itens_faturamento.item_documento in (
                        'ZEAT',
                        'ZBXE',
                        'ZEANP',
	                    'ZEAIT',
                        'ZEAFP',
                        'ZCMFNP',
	                    'ZIPFTE',
                        'ZEARV',
                        'ZEMFUP',
	                    'ZTUSNP',
                        'ZTUSFP'
                    ) then itens_faturamento.consumo else 0
                end
        end as consumo_faturado,
        case
            when
                itens_faturamento.flag = 'M'
                and itens_faturamento.item_documento in (
                    'ZRCAT', 'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV'
                )
                then itens_faturamento.consumo
            else 0
        end as consumo_medido,
        case
            when
                itens_faturamento.flag = 'D'
                and itens_faturamento.item_documento in ('ZEUSD')
                then itens_faturamento.receita
            else 0
        end as eusd,
        case
            when
                itens_faturamento.flag = 'D'
                and itens_faturamento.item_documento in ('ZEUSDB')
                then itens_faturamento.receita
            else 0
        end as eusdb,
        case
            when
                itens_faturamento.flag = 'R'
                and itens_faturamento.tipo_imposto in ('MW2')
                then itens_faturamento.receita
            else 0
        end as icms,
        case
            when
                itens_faturamento.flag = 'R'
                and itens_faturamento.operacao in ('ZBXR')
                or itens_faturamento.item_ordenacao in ('ZBTB')
                and itens_faturamento.tipo_imposto in ('MW2')
                then itens_faturamento.receita
            else 0
        end as icms_subvencao,
        case
            when
                itens_faturamento.flag = 'R'
                and itens_faturamento.tipo_imposto in ('PIS')
                then itens_faturamento.receita
            else 0
        end as pis,
        case
            when
                itens_faturamento.flag = 'R'
                and itens_faturamento.tipo_imposto in ('COF')
                then itens_faturamento.receita
            else 0
        end as cofins,
        case
            when
                itens_faturamento.flag = 'R'
                and itens_faturamento.operacao in (
                    'CIP1', 'CIP2', 'CIP3', 'CIP4'
                )
                then itens_faturamento.receita
            else 0
        end as cip,
        case
            when itens_faturamento.item_documento = 'WHTAX'
                then itens_faturamento.receita
            else 0
        end as retencao,
        case
            when
                itens_faturamento.item_ordenacao in
                (
                    'ZEAT',
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
                    'ZCRI'
                )
                then itens_faturamento.preco
            else 0
        end as tarifa,
        case
            when
                itens_faturamento.item_ordenacao in
                ('ZDAM', 'ZDVM')
                then itens_faturamento.receita
            else 0
        end as receita_bandeiras,
        case
            when int_calculo_delta.mes_referencia >= '202311'
                then
                    case
                        when
                            itens_faturamento.item_ordenacao in
                            (
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
                                'ZTIC',
                                'ZTNC',
                                'ZTCR',
                                'ZTAC'
                            )
                            then itens_faturamento.receita
                        else 0
                    end
            when
                itens_faturamento.item_ordenacao in
                (
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
                    'ZTIT', 'ZCRI'
                )
                then itens_faturamento.receita
            else 0
        end as receita_consumo_faturado,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'CORRECAO MONETARIA'
                then itens_faturamento.receita
            else 0
        end as correcao_monetaria,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'CREDITO'
                then itens_faturamento.receita
            else 0
        end as creditos,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'ESTORNO'
                then itens_faturamento.receita
            else 0
        end as estornos,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'JUROS'
                then itens_faturamento.receita
            else 0
        end as juros,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'MULTA'
                then itens_faturamento.receita
            else 0
        end as multas,
        case
            when
                itens_faturamento.flag in ('R')
                and faturamento_operacoes.bloco = 'PARCELAMENTO'
                then itens_faturamento.receita
            else 0
        end as parcelamentos
    from
        {{ ref ('int_calculo_delta') }} as int_calculo_delta
    inner join
        {{ ref ('itens_faturamento') }} as itens_faturamento
        on
            int_calculo_delta.mes_competencia
            = itens_faturamento.mes_competencia
            and int_calculo_delta.documento_calculo
            = itens_faturamento.documento_calculo
            and int_calculo_delta.documento_impressao
            = itens_faturamento.documento_impressao
    left outer join
        {{ ref ('stg_faturamento_operacoes') }} as faturamento_operacoes
        on
            itens_faturamento.operacao = faturamento_operacoes.operacao
            and itens_faturamento.sub_operacao
            = faturamento_operacoes.sub_operacao
    group by all

),

{# q_tarifa as (
    select distinct --avaliar necessidade
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        dt.tarifa
    from
        dt
), #}

q_soma_tarifa as (
    select distinct
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        sum(dt.tarifa) as tarifa
    from
        dt
    group by
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao
),

q_soma as (
    select
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        sum(consumo_faturado) as consumo_faturado,
        case
            when
                sum(case
                    when dt.flag = 'M' and dt.item_documento in ('ZRCAT')
                        then dt.consumo_medido
                    else 0
                end) <> 0
                then
                    sum(case
                        when
                            dt.flag = 'M' and dt.item_documento in ('ZRCAT')
                            then dt.consumo_medido
                        else 0
                    end)
            else
                sum(case
                    when
                        dt.flag = 'M'
                        and dt.item_documento in (
                            'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV'
                        )
                        then dt.consumo_medido
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
        sum(tarifa) as tarifa,
        sum(correcao_monetaria) as correcao_monetaria,
        sum(creditos) as creditos,
        sum(estornos) as estornos,
        sum(juros) as juros,
        sum(multas) as multas,
        sum(parcelamentos) as parcelamentos
    from
        dt
    group by
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao
),

q_trata as (
    select
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        dt.setor_industrial,
        dt.categoria_tarifa,
        dt.subclasse,
        {# coalesce(cast(dt.linha as INT), 0) as linha #}
        case
            when dt.linha is null then 0
            else cast(dt.linha as INT)
        end as linha
    from
        dt
    group by
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        linha,
        dt.setor_industrial,
        dt.categoria_tarifa,
        dt.subclasse
),

{# q_order as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        linha,
        setor_industrial,
        categoria_tarifa,
        subclasse
    from
        q_trata
    order by
        mes_competencia asc,
        documento_calculo asc,
        documento_impressao asc,
        linha desc
),

q_rank as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        linha,
        setor_industrial,
        categoria_tarifa,
        subclasse,
        row_number() over (
            partition by mes_competencia, documento_calculo, documento_impressao
            order by linha desc
        ) as posicao
    from
        q_order
), #}

q_filtro as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        setor_industrial,
        categoria_tarifa,
        subclasse
    from
        q_trata
    qualify ROW_NUMBER() over (
        partition by
            mes_competencia,
            documento_calculo,
            documento_impressao
        order by
            mes_competencia asc,
            documento_calculo asc,
            documento_impressao asc,
            linha desc
    ) = 1
)

select
    q_filtro.mes_competencia,
    q_filtro.documento_calculo,
    q_filtro.documento_impressao,
    q_filtro.setor_industrial,
    q_filtro.categoria_tarifa,
    q_filtro.subclasse,
    q_soma.consumo_faturado,
    q_soma.consumo_medido,
    q_soma.eusd,
    q_soma.eusdb,
    q_soma.icms,
    q_soma.icms_subvencao,
    q_soma.pis,
    q_soma.cofins,
    q_soma.cip,
    q_soma.retencao,
    q_soma.receita_bandeiras,
    q_soma.receita_consumo_faturado,
    q_soma.tarifa,
    q_soma.correcao_monetaria,
    q_soma.creditos,
    q_soma.estornos,
    q_soma.juros,
    q_soma.multas,
    q_soma.parcelamentos
from
    q_filtro
left outer join q_soma
    on
        q_filtro.mes_competencia = q_soma.mes_competencia
        and q_filtro.documento_calculo = q_soma.documento_calculo
        and q_filtro.documento_impressao = q_soma.documento_impressao
left outer join q_soma_tarifa
    on
        q_filtro.mes_competencia = q_soma_tarifa.mes_competencia
        and q_filtro.documento_calculo = q_soma_tarifa.documento_calculo
        and q_filtro.documento_impressao = q_soma_tarifa.documento_impressao
