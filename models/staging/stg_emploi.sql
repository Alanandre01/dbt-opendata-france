with source as (

    select * from {{ source('defm', 'demandeurs_emploi_communes') }}

),

renamed as (

    select
        -- période (format : AAAA-TN, ex : 2024-T4)
        "Date"                                                      as periode,
        {{ safe_cast('left("Date", 4)', 'integer') }}                  as annee,
        {{ safe_cast('right("Date", 1)', 'integer') }}               as trimestre,

        -- localisation
        "Code commune"                                              as code_commune,
        "Commune"                                                   as nom_commune,
        "Code département"                                          as code_departement,
        "Département"                                               as nom_departement,
        "Code région"                                               as code_region,
        "Région"                                                    as nom_region,

        -- dimensions analytiques
        "Sexe"                                                      as sexe,
        "Tranche d'âge"                                             as tranche_age,
        "Catégorie"                                                 as categorie_demande,
        "Type de données"                                           as type_donnees,

        -- métrique
        {{ safe_cast('"Nombre de demandeurs d\'emploi"', 'integer') }} as nb_demandeurs_emploi,

        -- métadonnées
        current_timestamp                                           as _loaded_at

    from source

)

select * from renamed
