# dbt_opendata_france

Analytical pipeline built with dbt and DuckDB on French open data (SIRENE business registry + DARES employment data).
Personal learning project to practice dbt Core concepts: sources, staging, intermediate, marts, tests, and documentation.

## Data sources

| Source | Description | Coverage |
|---|---|---|
| **Base SIRENE** | Official French business registry ([data.gouv.fr](https://www.data.gouv.fr)) | ~420,000 establishments, Nantes metropolitan area |
| **DARES DEFM** | Monthly job seekers by commune ([data.gouv.fr](https://www.data.gouv.fr)) | All France, Q4 2015 → Q4 2024 |

Both CSVs are read directly by DuckDB via `read_csv_auto` — they are not loaded as dbt seeds.

## Stack

| Tool | Role |
|---|---|
| **dbt Core 1.x** | Transformations, tests, documentation |
| **dbt-duckdb** | DuckDB adapter for dbt |
| **dbt-utils** | Utility macros (`generate_surrogate_key`) |
| **DuckDB** | In-process analytical SQL engine |
| **Python + venv** | Ad hoc exploration via `main.py` |

## Pipeline architecture

```
sources (data.gouv.fr CSVs)
├── sirene/base_sirene_nantes
│   └── stg_communes              ← clean & rename columns, cast types, one row per establishment (SIRET)
│       └── int_communes_enrichies ← JOIN SIRENE × DEFM, aggregate by commune, compute taux_demandeurs
│           ├── fct_emploi         ← fact table: surrogate key, categorie_tension_emploi
│           └── fct_stats_communes ← fact table: final stats per commune
└── defm/demandeurs_emploi_communes
    └── stg_emploi                ← clean & rename columns, split periode → annee + trimestre
        └── int_communes_enrichies
```

## Run the project

```bash
# Install dependencies
pip install dbt-duckdb
dbt deps          # install dbt-utils

# Run all models + tests
dbt build

# Run only transformations
dbt run

# Run only tests
dbt test

# Preview a model result
dbt show --select stg_communes --limit 5

# Generate and browse documentation
dbt docs generate && dbt docs serve
```

## Data quality tests

**Generic tests (schema.yml)**
- `not_null` on all key columns
- `unique` on primary keys (siret, code_commune, nom_commune)
- `accepted_values` on categorical columns:
  - `etat_administratif` → `['Actif', 'Fermé']`
  - `est_employeur` → `['Oui', 'Non']`
  - `categorie_entreprise` → `['PME', 'ETI', 'GE']`
  - `categorie_economique` → 4 values
  - `sexe` → `['Total', 'Hommes', 'Femmes']`
  - `tranche_age` → 4 values

**Singular tests (tests/)**
- `assert_identifiants_format.sql` — validates identifier lengths (SIRET=14, SIREN=9, NIC=5, code_commune=5)
- `assert_metriques_positives.sql` — checks metric coherence (no negatives, nb_actifs ≤ nb_etablissements)

## Project structure

```
models/
├── sources.yml
├── staging/
│   ├── schema.yml
│   ├── stg_communes.sql
│   └── stg_emploi.sql
├── intermediate/
│   ├── schema.yml
│   └── int_communes_enrichies.sql
└── marts/
    ├── schema.yml
    ├── fct_emploi.sql
    └── fct_stats_communes.sql
tests/
├── assert_identifiants_format.sql
└── assert_metriques_positives.sql
packages.yml           ← dbt-utils dependency
seeds/                 ← not tracked in git
```
