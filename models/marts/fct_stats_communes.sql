{{ config(materialized='table') }}

WITH communes_actives AS (
    SELECT *
    FROM {{ ref('int_communes_enrichies') }}
    WHERE nb_etablissements IS NOT NULL
      AND nb_etablissements > 0
),

stats_par_commune AS (
    SELECT
        nom_commune,
        nom_region,
        code_departement,
        SUM(nb_etablissements)          AS nb_etablissements_total,
        SUM(nb_actifs)                  AS nb_actifs_total,
        SUM(nb_employeurs)              AS nb_employeurs_total
    FROM communes_actives
    GROUP BY nom_commune, nom_region, code_departement
)

SELECT
    nom_commune,
    nom_region,
    code_departement,
    nb_etablissements_total,
    nb_actifs_total,
    nb_employeurs_total
FROM stats_par_commune
ORDER BY nb_etablissements_total DESC
