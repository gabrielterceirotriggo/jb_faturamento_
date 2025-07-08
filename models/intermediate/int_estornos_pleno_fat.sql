with estornos_plenos_delta as (
    select
        mes_competencia,
        documento_impressao,
        motivo_criacao_impressao,
        tipo_impressao,
        data_criacao_impressao,
        usuario_criacao,
        data_modificacao_impressao,
        usuario_modificacao,
        data_competencia,
        data_vencimento_original,
        data_apresentacao,
        chave_reconciliacao,
        motivo_estorno_impressao,
        contrapartida,
        valor_total,
        estorno_pleno,
        fatura_virtual
    from
        {{ ref ('estornos_plenos_delta') }}
),

faturamento_historico as (
    {{ select_cols_fat() }} {{ ref('stg_faturamento_fat') }}
),

q_estornos_pleno_fat as (
    select
        epd.mes_competencia,
        fh.mes_referencia,
        fh.documento_calculo,
        epd.documento_impressao,
        fh.fatura,
        fh.instalacao,
        fh.conta_contrato,
        fh.parceiro_negocio,
        fh.contrato,
        fh.unidade_leitura,
        fh.etapa,
        fh.setor_industrial,
        fh.grupo,
        fh.categoria_tarifa,
        fh.cliente_livre,
        fh.subclasse,
        epd.motivo_criacao_impressao,
        epd.tipo_impressao,
        fh.tipo_calculo,
        fh.origem_documento,
        fh.cnr,
        null as estornado,
        epd.estorno_pleno,
        fh.estorno_ajuste,
        fh.reversao,
        fh.cancelamento,
        epd.fatura_virtual,
        fh.minimo,
        epd.documento_impressao as documento_estorno_pleno,
        epd.data_criacao_impressao as data_estorno_pleno,
        epd.motivo_estorno_impressao as motivo_estorno_pleno,
        fh.documento_estorno_ajuste,
        fh.data_estorno_ajuste,
        fh.motivo_estorno_ajuste,
        epd.chave_reconciliacao,
        fh.domicilio_fiscal,
        fh.inicio_calculo,
        fh.fim_calculo,
        epd.data_competencia,
        fh.data_atribuicao_calculo,
        fh.data_apresentacao,
        fh.data_vencimento_original,
        fh.data_previsao_leitura,
        fh.data_criacao_impressao,
        epd.usuario_criacao as usuario_criacao_impressao,
        epd.data_modificacao_impressao,
        fh.usuario_modificacao_impressao,
        fh.data_criacao_calculo,
        fh.usuario_criacao_calculo,
        fh.data_modificacao_calculo,
        fh.usuario_modificacao_calculo,
        fh.documento_calculo_anterior,
        fh.estrutura_regional_politica,
        null as ordem_faturamento,
        fh.consumo_registrado,
        2 as flag,
        fh.valor_fatura * -1 as valor_fatura,
        fh.valor_contabil * -1 as valor_contabil,
        fh.consumo_faturado * -1 as consumo_faturado,
        fh.consumo_medido * -1 as consumo_medido,
        fh.eusd * -1 as eusd,
        fh.eusdb * -1 as eusdb,
        fh.icms * -1 as icms,
        fh.icms_subvencao * -1 as icms_subvencao,
        fh.pis * -1 as pis,
        fh.cofins * -1 as cofins,
        fh.cip * -1 as cip,
        fh.retencao * -1 as retencao,
        fh.receita_bandeiras * -1 as receita_bandeiras,
        fh.receita_consumo_faturado * -1 as receita_consumo_faturado,
        fh.tarifa * -1 as tarifa,
        fh.preco * -1 as preco,
        fh.correcao_monetaria * -1 as correcao_monetaria,
        fh.creditos * -1 as creditos,
        fh.estornos * -1 as estornos,
        fh.juros * -1 as juros,
        fh.multas * -1 as multas,
        fh.parcelamentos * -1 as parcelamentos,
        fh.outros_lancamentos * -1 as outros_lancamentos,
        case
            when fh.formulario_pagamento = ' ' then null else
                fh.formulario_pagamento
        end as formulario_pagamento,
        fh.quantidade_dias * -1 as quantidade_dias
    from
        estornos_plenos_delta as epd
    inner join
        faturamento_historico as fh
        on epd.contrapartida = fh.documento_impressao
),

final as (
    {{ select_from_estornado('q_estornos_pleno_fat') }}
)

select * from final
