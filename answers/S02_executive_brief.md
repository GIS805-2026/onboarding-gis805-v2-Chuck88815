# S02 Executive Brief

## Question du CEO

Quel schéma en étoile rend notre question CEO répétable et fiable chaque mois?

## Réponse exécutive

Le premier modèle analytique NexaMart doit partir de `fact_sales`, au grain d'une ligne de commande. Ce grain permet d'analyser les ventes par produit, région, client, canal et période sans perdre le détail nécessaire aux analyses futures. Les dimensions conformes `dim_product`, `dim_store`, `dim_customer`, `dim_channel` et `dim_date` rendent les regroupements mensuels et trimestriels plus fiables que les tables transactionnelles brutes.

## Décisions de modélisation

- Grain de `fact_sales` : une ligne = une ligne de vente, identifiée par `order_number` et `sale_line_id`.
- Mesures principales : `quantity`, `unit_price`, `discount_pct`, `net_price`, `line_total` et `gross_amount`.
- Dimensions retenues : produit, magasin, client, canal et date.
- Les clés substituts (`product_key`, `store_key`, `customer_key`, `channel_key`) sont créées dans les dimensions et utilisées dans `fact_sales`.
- `order_number` reste dans la table de faits comme dimension dégénérée, car il décrit la transaction sans nécessiter une dimension séparée.
- Le diagramme du schéma en étoile est documenté dans `docs/schema-v1.md` et sa source Mermaid est dans `diagrams/schema-v1.mmd`.

## Preuve

Requête de preuve à exécuter après `.\run.ps1 load` :

```sql
SELECT
    p.category,
    s.region,
    d.year,
    d.quarter,
    SUM(f.line_total) AS total_revenue,
    SUM(f.quantity) AS total_units,
    COUNT(*) AS sales_lines
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.order_date_key = d.date_surrogate_key
GROUP BY p.category, s.region, d.year, d.quarter
ORDER BY total_revenue DESC
LIMIT 10;
```

Résultat obtenu :

| category | region | year | quarter | total_revenue | total_units | sales_lines |
|---|---|---:|---:|---:|---:|---:|
| Pet Supplies | Ontario | 2025 | 3 | 11487.44 | 71 | 26 |
| Books & Media | Québec | 2025 | 1 | 11117.10 | 86 | 31 |
| Toys & Games | Québec | 2025 | 3 | 10434.08 | 88 | 35 |
| Grocery | Québec | 2025 | 3 | 10406.49 | 125 | 52 |
| Grocery | Ontario | 2025 | 3 | 9929.96 | 121 | 49 |
| Toys & Games | Ontario | 2025 | 3 | 9665.87 | 80 | 31 |
| Toys & Games | Québec | 2025 | 1 | 9385.84 | 79 | 30 |
| Grocery | Ontario | 2025 | 2 | 9296.35 | 110 | 44 |
| Books & Media | Québec | 2025 | 3 | 8903.41 | 67 | 32 |
| Toys & Games | Ontario | 2025 | 2 | 8827.30 | 74 | 29 |

Ce résultat prouve que le schéma permet de regrouper les ventes par catégorie, région et trimestre, ce qui rend ensuite possible l'analyse des déclins.

## Validation

La validation se fait en exécutant :

```powershell
.\run.ps1 load
.\run.ps1 check
```

Les contrôles importants pour S02 sont : tables non vides, clés de dimensions uniques, clés étrangères non nulles dans `fact_sales`, et unicité du grain `(order_number, sale_line_id)`.

## Risques / limites

Le modèle S02 couvre les ventes, mais pas encore les retours, les budgets, les changements historiques de clients ou les problèmes de livraison. Les analyses de marge sont aussi limitées, car elles utilisent les coûts produits actuels plutôt qu'un historique complet des coûts.

## Prochaine recommandation

Utiliser cette étoile comme base stable pour répondre aux questions de ventes par catégorie, région et trimestre, puis enrichir le modèle avec les dimensions historisées et les faits de retour dans les prochaines séances.
