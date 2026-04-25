{{ config(
    materialized='incremental',
    unique_key='emploi_id'
) }}

with base as (

    select * from {{ ref('int_communes_enrichies') }}

),

final as (

    select
        -- clé primaire technique : combinaison unique commune + période
        {{ dbt_utils.generate_surrogate_key(['code_commune', 'periode']) }}
                                            as emploi_id,

        -- clés de jointure
        code_commune,
        code_departement,

        -- attributs descriptifs
        nom_commune,
        nom_region,
        categorie_economique,
        periode,
        annee,
        trimestre,

        -- métriques héritées de int_communes_enrichies
        nb_etablissements,
        nb_actifs,
        nb_employeurs,
        nb_demandeurs_emploi,
        taux_demandeurs_pour_cent,

        -- catégorisation métier (décision analytique, va dans le mart)
        case
            when taux_demandeurs_pour_cent is null  then 'inconnu'
            when taux_demandeurs_pour_cent < 10     then 'faible'
            when taux_demandeurs_pour_cent < 25     then 'moyen'
            else                                         'élevé'
        end                                         as categorie_tension_emploi,

        -- métadonnée de traçabilité
        current_timestamp                           as _loaded_at

    from base
    where annee is not null

    {% if is_incremental() %}
        and annee >= (
            select max(annee)
            from {{ this }}
        )
    {% endif %}

)

select * from final
