with int_consumo_delta as (
    select
        mes_competencia,
        documento_calculo,
        documento_impressao,
        setor_industrial,
        categoria_tarifa,
        subclasse,
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
        correcao_monetaria,
        creditos,
        estornos,
        juros,
        multas,
        parcelamentos
    from
        {{ ref ('int_consumo_delta') }}
),

int_calculo_delta as (
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
        motivo_criacao_impressao,
        tipo_impressao,
        tipo_calculo,
        origem_documento,
        cnr,
        estornado,
        estorno_pleno,
        estorno_ajuste,
        reversao,
        cancelamento,
        fatura_virtual,
        minimo,
        inicio_calculo,
        fim_calculo,
        quantidade_dias,
        documento_estorno_pleno,
        data_estorno_pleno,
        motivo_estorno_pleno,
        documento_estorno_ajuste,
        data_estorno_ajuste,
        motivo_estorno_ajuste,
        valor_fatura,
        valor_contabil,
        chave_reconciliacao,
        formulario_pagamento,
        domicilio_fiscal,
        data_competencia,
        data_atribuicao_calculo,
        data_apresentacao,
        data_vencimento_original,
        data_previsao_leitura,
        data_criacao_impressao,
        usuario_criacao_impressao,
        data_modificacao_impressao,
        usuario_modificacao_impressao,
        data_criacao_calculo,
        usuario_criacao_calculo,
        data_modificacao_calculo,
        usuario_modificacao_calculo,
        documento_calculo_anterior,
        estrutura_regional_politica
    from
        {{ ref ('int_calculo_delta') }}
),

int_consumo_registrado as (
    select
        mes_competencia,
        documento_calculo,
        consumo_registrado,
        documento_impressao
    from
        {{ ref ('int_consumo_registrado') }}
)

select
    int_calculo_delta.mes_competencia,
    int_calculo_delta.mes_referencia,
    int_calculo_delta.documento_calculo,
    int_calculo_delta.documento_impressao,
    int_calculo_delta.fatura,
    int_calculo_delta.instalacao,
    int_calculo_delta.conta_contrato,
    int_calculo_delta.parceiro_negocio,
    int_calculo_delta.contrato,
    int_calculo_delta.unidade_leitura,
    int_calculo_delta.etapa,
    int_consumo_delta.setor_industrial,
    int_consumo_delta.categoria_tarifa,
    int_consumo_delta.subclasse,
    int_calculo_delta.motivo_criacao_impressao,
    int_calculo_delta.tipo_calculo,
    int_calculo_delta.origem_documento,
    int_calculo_delta.cnr,
    int_calculo_delta.estornado,
    int_calculo_delta.estorno_pleno,
    int_calculo_delta.estorno_ajuste,
    int_calculo_delta.reversao,
    int_calculo_delta.cancelamento,
    int_calculo_delta.fatura_virtual,
    int_calculo_delta.minimo,
    int_calculo_delta.documento_estorno_pleno,
    int_calculo_delta.data_estorno_pleno,
    int_calculo_delta.motivo_estorno_pleno,
    int_calculo_delta.documento_estorno_ajuste,
    int_calculo_delta.data_estorno_ajuste,
    int_calculo_delta.motivo_estorno_ajuste,
    int_calculo_delta.valor_fatura,
    int_calculo_delta.valor_contabil,
    int_consumo_delta.consumo_faturado,
    int_consumo_delta.consumo_medido,
    int_consumo_delta.eusd,
    int_consumo_delta.eusdb,
    int_consumo_delta.icms,
    int_consumo_delta.icms_subvencao,
    int_consumo_delta.pis,
    int_consumo_delta.cofins,
    int_consumo_delta.cip,
    int_consumo_delta.retencao,
    int_consumo_delta.receita_bandeiras,
    int_consumo_delta.receita_consumo_faturado,
    int_consumo_delta.tarifa,
    int_consumo_delta.correcao_monetaria,
    int_consumo_delta.creditos,
    int_consumo_delta.estornos,
    int_consumo_delta.juros,
    int_consumo_delta.multas,
    int_consumo_delta.parcelamentos,
    int_calculo_delta.chave_reconciliacao,
    int_calculo_delta.domicilio_fiscal,
    int_calculo_delta.inicio_calculo,
    int_calculo_delta.fim_calculo,
    int_calculo_delta.quantidade_dias,
    int_calculo_delta.data_competencia,
    int_calculo_delta.data_atribuicao_calculo,
    int_calculo_delta.data_apresentacao,
    int_calculo_delta.data_vencimento_original,
    int_calculo_delta.data_previsao_leitura,
    int_calculo_delta.data_criacao_impressao,
    int_calculo_delta.usuario_criacao_impressao,
    int_calculo_delta.data_modificacao_impressao,
    int_calculo_delta.usuario_modificacao_impressao,
    int_calculo_delta.data_criacao_calculo,
    int_calculo_delta.usuario_criacao_calculo,
    int_calculo_delta.data_modificacao_calculo,
    int_calculo_delta.usuario_modificacao_calculo,
    int_calculo_delta.documento_calculo_anterior,
    int_calculo_delta.estrutura_regional_politica,
    null as ordem_faturamento,
    int_consumo_registrado.consumo_registrado,
    SUBSTR(int_consumo_delta.categoria_tarifa, 1, 1) as grupo,
    case
        when
            int_consumo_delta.categoria_tarifa in (
                'A1_LVAZ',
                'A1_LVVD',
                'A2_LVAZ',
                'A2_LVVD',
                'AÇA_LVAZ',
                'A3A_LVVD',
                'A3_LVAZ',
                'A3_LVVD',
                'A4_LVAZ',
                'A4_LVVD'
            )
            then 'X'
    end as cliente_livre,
    case
        when int_calculo_delta.tipo_impressao = ' '
            then null
        else int_calculo_delta.tipo_impressao
    end as tipo_impressao,
    case
        when COALESCE(int_consumo_delta.consumo_faturado, 0) = 0
            then null
        else
            COALESCE(int_consumo_delta.receita_consumo_faturado, 0)
            / int_consumo_delta.consumo_faturado
    end as preco,
    COALESCE(int_calculo_delta.valor_fatura, 0)
    - COALESCE(int_consumo_delta.receita_consumo_faturado, 0)
    - COALESCE(int_consumo_delta.receita_bandeiras, 0)
    - COALESCE(int_consumo_delta.cip, 0)
    - COALESCE(int_consumo_delta.correcao_monetaria, 0)
    - COALESCE(int_consumo_delta.creditos, 0)
    - COALESCE(int_consumo_delta.estornos, 0)
    - COALESCE(int_consumo_delta.juros, 0)
    - COALESCE(int_consumo_delta.multas, 0)
    - COALESCE(int_consumo_delta.parcelamentos, 0)
    - COALESCE(int_consumo_delta.icms_subvencao, 0) as outros_lancamentos,
    case
        when int_calculo_delta.formulario_pagamento = ' '
            then null
        else int_calculo_delta.formulario_pagamento
    end as formulario_pagamento,
    SYSDATE() as data_dados
from
    int_calculo_delta
inner join
    int_consumo_delta
    on
        int_calculo_delta.mes_competencia = int_consumo_delta.mes_competencia
        and int_calculo_delta.documento_calculo
        = int_consumo_delta.documento_calculo
        and int_calculo_delta.documento_impressao
        = int_consumo_delta.documento_impressao
left outer join
    int_consumo_registrado
    on
        int_calculo_delta.mes_competencia
        = int_consumo_registrado.mes_competencia
        and int_calculo_delta.documento_calculo
        = int_consumo_registrado.documento_calculo
        and int_calculo_delta.documento_impressao
        = int_consumo_registrado.documento_impressao
