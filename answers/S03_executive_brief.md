# S03 Executive Brief

## Question du CEO

Comment garder des rapports fiables quand un client change de ville, de province ou de segment de fidelite?

## Réponse exécutive

NexaMart doit historiser les attributs analytiques de `dim_customer` avec une dimension SCD Type 2. Quand un client change de ville, de province ou de segment de fidelite, le modele conserve l'ancienne version et ouvre une nouvelle version. Ainsi, une vente faite avant le changement reste attribuee au bon contexte client historique, au lieu d'etre reecrite avec l'information actuelle.

## Décisions de modélisation

- `city`, `province` et `loyalty_segment` sont traites en SCD Type 2, car ils servent aux analyses par region et segment.
- `name_correction` est traite comme Type 1, car il corrige une erreur descriptive et ne change pas l'analyse historique.
- `dim_customer` contient maintenant `effective_from`, `effective_to` et `is_current`.
- Un meme `customer_id` peut avoir plusieurs versions, mais chaque version garde un `customer_key` unique.
- `fact_sales` joint `dim_customer` avec `order_date` entre `effective_from` et `effective_to`.

## Preuve

Requete de preuve a executer apres `.\run.ps1 load` en ouvrant `sql/analysis/s03-scd2-proof.sql` :

```sql
WITH changed_customer AS (
    SELECT customer_id
    FROM dim_customer
    GROUP BY customer_id
    HAVING COUNT(*) > 1
    ORDER BY customer_id
    LIMIT 1
)
SELECT
    c.customer_id,
    c.customer_key,
    c.city,
    c.province,
    c.loyalty_segment,
    c.effective_from,
    c.effective_to,
    c.is_current
FROM dim_customer c
JOIN changed_customer x
    ON c.customer_id = x.customer_id
ORDER BY c.effective_from;
```

Resultat obtenu :

| customer_id | customer_key | city | province | loyalty_segment | effective_from | effective_to | is_current | sales_lines | total_revenue |
|---|---:|---|---|---|---|---|---|---:|---:|
| CUS-00007 | 7 | Gatineau | QC | Silver | 1900-01-01 | 2025-02-05 | false | 0 | 0.00 |
| CUS-00007 | 8 | Gatineau | BC | Silver | 2025-02-06 | 9999-12-31 | true | 2 | 212.03 |

Ce resultat montre que le meme `customer_id` peut avoir plusieurs versions historiques, mais une seule version courante. Les ventes sont rattachees au `customer_key` valide a la date de commande.

## Validation

La validation se fait avec :

```powershell
.\run.ps1 load
.\run.ps1 check
```

Les controles importants pour S03 sont l'unicite de `customer_key` et la regle "une seule version courante par `customer_id`". Le modele preserve aussi les cles de vente, car `fact_sales.customer_key` est derive de la version client active a la date de commande.

## Risques / limites

Le modele S03 historise les changements clients importants, mais il ne traite pas encore les cas plus complexes comme les corrections retroactives, les changements recus en retard ou les chevauchements d'evenements contradictoires.

## Prochaine recommandation

Utiliser cette dimension client historisee comme base pour les prochaines analyses de declin, puis appliquer la meme logique aux autres dimensions lorsque leurs attributs deviennent importants pour les decisions executives.
