-- Ce test échoue si des identifiants n'ont pas le bon format INSEE/SIRENE.
-- Format attendu : code_commune = 5 caractères, siren = 9, nic = 5, siret = 14.
-- Un résultat vide = test réussi.

SELECT
    siret,
    siren,
    nic,
    code_commune,
    nom_commune,
    LENGTH(code_commune)    AS longueur_code_commune,
    LENGTH(siren)           AS longueur_siren,
    LENGTH(nic)             AS longueur_nic,
    LENGTH(siret)           AS longueur_siret
FROM {{ ref('stg_communes') }}
WHERE
    LENGTH(code_commune) != 5
    OR LENGTH(siren)     != 9
    OR LENGTH(nic)       != 5
    OR LENGTH(siret)     != 14
