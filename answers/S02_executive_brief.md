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
| Automotive | Ontario | 2025 | 4 | 6027.49 | 39 | 14 |
| Pet Supplies | Québec | 2025 | 3 | 5753.44 | 34 | 13 |
| Pet Supplies | Québec | 2025 | 4 | 5676.32 | 34 | 15 |
| Books & Media | Québec | 2025 | 4 | 5553.40 | 41 | 17 |
| Books & Media | Ontario | 2025 | 4 | 5262.22 | 38 | 12 |
| Pet Supplies | Québec | 2025 | 1 | 4981.45 | 30 | 12 |
| Automotive | Ontario | 2025 | 1 | 4733.92 | 32 | 14 |
| Toys & Games | Québec | 2025 | 2 | 4696.67 | 40 | 15 |
| Pet Supplies | Ontario | 2025 | 2 | 4554.66 | 27 | 13 |
| Automotive | Québec | 2025 | 2 | 4509.32 | 30 | 12 |

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
