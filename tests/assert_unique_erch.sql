select
    belnr as unique_field_0,
    count(*) as n_records
from {{ source('RAW', 'ERCH') }}
where 
    belnr is not null
group by belnr
having count(*) > 1