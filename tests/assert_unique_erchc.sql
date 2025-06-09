select
    opbel as unique_field_0,
    belnr as unique_field_1,
    count(*) as n_records
from {{ source('RAW', 'ERCHC') }}
where 
    opbel is not null
    and belnr is not null
group by opbel, belnr
having count(*) > 1