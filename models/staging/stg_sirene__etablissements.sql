WITH source AS (
    SELECT *
    FROM read_csv_auto(
        'seeds/base-sirene-nantes.csv',
        delim=';',
        all_varchar=true        -- ← tout en VARCHAR, on gère les types nous-mêmes
    )
),

renomme AS (
    SELECT
        SIREN                                               AS siren,
        SIRET                                               AS siret,
        NIC                                                 AS nic,
        "Etablissement siège"                               AS est_siege,
        "Etat administratif de l'établissement"             AS statut,
        "Date de création de l'établissement"               AS date_creation_raw,
        "Code postal de l'établissement"                    AS code_postal,
        "Commune de l'établissement"                        AS code_commune,
        "Libellé de la commune de l'établissement à l'étranger" AS commune,
        "Région de l'établissement"                         AS region,
        "Département de l'établissement"                    AS departement,
        "Activité principale de l'établissement"            AS code_naf,
        "Division de l'établissement"                       AS division_naf,
        "Caractère employeur de l'établissement"            AS est_employeur,
        "Dénomination de l'unité légale"                    AS denomination,
        "Catégorie juridique de l'unité légale"             AS categorie_juridique,
        "Géolocalisation de l'établissement"                AS geolocalisation
    FROM source
),

type AS (
    SELECT
        siren,
        siret,
        nic,
        est_siege,
        statut,
        TRY_CAST(date_creation_raw AS DATE)                 AS date_creation,
        code_postal,
        code_commune,
        commune,
        region,
        departement,
        code_naf,
        division_naf,
        est_employeur,
        denomination,
        categorie_juridique,
        geolocalisation
    FROM renomme
    WHERE siren IS NOT NULL
)

SELECT * FROM type