select ultima_execucao
from
    {{ source('PROD','INT_ULTIMA_EXECUCAO') }}
