with communes as (

    select
        code_commune,
        max(nom_commune)                                            as nom_commune,
        max(nom_region)                                             as nom_region,
        max(code_departement)                                       as code_departement,
        count(*)                                                    as nb_etablissements,
        count(*) filter (where etat_administratif = 'Actif')       as nb_actifs,
        count(*) filter (where est_employeur = 'Oui')              as nb_employeurs,
        case
            when count(*) > 1000 then 'pôle économique'
            when count(*) > 200  then 'commune active'
            when count(*) > 50   then 'commune intermédiaire'
            else                      'petite commune'
        end                                                         as categorie_economique

    from {{ ref('stg_communes') }}
    group by code_commune

),

emploi as (

    select *
    from {{ ref('stg_emploi') }}
    where sexe = 'Total'
      and tranche_age = 'Total'

),

joined as (

    select
        c.code_commune,
        c.nom_commune,
        c.nom_region,
        c.code_departement,
        c.nb_etablissements,
        c.nb_actifs,
        c.nb_employeurs,
        c.categorie_economique,

        -- métriques emploi (une ligne par période)
        e.periode,
        e.annee,
        e.trimestre,
        e.nb_demandeurs_emploi,

        -- taux calculé ici, pas dans staging
        round(
            e.nb_demandeurs_emploi * 100.0 / nullif(c.nb_etablissements, 0),
            2
        )                                                           as taux_demandeurs_pour_cent

    from communes c
    left join emploi e
        on c.code_commune = e.code_commune

)

select * from joined
