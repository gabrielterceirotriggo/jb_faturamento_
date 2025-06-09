select
    mes_competencia as unique_field_0,
    documento_calculo as unique_field_1,
    documento_impressao as unique_field_2,
    count(*) as n_records

from {{ source('PROD', 'FATURAMENTO') }}
where
    mes_competencia is not null
    and documento_calculo is not null
    and documento_impressao is not null
group by mes_competencia, documento_calculo, documento_impressao
having count(*) > 1
