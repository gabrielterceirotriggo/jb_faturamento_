with estornos_ajustes_delta as (
    select
        documento_calculo,
        data_criacao_calculo,
        usuario_criacao_calculo,
        motivo_estorno_calculo,
        documento_estorno_ajuste
    from
        {{ ref ('estornos_ajustes_delta') }}
),

faturamento_delta as (
    {{ select_cols_fat() }} {{ ref('faturamento_delta') }}
),

q_estornados_ajuste_delta as (
    select
        fd.mes_competencia,
        fd.mes_referencia,
        fd.documento_calculo,
        fd.documento_impressao,
        fd.fatura,
        fd.instalacao,
        fd.conta_contrato,
        fd.parceiro_negocio,
        fd.contrato,
        fd.unidade_leitura,
        fd.etapa,
        fd.setor_industrial,
        fd.grupo,
        fd.categoria_tarifa,
        fd.cliente_livre,
        fd.subclasse,
        fd.motivo_criacao_impressao,
        fd.tipo_impressao,
        fd.tipo_calculo,
        fd.origem_documento,
        fd.cnr,
        'x' as estornado,
        fd.estorno_pleno,
        fd.estorno_ajuste,
        fd.reversao,
        fd.cancelamento,
        fd.fatura_virtual,
        fd.minimo,
        fd.documento_estorno_pleno,
        fd.data_estorno_pleno,
        fd.motivo_estorno_pleno,
        ead.documento_calculo as documento_estorno_ajuste,
        ead.data_criacao_calculo as data_estorno_ajuste,
        ead.motivo_estorno_calculo as motivo_estorno_ajuste,
        fd.valor_fatura,
        fd.valor_contabil,
        fd.consumo_faturado,
        fd.consumo_medido,
        fd.eusd,
        fd.eusdb,
        fd.icms,
        fd.icms_subvencao,
        fd.pis,
        fd.cofins,
        fd.cip,
        fd.retencao,
        fd.receita_bandeiras,
        fd.receita_consumo_faturado,
        fd.tarifa,
        fd.preco,
        fd.correcao_monetaria,
        fd.creditos,
        fd.estornos,
        fd.juros,
        fd.multas,
        fd.parcelamentos,
        fd.outros_lancamentos,
        fd.chave_reconciliacao,
        fd.domicilio_fiscal,
        fd.inicio_calculo,
        fd.fim_calculo,
        fd.quantidade_dias,
        fd.data_competencia,
        fd.data_atribuicao_calculo,
        fd.data_apresentacao,
        fd.data_vencimento_original,
        fd.data_previsao_leitura,
        fd.data_criacao_impressao,
        fd.usuario_criacao_impressao,
        fd.data_modificacao_impressao,
        fd.usuario_modificacao_impressao,
        fd.data_criacao_calculo,
        fd.usuario_criacao_calculo,
        ead.data_criacao_calculo as data_modificacao_calculo,
        ead.usuario_criacao_calculo as usuario_modificacao_calculo,
        fd.documento_calculo_anterior,
        fd.estrutura_regional_politica,
        fd.ordem_faturamento,
        fd.consumo_registrado,
        1 as flag,
        case
            when fd.formulario_pagamento = ' ' then null else
                fd.formulario_pagamento
        end as formulario_pagamento
    from
        estornos_ajustes_delta as ead
    inner join
        faturamento_delta as fd
        on ead.documento_estorno_ajuste = fd.documento_calculo
    where
        fd.estorno_pleno is null
),

final as (
    {{ select_from_estornado('q_estornados_ajuste_delta') }}
)

select * from final
