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

faturamento_delta as (
    {{ select_cols_fat() }} {{ ref('faturamento_delta') }}
),

q_estornos_pleno_fat_delta as (
    select
        epd.mes_competencia,
        fd.mes_referencia,
        fd.documento_calculo,
        epd.documento_impressao,
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
        epd.motivo_criacao_impressao,
        epd.tipo_impressao,
        fd.tipo_calculo,
        fd.origem_documento,
        fd.cnr,
        null as estornado,
        epd.estorno_pleno,
        fd.estorno_ajuste,
        fd.reversao,
        fd.cancelamento,
        epd.fatura_virtual,
        fd.minimo,
        fd.documento_impressao as documento_estorno_pleno,
        epd.data_criacao_impressao as data_estorno_pleno,
        epd.motivo_estorno_impressao as motivo_estorno_pleno,
        fd.documento_estorno_ajuste,
        fd.data_estorno_ajuste,
        fd.motivo_estorno_ajuste,
        epd.chave_reconciliacao,
        fd.domicilio_fiscal,
        fd.inicio_calculo,
        fd.fim_calculo,
        epd.data_competencia,
        fd.data_atribuicao_calculo,
        epd.data_apresentacao,
        epd.data_vencimento_original,
        fd.data_previsao_leitura,
        epd.data_criacao_impressao,
        epd.usuario_criacao as usuario_criacao_impressao,
        fd.data_modificacao_impressao,
        fd.usuario_modificacao_impressao,
        fd.data_criacao_calculo,
        fd.usuario_criacao_calculo,
        fd.data_modificacao_calculo,
        fd.usuario_modificacao_calculo,
        fd.documento_calculo_anterior,
        fd.estrutura_regional_politica,
        null as ordem_faturamento,
        fd.consumo_registrado,
        1 as flag,
        fd.valor_fatura * -1 as valor_fatura,
        fd.valor_contabil * -1 as valor_contabil,
        fd.consumo_faturado * -1 as consumo_faturado,
        fd.consumo_medido * -1 as consumo_medido,
        fd.eusd * -1 as eusd,
        fd.eusdb * -1 as eusdb,
        fd.icms * -1 as icms,
        fd.icms_subvencao * -1 as icms_subvencao,
        fd.pis * -1 as pis,
        fd.cofins * -1 as cofins,
        fd.cip * -1 as cip,
        fd.retencao * -1 as retencao,
        fd.receita_bandeiras * -1 as receita_bandeiras,
        fd.receita_consumo_faturado * -1 as receita_consumo_faturado,
        fd.tarifa * -1 as tarifa,
        fd.preco * -1 as preco,
        fd.correcao_monetaria * -1 as correcao_monetaria,
        fd.creditos * -1 as creditos,
        fd.estornos * -1 as estornos,
        fd.juros * -1 as juros,
        fd.multas * -1 as multas,
        fd.parcelamentos * -1 as parcelamentos,
        fd.outros_lancamentos * -1 as outros_lancamentos,
        case
            when fd.formulario_pagamento = ' ' then null else
                fd.formulario_pagamento
        end as formulario_pagamento,
        fd.quantidade_dias * -1 as quantidade_dias
    from
        estornos_plenos_delta as epd
    inner join
        faturamento_delta as fd
        on epd.contrapartida = fd.documento_impressao
),

final as (
    {{ select_from_estornado('q_estornos_pleno_fat_delta') }}
)

select * from final
