WITH source AS (
    SELECT *
    FROM {{ source('sirene', 'base_sirene_nantes') }}
),

cleaned AS (
    SELECT
        TRIM("SIRET")                                       AS siret,
        TRIM("SIREN")                                       AS siren,
        TRIM("NIC")                                         AS nic,
        TRIM("Code commune de l'établissement")             AS code_commune,
        TRIM("Commune de l'établissement")                  AS nom_commune,
        TRIM("Code postal de l'établissement")              AS code_postal,
        TRIM("Etat administratif de l'établissement")       AS etat_administratif,
        TRIM("Activité principale de l'établissement")      AS activite_principale,
        TRIM("Caractère employeur de l'établissement")      AS est_employeur,
        TRIM("Date de création de l'établissement")         AS date_creation,
        TRIM("Date de fermeture de l'établissement")        AS date_fermeture,
        TRIM("Code du département de l'établissement")      AS code_departement,
        TRIM("Région de l'établissement")                   AS nom_region,
        TRIM("Géolocalisation de l'établissement")          AS geolocalisation
    FROM source
    WHERE TRIM("SIRET") IS NOT NULL
      AND TRIM("SIRET") != ''
)

SELECT * FROM cleaned
