{{ config(materialized='table') }}

with source as (

    select * from {{ ref('stg_emploi') }}

),

regions as (

    select
        code_region,
        max(nom_region) as nom_region

    from source
    where code_region is not null
      and code_region != 'Total'

    group by code_region

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['code_region']) }} as region_sk,
        code_region,
        nom_region,
        current_timestamp                                        as _loaded_at

    from regions

)

select * from final
