select
    opbel as unique_field_0,
    belnr as unique_field_1,
    lfdnr as unique_field_2,
    count(*) as n_records
from {{ source('RAW', 'ERCHC') }}
where 
    opbel is not null
    and belnr is not null
    and lfdnr is not null
group by all
having count(*) > 1