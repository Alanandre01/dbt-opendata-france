-- Ce test échoue si une commune a des métriques négatives ou incohérentes.
-- Un résultat vide = test réussi.

SELECT
    code_commune,
    nom_commune,
    nb_etablissements,
    nb_actifs,
    nb_employeurs
FROM {{ ref('stg_communes_enriched') }}
WHERE
    nb_etablissements < 0
    OR nb_actifs < 0
    OR nb_employeurs < 0
    OR nb_actifs > nb_etablissements
    OR nb_employeurs > nb_etablissements
