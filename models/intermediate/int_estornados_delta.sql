with erch as (
    select
        mandt,
        belnr,
        bcreason
    from
        {{ ref('stg_erch') }}
),

q_estornados_pleno_fat as (
    {{ select_from_estornado('') }} {{ ref('int_estornados_pleno_fat') }}
),

q_estornos_pleno_fat as (
    {{ select_from_estornado('') }} {{ ref('int_estornos_pleno_fat') }}
),

q_estornados_pleno_fat_delta as (
    {{ select_from_estornado('') }} {{ ref('int_estornados_pleno_fat_delta') }}
),

q_estornos_pleno_fat_delta as (
    {{ select_from_estornado('') }} {{ ref('int_estornos_pleno_fat_delta') }}
),

q_estornados_ajuste_fat as (
    {{ select_from_estornado('') }} {{ ref('int_estornados_ajuste_fat') }}
),

q_estornados_ajuste_delta as (
    {{ select_from_estornado('') }} {{ ref('int_estornados_ajuste_delta') }}
),

documentos_estornados_unificados as (
    {{ select_from_estornado('q_estornados_pleno_fat') }}
    union all
    {{ select_from_estornado('q_estornos_pleno_fat') }}
    union all
    {{ select_from_estornado('q_estornados_pleno_fat_delta') }}
    union all
    {{ select_from_estornado('q_estornos_pleno_fat_delta') }}
    union all
    {{ select_from_estornado('q_estornados_ajuste_fat') }}
    union all
    {{ select_from_estornado('q_estornados_ajuste_delta') }}
),

registros_agrupados as (
    select
        mes_competencia,
        mes_referencia,
        documento_calculo,
        documento_impressao,
        fatura,
        instalacao,
        conta_contrato,
        parceiro_negocio,
        contrato,
        unidade_leitura,
        etapa,
        setor_industrial,
        grupo,
        categoria_tarifa,
        cliente_livre,
        subclasse,
        motivo_criacao_impressao,
        tipo_impressao,
        tipo_calculo,
        origem_documento,
        cnr,
        estorno_pleno,
        estorno_ajuste,
        reversao,
        cancelamento,
        fatura_virtual,
        minimo,
        valor_fatura,
        consumo_faturado,
        consumo_medido,
        eusd,
        eusdb,
        icms,
        icms_subvencao,
        pis,
        cofins,
        cip,
        retencao,
        receita_bandeiras,
        receita_consumo_faturado,
        tarifa,
        preco,
        correcao_monetaria,
        creditos,
        estornos,
        juros,
        multas,
        parcelamentos,
        outros_lancamentos,
        chave_reconciliacao,
        formulario_pagamento,
        domicilio_fiscal,
        inicio_calculo,
        fim_calculo,
        quantidade_dias,
        data_competencia,
        data_atribuicao_calculo,
        data_apresentacao,
        data_vencimento_original,
        data_previsao_leitura,
        data_criacao_impressao,
        usuario_criacao_impressao,
        data_criacao_calculo,
        usuario_criacao_calculo,
        documento_calculo_anterior,
        estrutura_regional_politica,
        ordem_faturamento,
        consumo_registrado,
        MAX(estornado) as estornado,
        MAX(documento_estorno_pleno) as documento_estorno_pleno,
        MAX(data_estorno_pleno) as data_estorno_pleno,
        MAX(motivo_estorno_pleno) as motivo_estorno_pleno,
        MAX(documento_estorno_ajuste) as documento_estorno_ajuste,
        MAX(data_estorno_ajuste) as data_estorno_ajuste,
        MAX(motivo_estorno_ajuste) as motivo_estorno_ajuste,
        MAX(valor_contabil) as valor_contabil,
        MAX(data_modificacao_impressao) as data_modificacao_impressao,
        MAX(usuario_modificacao_impressao) as usuario_modificacao_impressao,
        MAX(data_modificacao_calculo) as data_modificacao_calculo,
        MAX(usuario_modificacao_calculo) as usuario_modificacao_calculo,
        MIN(flag) as flag
    from documentos_estornados_unificados
    group by all
),

registros_ranqueados as (
    select *
    from registros_agrupados
    qualify ROW_NUMBER() over (
        partition by
            mes_competencia,
            documento_calculo,
            documento_impressao
        order by flag asc
    ) = 1
),

busca_motivos_estorno_ajuste as (
    select
        rr.mes_competencia,
        rr.mes_referencia,
        rr.documento_calculo,
        rr.documento_impressao,
        rr.fatura,
        rr.instalacao,
        rr.conta_contrato,
        rr.parceiro_negocio,
        rr.contrato,
        rr.unidade_leitura,
        rr.etapa,
        rr.setor_industrial,
        rr.grupo,
        rr.categoria_tarifa,
        rr.cliente_livre,
        rr.subclasse,
        rr.motivo_criacao_impressao,
        rr.tipo_impressao,
        rr.tipo_calculo,
        rr.origem_documento,
        rr.cnr,
        rr.estornado,
        rr.estorno_pleno,
        rr.estorno_ajuste,
        rr.reversao,
        rr.cancelamento,
        rr.fatura_virtual,
        rr.minimo,
        rr.documento_estorno_pleno,
        rr.data_estorno_pleno,
        rr.motivo_estorno_pleno,
        rr.documento_estorno_ajuste,
        rr.data_estorno_ajuste,
        rr.valor_fatura,
        rr.valor_contabil,
        rr.consumo_faturado,
        rr.consumo_medido,
        rr.eusd,
        rr.eusdb,
        rr.icms,
        rr.icms_subvencao,
        rr.pis,
        rr.cofins,
        rr.cip,
        rr.retencao,
        rr.receita_bandeiras,
        rr.receita_consumo_faturado,
        rr.tarifa,
        rr.preco,
        rr.correcao_monetaria,
        rr.creditos,
        rr.estornos,
        rr.juros,
        rr.multas,
        rr.parcelamentos,
        rr.outros_lancamentos,
        rr.chave_reconciliacao,
        rr.formulario_pagamento,
        rr.domicilio_fiscal,
        rr.inicio_calculo,
        rr.fim_calculo,
        rr.quantidade_dias,
        rr.data_competencia,
        rr.data_atribuicao_calculo,
        rr.data_apresentacao,
        rr.data_vencimento_original,
        rr.data_previsao_leitura,
        rr.data_criacao_impressao,
        rr.usuario_criacao_impressao,
        rr.data_modificacao_impressao,
        rr.usuario_modificacao_impressao,
        rr.data_criacao_calculo,
        rr.usuario_criacao_calculo,
        rr.data_modificacao_calculo,
        rr.usuario_modificacao_calculo,
        rr.documento_calculo_anterior,
        rr.estrutura_regional_politica,
        rr.ordem_faturamento,
        rr.consumo_registrado,
        rr.flag,
        case when e.bcreason = ' ' then null else e.bcreason end
            as motivo_estorno_ajuste
    from registros_ranqueados as rr
    left outer join erch as e
        on
            rr.documento_calculo = e.belnr
            and e.mandt = {{ mc_mandante(var('source_param')) }}
),

final as (
    {{ select_from_estornado('busca_motivos_estorno_ajuste') }}
)

select
    *,
    CURRENT_TIMESTAMP() as data_dados
from final
