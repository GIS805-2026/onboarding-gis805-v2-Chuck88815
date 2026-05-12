# Board Brief - S01

## Question du CEO

> « Quelles catégories déclinent dans quelles régions et pourquoi ? Chaque étudiant doit identifier sa première question exécutive. »

## Réponse exécutive

Les données actuellement disponibles sont structurées selon une logique OLTP (Online Transaction Processing), principalement orientée vers l'enregistrement des transactions opérationnelles. Les ventes brutes seules ne suffisent pas à répondre efficacement à la question stratégique du CEO; elles doivent être enrichies par des dimensions analytiques.

La table de ventes contient principalement des identifiants transactionnels (`product_id`, `store_id`, `customer_id`). Pour comprendre les catégories, les régions et les tendances temporelles, il faut joindre ces identifiants aux dimensions produit, magasin et date.

Afin de produire une analyse exploitable pour la direction, il est nécessaire de transformer les données transactionnelles en un modèle OLAP (Online Analytical Processing) reposant sur un schéma en étoile.

## Décisions de modélisation

Pour répondre à la question exécutive, les décisions de modélisation suivantes sont proposées :

- Construire une table de faits analytique `fact_sales`.
- Définir un grain analytique par produit vendu et par transaction.
- Créer les dimensions descriptives `dim_product`, `dim_store`, `dim_customer` et `dim_date`.
- Intégrer les hiérarchies analytiques produit -> catégorie -> sous-catégorie et magasin -> région -> province.
- Ajouter les attributs utiles aux analyses exécutives : catégorie, sous-catégorie, région, province, canal de vente et période temporelle.

Cette structure permettra d'effectuer des analyses multidimensionnelles sur :

- les ventes par catégorie;
- les tendances régionales;
- les variations temporelles;
- les catégories en déclin.

## Preuve

Pour répondre à la question du CEO, il faut relier les ventes aux dimensions produit, magasin et date. La requête ci-dessous calcule le revenu par catégorie, région et trimestre, puis compare chaque trimestre au trimestre précédent.

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

Résultat obtenu :

| category | region | year | quarter | total_revenue | previous_quarter_revenue | revenue_change |
|---|---|---:|---:|---:|---:|---:|
| Toys & Games | Québec | 2025 | 3 | 2219.82 | 4696.67 | -2476.85 |
| Grocery | Alberta | 2025 | 3 | 1140.62 | 3450.41 | -2309.79 |
| Automotive | Ontario | 2025 | 2 | 2457.95 | 4733.92 | -2275.97 |
| Books & Media | Estrie | 2025 | 4 | 844.94 | 3116.08 | -2271.14 |
| Automotive | Estrie | 2025 | 3 | 1764.10 | 3793.53 | -2029.43 |
| Books & Media | Alberta | 2025 | 3 | 1723.78 | 3657.77 | -1933.99 |
| Grocery | Ontario | 2025 | 2 | 1155.64 | 3086.67 | -1931.03 |
| Pet Supplies | BC | 2025 | 3 | 1471.35 | 3390.76 | -1919.41 |
| Beauty & Health | Ontario | 2025 | 3 | 1046.42 | 2815.35 | -1768.93 |
| Grocery | Outaouais | 2025 | 3 | 962.89 | 2635.37 | -1672.48 |

Cette preuve montre que la question est techniquement possible seulement si les ventes sont enrichies avec les dimensions analytiques. Sans les jointures vers `raw_dim_product`, `raw_dim_store` et `raw_dim_date`, la table de ventes seule ne permettrait pas d'interpréter les catégories, les régions ou les tendances trimestrielles.

## Validation

Les validations minimales sont :

```sql
SHOW TABLES;

DESCRIBE raw_fact_sales;
DESCRIBE raw_dim_product;
DESCRIBE raw_dim_store;
DESCRIBE raw_dim_date;

SELECT COUNT(*) AS nb_ventes
FROM raw_fact_sales;

SELECT COUNT(*) AS ventes_sans_produit
FROM raw_fact_sales f
LEFT JOIN raw_dim_product p
    ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS ventes_sans_magasin
FROM raw_fact_sales f
LEFT JOIN raw_dim_store s
    ON f.store_id = s.store_id
WHERE s.store_id IS NULL;
```

Si les deux derniers résultats retournent `0`, les ventes peuvent être reliées correctement aux dimensions produit et magasin.

## Risques / limites

L'utilisation directe des tables `raw_fact_sales` comporte plusieurs limites importantes :

- Absence d'attributs descriptifs nécessaires à l'analyse stratégique.
- Absence de hiérarchies analytiques complètes, comme produit -> catégorie -> sous-catégorie et magasin -> région -> province.
- Difficulté à produire des indicateurs agrégés cohérents.
- Risque d'interprétation erronée des tendances.
- Analyses temporelles limitées sans dimension date.
- Modèle transactionnel non optimisé pour les analyses exécutives.

Dans cet état, les données ne permettent pas de soutenir adéquatement la prise de décision de la direction.

## Prochaine recommandation

La prochaine étape est de construire un schéma en étoile orienté OLAP :

- créer les dimensions analytiques nécessaires;
- transformer les tables `raw_*` vers des tables dimensionnelles finales;
- exécuter le pipeline analytique avec `make load` ou `.\run.ps1 load`.

Une fois les dimensions disponibles :

- vérifier la présence des attributs `category` et `region`;
- construire des agrégations de ventes par catégorie, région et trimestre;
- identifier les catégories en déclin selon les régions et les périodes temporelles.

Cette approche permettra de transformer les données transactionnelles en information stratégique exploitable par la direction.
