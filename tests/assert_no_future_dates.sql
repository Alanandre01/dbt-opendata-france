-- Retourne les périodes dont la date reconstruite est dans le futur.
-- 0 ligne attendu = test vert.
-- make_date reconstruit une date à partir de annee + trimestre (mois = trimestre * 3).

select
    emploi_id,
    periode,
    annee,
    trimestre,
    make_date(annee, trimestre * 3, 1) as date_periode,
    current_date                       as date_aujourdhui
from {{ ref('fct_emploi') }}
where make_date(annee, trimestre * 3, 1) > current_date
