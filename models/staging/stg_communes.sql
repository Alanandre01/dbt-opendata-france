with source as (

    select * from {{ source('sirene', 'base_sirene_nantes') }}

),

renamed as (

    select
        -- identifiants
        trim("SIRET")                                           as siret,
        trim("SIREN")                                           as siren,
        trim("NIC")                                             as nic,

        -- localisation
        trim("Code commune de l'établissement")                 as code_commune,
        trim("Commune de l'établissement")                      as nom_commune,
        trim("Code postal de l'établissement")                  as code_postal,
        trim("Code du département de l'établissement")          as code_departement,
        trim("Code de la région de l'établissement")           as code_region,
        trim("Région de l'établissement")                       as nom_region,
        trim("Géolocalisation de l'établissement")              as geolocalisation,

        -- attributs établissement
        trim("Etat administratif de l'établissement")           as etat_administratif,
        trim("Activité principale de l'unité légale")            as activite_principale,
        trim("Caractère employeur de l'établissement")          as est_employeur,
        trim("Catégorie de l'entreprise")                       as categorie_entreprise,

        -- cast des types (format source : JJ/MM/AAAA)
        cast(try_strptime(trim("Date de création de l'établissement"),  '%d/%m/%Y') as date)  as date_creation,
        cast(try_strptime(trim("Date de fermeture de l'établissement"), '%d/%m/%Y') as date)  as date_fermeture,

        -- métadonnées
        current_timestamp                                       as _loaded_at

    from source
    where trim("SIRET") is not null
      and trim("SIRET") != ''

)

select * from renamed
