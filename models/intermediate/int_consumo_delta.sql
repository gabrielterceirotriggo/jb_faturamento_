WITH DT AS (
SELECT
    int_calculo_delta.mes_competencia AS mes_competencia,
    int_calculo_delta.documento_calculo AS documento_calculo,
    int_calculo_delta.documento_impressao AS documento_impressao,
    itens_faturamento.linha,
    itens_faturamento.setor_industrial,
    itens_faturamento.categoria_tarifa,
    itens_faturamento.subclasse,
    itens_faturamento.item_documento,
    itens_faturamento.flag,
    CASE 
        WHEN int_calculo_delta.mes_referencia >= '202311' THEN
            CASE 
                WHEN itens_faturamento.flag = 'C' AND itens_faturamento.item_documento IN ('ZEAT', 'ZBXE', 'ZEANP', 'ZEAIT', 'ZEAFP', 'ZCMFNP', 'ZIPFTE', 'ZEARV', 'ZEMFUP', 'ZTUSNP', 'ZTUSFP', 'ZEAFPC', 'ZEANPC', 'ZEARVC', 'ZEATC', 'ZBXEC')
                    THEN itens_faturamento.consumo
                WHEN itens_faturamento.FLAG = 'C' AND itens_faturamento.item_documento IN ('ZEGAT', 'ZEGFP', 'ZEGIT', 'ZEGNP', 'ZEGRV')
                    THEN itens_faturamento.consumo
                ELSE 0
            END
        ELSE 0
    END consumo_faturado,
    CASE 
        WHEN itens_faturamento.flag = 'M'
            AND itens_faturamento.item_documento IN ('ZRCAT', 'ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV') 
        THEN itens_faturamento.consumo
        ELSE 0
    END consumo_medido,
    CASE 
        WHEN itens_faturamento.flag = 'D'
            AND itens_faturamento.item_documento IN ('ZEUSD') 
        THEN itens_faturamento.receita
        ELSE 0
    END eusd,
    CASE 
        WHEN itens_faturamento.flag = 'D'
            AND itens_faturamento.item_documento IN ('ZEUSDB') 
        THEN itens_faturamento.receita
        ELSE 0
    END eusdb,
    CASE 
        WHEN itens_faturamento.flag = 'R'
            AND itens_faturamento.tipo_imposto IN ('MW2')
        THEN itens_faturamento.receita
        ELSE 0
    END icms,
    CASE 
        WHEN itens_faturamento.flag = 'R'
            AND itens_faturamento.operacao IN ('ZBXR')
            OR itens_faturamento.item_ordenacao IN ('ZBTB')
            AND itens_faturamento.tipo_imposto IN ('MW2')
        THEN itens_faturamento.receita
        ELSE 0
    END icms_subvencao,
    CASE 
        WHEN itens_faturamento.flag = 'R'
            AND itens_faturamento.tipo_imposto IN ('PIS')
        THEN itens_faturamento.receita
        ELSE 0
    END pis,
    CASE 
        WHEN itens_faturamento.flag = 'R'
            AND itens_faturamento.tipo_imposto IN ('COF')
        THEN itens_faturamento.receita
        ELSE 0
    END cofins,
    CASE 
        WHEN itens_faturamento.flag = 'R'
            AND itens_faturamento.operacao IN ('CIP1', 'CIP2', 'CIP3','CIP4')
        THEN itens_faturamento.receita
        ELSE 0
    END cip,
    CASE 
        WHEN itens_faturamento.item_documento = 'WHTAX'
        THEN itens_faturamento.receita
        ELSE 0
    END retencao,
    CASE 
        WHEN itens_faturamento.item_ordenacao IN 
            ('ZEAT', 'ZEFP', 'ZENP', 'ZTFP', 'ZTNP', 'ZMFB', 'ZMUE', 'ZMUT', 'ZEIP', 
            'ZTIP', 'ZTAT', 'ZTRV', 'ZERV', 'ZEIT', 'ZTIT', 'ZCRI') 
        THEN itens_faturamento.preco
        ELSE 0
    END tarifa,
    CASE 
        WHEN itens_faturamento.item_ordenacao IN 
            ('ZDAM','ZDVM') 
        THEN itens_faturamento.receita
        ELSE 0
    END receita_bandeiras,
    CASE 
        WHEN int_calculo_delta.mes_referencia >= '202311' THEN 
            CASE 
                WHEN itens_faturamento.item_ordenacao IN 
                     ('ZEAT', 'ZBXE', 'ZBXT', 'ZEFP', 'ZENP', 'ZTFP', 'ZTNP', 'ZMFB', 
                      'ZMUE', 'ZMUT', 'ZEIP', 'ZTIP', 'ZTAT', 'ZTRV', 'ZERV', 'ZEIT', 
                      'ZTIT', 'ZCRI', 'ZEGN', 'ZEGR', 'ZEGI', 'ZEGF', 'ZEGT', 'ZTGN', 
                      'ZTGR', 'ZTGI', 'ZTGF', 'ZTGT', 'ZBEC', 'ZEFC', 'ZEIC', 'ZENC', 
                      'ZECR', 'ZEAC', 'ZTFC', 'ZTIC', 'ZTNC', 'ZTCR', 'ZTAC') 
                THEN itens_faturamento.receita
                ELSE 0 
            END
        ELSE 
            CASE 
                WHEN itens_faturamento.item_ordenacao IN 
                     ('ZEAT', 'ZBXE', 'ZBXT', 'ZEFP', 'ZENP', 'ZTFP', 'ZTNP', 'ZMFB', 
                      'ZMUE', 'ZMUT', 'ZEIP', 'ZTIP', 'ZTAT', 'ZTRV', 'ZERV', 'ZEIT', 
                      'ZTIT', 'ZCRI') 
                THEN itens_faturamento.receita
                ELSE 0 
            END
    END AS receita_consumo_faturado,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'CORRECAO MONETARIA'
        THEN itens_faturamento.receita
        ELSE 0
    END correcao_monetaria,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'CREDITO'
        THEN itens_faturamento.receita
        ELSE 0
    END creditos,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'ESTORNO'
        THEN itens_faturamento.receita
        ELSE 0
    END estornos,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'JUROS'
        THEN itens_faturamento.receita
        ELSE 0
    END juros,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'MULTA'
        THEN itens_faturamento.receita
        ELSE 0
    END multas,
    CASE 
        WHEN itens_faturamento.flag IN ('R')
        AND faturamento_operacoes.bloco = 'PARCELAMENTO'
        THEN itens_faturamento.receita
        ELSE 0
    END parcelamentos
FROM 
    {{ ref ('int_calculo_delta')}} int_calculo_delta
INNER JOIN 
    {{ ref ('itens_faturamento')}} itens_faturamento
    ON itens_faturamento.mes_competencia = int_calculo_delta.mes_competencia
    AND itens_faturamento.documento_calculo = int_calculo_delta.documento_calculo
    AND itens_faturamento.documento_impressao = int_calculo_delta.documento_impressao
LEFT OUTER JOIN 
    {{ ref ('stg_faturamento_operacoes')}} faturamento_operacoes
    ON itens_faturamento.OPERACAO = faturamento_operacoes.OPERACAO
    AND itens_faturamento.SUB_OPERACAO = faturamento_operacoes.SUB_OPERACAO
GROUP BY ALL

),

Q_SOMA_TARIFA AS (
    SELECT
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao,
        sum(dt.tarifa) as tarifa
    FROM
        dt
    GROUP BY
        dt.mes_competencia,
        dt.documento_calculo,
        dt.documento_impressao
),

Q_SOMA AS (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    sum(consumo_faturado) AS consumo_faturado,
    CASE 
        WHEN SUM(CASE 
                    WHEN dt.flag = 'M' AND dt.item_documento IN ('ZRCAT') 
                    THEN dt.consumo_medido 
                    ELSE 0 
                END) <> 0 
        THEN 
            SUM(CASE 
                    WHEN dt.flag = 'M' AND dt.item_documento IN ('ZRCAT') 
                    THEN dt.consumo_medido 
                    ELSE 0 
                END)
        ELSE 
            SUM(CASE 
                    WHEN dt.flag = 'M' AND dt.item_documento IN ('ZRCAFP', 'ZRCAIT', 'ZRCANP', 'ZRCARV') 
                    THEN dt.consumo_medido 
                    ELSE 0 
                END)
    END AS consumo_medido,
    SUM(eusd) AS eusd,
    SUM(eusdb) AS eusdb,
    SUM(icms) AS icms,
    SUM(icms_subvencao) AS icms_subvencao,
    SUM(pis) AS pis,
    SUM(cofins) AS cofins,
    SUM(cip) AS cip,
    SUM(retencao) AS retencao,
    SUM(receita_bandeiras) AS receita_bandeiras,
    SUM(receita_consumo_faturado) AS receita_consumo_faturado,
    SUM(tarifa) AS tarifa,
    SUM(correcao_monetaria) AS correcao_monetaria,
    SUM(creditos) AS creditos,
    SUM(estornos) AS estornos,
    SUM(juros) AS juros,
    SUM(multas) AS multas,
    SUM(parcelamentos) AS parcelamentos
FROM
    dt
GROUP BY
    mes_competencia,
    documento_calculo,
    documento_impressao
),

Q_TRATA AS (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    COALESCE(CAST(DT.LINHA AS INT), 0) AS linha,
    setor_industrial,
    categoria_tarifa,
    subclasse
FROM
    DT
GROUP BY
    mes_competencia,
    documento_calculo,
    documento_impressao,
    linha,
    setor_industrial,
    categoria_tarifa,
    subclasse
),

Q_ORDER AS (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    linha,
    setor_industrial,
    categoria_tarifa,
    subclasse
FROM
    q_trata
ORDER BY 
    mes_competencia asc,
    documento_calculo asc,
    documento_impressao asc,
    linha desc
),

Q_RANK AS (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    linha,
    setor_industrial,
    categoria_tarifa,
    subclasse,
    ROW_NUMBER() OVER (
    PARTITION BY mes_competencia, documento_calculo, documento_impressao
    ORDER BY linha DESC
) AS posicao
FROM
    q_order
),

Q_FILTRO AS (
SELECT
    mes_competencia,
    documento_calculo,
    documento_impressao,
    setor_industrial,
    categoria_tarifa,
    subclasse
FROM
    q_rank
WHERE
    posicao = 1
)

SELECT
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
FROM
    q_filtro
LEFT OUTER JOIN q_soma
    USING (mes_competencia, documento_calculo, documento_impressao)
LEFT OUTER JOIN q_soma_tarifa
    USING (mes_competencia, documento_calculo, documento_impressao)
