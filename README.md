# dbt_opendata_france

Analytical pipeline built with dbt and DuckDB on French open data (SIRENE business registry).
Personal learning project to practice dbt Core concepts: sources, staging, marts, tests, and documentation.

## Data source

**Base SIRENE** — official French business registry, published on [data.gouv.fr](https://www.data.gouv.fr).
The dataset covers the **Nantes metropolitan area** (~420,000 establishments in Loire-Atlantique, Pays de la Loire).

The CSV is read directly by DuckDB via `read_csv_auto` — it is not loaded as a dbt seed.

## Stack

| Tool | Role |
|---|---|
| **dbt Core 1.x** | Transformations, tests, documentation |
| **dbt-duckdb** | DuckDB adapter for dbt |
| **DuckDB** | In-process analytical SQL engine |
| **Python + venv** | Ad hoc exploration via `main.py` |

## Pipeline architecture

```
Source (data.gouv.fr CSV)
└── seeds/base-sirene-nantes.csv
    └── staging/stg_communes           ← clean & rename columns, one row per establishment (SIRET)
        └── staging/stg_communes_enriched  ← aggregate by commune, compute metrics & economic category
            └── marts/mart_stats_regions   ← final table sorted by establishment volume
```

## Run the project

```bash
# Install dependencies
pip install dbt-duckdb

# Run all models + tests
dbt build

# Run only transformations
dbt run

# Run only tests
dbt test

# Generate and browse documentation
dbt docs generate && dbt docs serve
```

## Data quality tests

31 tests total — 29 generic (defined in `schema.yml`) and 2 singular (in `tests/`).

**Generic tests (schema.yml)**
- `not_null` on all key columns (siret, siren, code_commune, etat_administratif, etc.)
- `unique` on primary keys (siret in stg_communes, code_commune in stg_communes_enriched, nom_commune in mart_stats_regions)
- `accepted_values` on categorical columns:
  - `etat_administratif` → `['Actif', 'Fermé']`
  - `est_employeur` → `['Oui', 'Non']`
  - `categorie_entreprise` → `['PME', 'ETI', 'GE']`
  - `categorie_economique` → `['pôle économique', 'commune active', 'commune intermédiaire', 'petite commune']`

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
│   └── stg_communes_enriched.sql
└── marts/
    ├── schema.yml
    └── mart_stats_regions.sql
tests/
├── assert_identifiants_format.sql
└── assert_metriques_positives.sql
seeds/
└── base-sirene-nantes.csv   ← not tracked in git
```
