select distinct
    df.opbel,
    df.belnr
from (select
        erdk.opbel,
        erchc.belnr
    from {{ source('RAW', 'ERDK') }} as erdk
    inner join {{ source('RAW', 'ERCHC') }} as erchc on erdk.opbel = erchc.opbel
    inner join {{ source('RAW', 'ERCH') }} as erch on erchc.belnr = erch.belnr
    where
        erdk.invoiced = 'X'
        and erchc.belnr = erch.belnr
        and erch.belegart is not null) as df
left join {{ source('RAW', 'DBERDLB') }} as dlb
    on df.opbel = dlb.printdoc
    and df.belnr = dlb.billdoc
left join {{ source('RAW', 'DBERCHZ1') }} as dz1
    on dlb.billdoc = dz1.belnr
    and dlb.billdocline = dz1.belzeile
left join {{ source('RAW', 'DBERCHZ5') }} as dz5
    on dlb.billdoc = dz5.belnr
    and dlb.billdocline = dz5.belzeile
where
    dlb.xtotal_amnt = 'X'
    and dz1.belnr is null 
    and dz5.belnr is null