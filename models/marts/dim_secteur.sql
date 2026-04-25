{{ config(materialized='table') }}

with source as (

    select * from {{ ref('stg_communes') }}

),

secteurs as (

    select distinct
        activite_principale as code_naf

    from source
    where activite_principale is not null

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['code_naf']) }} as secteur_sk,
        code_naf,
        case
            when try_cast(left(code_naf, 2) as integer) between 1  and 3  then 'Agriculture'
            when try_cast(left(code_naf, 2) as integer) between 10 and 33 then 'Industrie manufacturière'
            when try_cast(left(code_naf, 2) as integer) between 41 and 43 then 'Construction'
            when try_cast(left(code_naf, 2) as integer) between 45 and 47 then 'Commerce'
            when try_cast(left(code_naf, 2) as integer) between 49 and 53 then 'Transport'
            when try_cast(left(code_naf, 2) as integer) between 55 and 56 then 'Hébergement & restauration'
            when try_cast(left(code_naf, 2) as integer) between 58 and 63 then 'Information & communication'
            when try_cast(left(code_naf, 2) as integer) between 64 and 66 then 'Finance & assurance'
            when try_cast(left(code_naf, 2) as integer) = 68              then 'Immobilier'
            when try_cast(left(code_naf, 2) as integer) between 69 and 75 then 'Services aux entreprises'
            when try_cast(left(code_naf, 2) as integer) = 85              then 'Enseignement'
            when try_cast(left(code_naf, 2) as integer) between 86 and 88 then 'Santé & action sociale'
            else 'Autres'
        end                  as famille_metier,
        current_timestamp    as _loaded_at

    from secteurs

)

select * from final
