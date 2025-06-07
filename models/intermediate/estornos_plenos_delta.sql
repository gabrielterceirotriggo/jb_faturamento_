with impressao_delta as (
    select
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
        {{ ref ('int_impressao_delta') }}
),

estornos_plenos_transformados as (
    select
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
        valor_total * -1 as valor_total,
        estorno_pleno,
        fatura_virtual,
        TO_VARCHAR(data_competencia, 'YYYYMM') as mes_competencia
    from
        impressao_delta
    where
        estorno_pleno = 'X'
),

final as (
    select
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
        fatura_virtual,
        mes_competencia
    from
        estornos_plenos_transformados
)

select * from final