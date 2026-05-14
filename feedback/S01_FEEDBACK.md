# Rétroaction automatisée -- S01 (Diagnostic fondamental -- NexaMart kickoff)

_Générée le 2026-05-14T22:17:04+00:00 -- Run `20260514T221333Z-7d34bf6a`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief s'exécute correctement et produit la forme attendue. Bon travail sur l'auto-validation.

<details><summary>Requête analysée — cliquez pour déplier</summary>

```sql
WITH ventes_trimestrielles AS (
    SELECT
        p.category,
        s.region,
        d.year,
        d.quarter,
        SUM(f.line_total) AS total_revenue
    FROM raw_fact_sales f
    JOIN raw_dim_product p
        ON f.product_id = p.product_id
    JOIN raw_dim_store s
        ON f.store_id = s.store_id
    JOIN raw_dim_date d
        ON CAST(f.order_date AS DATE) = CAST(d.date_key AS DATE)
    GROUP BY
        p.category,
        s.region,
        d.year,
        d.quarter
),
comparaison AS (
    SELECT
        category,
        region,
        year,
        quarter,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY category, region
            ORDER BY year, quarter
        ) AS previous_quarter_revenue
    FROM ventes_trimestrielles
)
SELECT
    category,
    region,
    year,
    quarter,
    total_revenue,
    previous_quarter_revenue,
    total_revenue - previous_quarter_revenue AS revenue_change
FROM comparaison
WHERE previous_quarter_revenue IS NOT NULL
  AND total_revenue < previous_quarter_revenue
ORDER BY revenue_change ASC
LIMIT 10;
```

</details>

- Colonnes retournées : `category, region, year, quarter, total_revenue, previous_quarter_revenue, revenue_change`
- Correspondance avec les colonnes attendues :
  - `category` → `category`
  - `region` → `region`
  - `quarter` → `quarter`
  - `revenue` → `total_revenue`
- Présence de NULLs dans des colonnes de groupement : `category` =0, `region` =0, `quarter` =0. Pensez à documenter le traitement de ces cas.

**Pistes :**
> Votre `db/nexamart.duckdb` est absente ou vide ; la requête a été exécutée contre une **base de référence cohorte** (seed instructeur). Les chiffres retournés ne correspondent donc pas à vos propres données : reconstruisez votre base avec `python src/run_pipeline.py` (ou `.\run.ps1 load`) pour valider vos calculs sur votre seed personnel.

## 2. Rétroaction pédagogique sur le brief

> Bon brief exécutif qui explique clairement pourquoi passer d'un OLTP à un schéma en étoile et fournit une preuve SQL fonctionnelle. Il manque cependant la traçabilité des décisions (commits/IA) et des contrôles de qualité plus robustes (SCD, gestion des NULLs, vérifications du grain).

### Observations par dimension

**Model quality**
- Observation : « Définir un grain analytique par produit vendu et par transaction » et création des dimensions dim_product, dim_store, dim_customer et dim_date.
- Piste d'amélioration : Préciser la gestion des changements historiques (SCD Type 2) et mentionner les attributs non-additifs (ex. unit_price) avec justification du grain.

**Validation quality**
- Observation : Le brief fournit une requête SQL regroupant SUM(f.line_total) par catégorie, région et trimestre et des contrôles COUNT() pour vérifier les jointures.
- Piste d'amélioration : Ajouter des contrôles de cas limites (NULLs, doublons du grain, vérification du grain unique) et documenter les hypothèses sur line_total vs unit_price.

**Executive justification**
- Observation : La section « Réponse exécutive » explique en langage d'affaires que les données OLTP doivent être transformées en un modèle OLAP et recommande la construction d'un schéma en étoile.
- Piste d'amélioration : Formuler une décision claire pour le CEO (par ex. approbation du schéma en étoile v1) et indiquer le bénéfice attendu (mesure KPI/impact) à court terme.

**Process trace**
- Observation : Aucune trace de commits git, message IA ou journal de décisions n'est fournie dans le brief.
- Piste d'amélioration : Inclure un petit historique de commits (≥3) avec messages et une note IA précisant outil et validation humaine.

**Reproducibility**
- Observation : Le brief mentionne des commandes générales (make load / .\run.ps1 load) mais ne fournit pas de README reproduisible ni scripts sans chemins codés en dur.
- Piste d'amélioration : Fournir un README pas-à-pas et un script de vérification (make check) exécutable sur un clone propre sans ajustements manuels.

## 3. Déclaration d'utilisation de l'IA

> La déclaration est complète et donne des preuves concrètes de l'usage (modèles nommés, étapes et validations exécutées). Assurez-vous, pour plus de robustesse, d'indiquer systématiquement la version exacte lorsque plusieurs variantes d'un outil existent et de signaler si des validations ont échoué.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260514T221333Z-7d34bf6a`
- **Devoir :** `S01`
- **Étudiant·e :** `Chuck88815`
- **Commit analysé :** `6db496e`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260514T221333Z-7d34bf6a/Chuck88815/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
