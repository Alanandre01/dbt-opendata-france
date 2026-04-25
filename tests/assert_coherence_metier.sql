-- Vérifie la hiérarchie logique des compteurs d'établissements :
--   nb_employeurs ≤ nb_etablissements  (un employeur est un établissement)
--   nb_actifs     ≤ nb_etablissements  (les actifs sont un sous-ensemble du total)
--   aucune valeur négative
-- 0 ligne attendu = test vert.

select
    etablissement_sk,
    code_commune,
    code_naf,
    nb_etablissements,
    nb_actifs,
    nb_employeurs
from {{ ref('fct_etablissements') }}
where
    nb_etablissements < 0
    or nb_actifs      < 0
    or nb_employeurs  < 0
    or nb_actifs    > nb_etablissements
    or nb_employeurs > nb_etablissements
