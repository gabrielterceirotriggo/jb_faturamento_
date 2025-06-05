select
    a.anlage as instalacao,
    a.abrvorg as tipo_calculo,
    a.ableinh as ul,
    a.ernam as criado_por,
    TO_DATE(a.abrdats, 'YYYYMMDD') as data_calc_previsto,
    case
        when a.trigstat = '1' then 'NAO_CALCULAVEL'
        when a.trigstat = '2' then 'CALCULAVEL'
    end as status,
    TO_DATE(a.erdat, 'YYYYMMDD') as data_criacao
from
    {{ ref ('stg_etrg') }} as a
where
    a.mandt = {{ mc_mandante(var('source_param')) }}
