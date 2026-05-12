# Board Brief — S01

## Question du CEO

> « Quelles catégories déclinent dans quelles régions et pourquoi ? Chaque étudiant doit identifier sa première question exécutive. »

## Réponse exécutive

Les données actuellement disponibles sont structurées selon une logique OLTP (Online Transaction Processing), principalement orientée vers l’enregistrement des transactions opérationnelles. Dans leur état actuel, elles ne permettent pas de répondre efficacement à la question stratégique du CEO concernant les catégories en déclin par région.

Les tables brutes (raw_fact_* et raw_dim_*) contiennent principalement des identifiants transactionnels (product_id, store_id, customer_id) sans hiérarchies analytiques complètes permettant de produire des agrégations multidimensionnelles fiables.

Afin de produire une analyse exploitable pour la direction, il est nécessaire de transformer les données transactionnelles en un modèle OLAP (Online Analytical Processing) reposant sur un schéma en étoile.



## Décisions de modélisation
Pour répondre à la question exécutive, les décisions de modélisation suivantes sont proposées :

Construire une table de faits analytique fact_sales
Définir un grain analytique par produit vendu et par transaction
Créer plusieurs dimensions descriptives :
dim_product
dim_store
dim_customer
dim_date
Intégrer des hiérarchies analytiques :
produit → catégorie → sous-catégorie
magasin → région → province
Ajouter des attributs permettant les analyses exécutives :
catégorie
sous-catégorie
région
province
canal de vente
période temporelle

Cette structure permettra d’effectuer des analyses multidimensionnelles sur :

les ventes par catégorie,
les tendances régionales,
les variations temporelles,
les catégories en déclin.


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
L’utilisation directe des tables raw_fact_sales comporte plusieurs limites importantes :

Absence d’attributs descriptifs nécessaires à l’analyse stratégique
Absence de hiérarchies analytiques :
produit → catégorie → sous-catégorie
magasin → région → province
Difficulté à produire des indicateurs agrégés cohérents
Risque d’interprétation erronée des tendances
Analyses temporelles limitées
Modèle transactionnel non optimisé pour les analyses exécutives

Dans cet état, les données ne permettent pas de soutenir adéquatement la prise de décision de la direction.


## Prochaine recommandation
Construire un schéma en étoile (star schema) orienté OLAP
Créer les dimensions analytiques nécessaires
Transformer les tables raw_* vers des tables dimensionnelles finales
Exécuter le pipeline analytique : make load

Une fois les dimensions disponibles :

vérifier la présence des attributs category et region
construire des agrégations :
ventes par catégorie
ventes par région
évolution temporelle des catégories
identifier les catégories en déclin selon les régions et les périodes temporelles

Cette approche permettra de transformer les données transactionnelles en information stratégique exploitable par la direction.

