{{ config(materialized='table') }}

with source as (

    select * from {{ ref('stg_communes') }}

),

dim_region as (

    select * from {{ ref('dim_region') }}

),

dim_secteur as (

    select * from {{ ref('dim_secteur') }}

),

aggregated as (

    -- Grain : commune × secteur NAF
    select
        code_commune,
        max(nom_commune)                                            as nom_commune,
        max(code_region)                                            as code_region,
        activite_principale,
        count(*)                                                    as nb_etablissements,
        count(*) filter (where etat_administratif = 'Actif')       as nb_actifs,
        count(*) filter (where est_employeur = 'Oui')              as nb_employeurs

    from source
    where activite_principale is not null

    group by code_commune, activite_principale

),

final as (

    select
        -- clé primaire technique
        {{ dbt_utils.generate_surrogate_key(['a.code_commune', 'a.activite_principale']) }}
                                            as etablissement_sk,

        -- clés étrangères (star schema)
        r.region_sk,
        sec.secteur_sk,

        -- clés naturelles
        a.code_commune,
        a.nom_commune,
        a.activite_principale               as code_naf,

        -- métriques
        a.nb_etablissements,
        a.nb_actifs,
        a.nb_employeurs,

        current_timestamp                   as _loaded_at

    from aggregated a

    -- jointure sur la clé naturelle, pas sur un hash recalculé
    left join dim_region r
        on a.code_region = r.code_region

    left join dim_secteur sec
        on a.activite_principale = sec.code_naf

)

select * from final
