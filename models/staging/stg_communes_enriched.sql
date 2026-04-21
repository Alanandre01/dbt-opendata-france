WITH communes AS (
    SELECT * FROM {{ ref('stg_communes') }}
),

agregation AS (
    SELECT
        code_commune,
        nom_commune,
        nom_region,
        code_departement,
        COUNT(*)                                            AS nb_etablissements,
        COUNT(*) FILTER (WHERE etat_administratif = 'A')   AS nb_actifs,
        COUNT(*) FILTER (WHERE est_employeur = 'O')        AS nb_employeurs
    FROM communes
    GROUP BY code_commune, nom_commune, nom_region, code_departement
)

SELECT
    code_commune,
    nom_commune,
    nom_region,
    code_departement,
    nb_etablissements,
    nb_actifs,
    nb_employeurs,

    CASE
        WHEN nb_etablissements > 1000 THEN 'pôle économique'
        WHEN nb_etablissements > 200  THEN 'commune active'
        WHEN nb_etablissements > 50   THEN 'commune intermédiaire'
        ELSE                               'petite commune'
    END AS categorie_economique

FROM agregation
WHERE nb_etablissements > 0
