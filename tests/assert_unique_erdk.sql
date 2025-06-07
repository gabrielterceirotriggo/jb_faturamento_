select
    opbel as unique_field_0,
    count(*) as n_records

from {{ source('RAW', 'ERDK') }}
where 
    opbel is not null
group by opbel
having count(*) > 1