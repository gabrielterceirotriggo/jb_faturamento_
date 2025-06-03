SELECT
    mandt AS mandante,
    ablbelnr AS id_leitura,
    anlage AS instalacao,
    CASE
        WHEN ZCFAT_IRREG_CAB.ADAT = '00000000' THEN NULL
        ELSE TO_DATE(ZCFAT_IRREG_CAB.ADAT, 'YYYYMMDD')
    END data_leitura,
    aplicacao,
    parcelas,
    fat_compl,
    ernam AS criado_por,
    CASE
        WHEN ZCFAT_IRREG_CAB.ERDAT = '00000000' THEN NULL
        ELSE TO_DATE(ZCFAT_IRREG_CAB.ERDAT, 'YYYYMMDD')
    END data_criacao
FROM
    {{ ref ('stg_zcfat_irreg_cab')}} ZCFAT_IRREG_CAB
WHERE
    MANDT IN (401, 402, 403, 404)
    