# Decision Log - entrepot NexaMart

Ce journal documente les choix de modelisation importants du projet. Chaque entree explique le contexte, la decision retenue, les alternatives ecartees et les consequences pour les prochains livrables.

## Decisions

### D01 - Definir `fact_sales` au grain de la ligne de vente

- **Date / seance :** 2026-05-12 (S02)
- **Contexte :** La question CEO du S02 demande d'analyser les ventes par categorie de produit, region et trimestre. Un grain au niveau de l'en-tete de commande masquerait les categories lorsqu'une commande contient plusieurs produits.
- **Decision :** Une ligne de `fact_sales` represente une ligne de vente, identifiee par `(order_number, sale_line_id)`.
- **Alternatives ecartees :**
  - Grain en-tete de commande : trop grossier pour analyser correctement les categories de produits.
  - Grain evenement de paiement : trop detaille pour la question S02 et inutile sans analyse des paiements.
- **Consequences :** Les mesures comme `quantity`, `line_total` et `gross_amount` peuvent etre additionnees par categorie, region et periode. `order_number` reste dans `fact_sales` comme dimension degeneree pour permettre des analyses par commande sans creer une dimension separee.
- **Revisable si :** Le projet doit analyser des paiements fractionnes, des remboursements partiels ou des evenements transactionnels plus fins que la ligne de vente.
- **References :** `sql/facts/fact_sales.sql`, `sql/analysis/s02-first-answer.sql`, `answers/S02_executive_brief.md`, `docs/schema-v1.md`.

### D02 - Utiliser cinq dimensions conformes pour la premiere etoile

- **Date / seance :** 2026-05-12 (S02)
- **Contexte :** La question CEO doit etre repetable chaque mois sans revenir aux tables transactionnelles brutes. Les regroupements par categorie, region, client, canal et periode doivent donc venir de dimensions stables.
- **Decision :** La premiere etoile utilise `dim_product`, `dim_store`, `dim_customer`, `dim_channel` et `dim_date` autour de `fact_sales`.
- **Alternatives ecartees :**
  - Garder les attributs descriptifs directement dans `fact_sales` : duplication elevee et regroupements moins fiables.
  - Creer une seule grande table aplatie : plus simple au debut, mais moins maintenable pour les prochains faits.
- **Consequences :** Les prochaines analyses pourront reutiliser ces dimensions conformes pour comparer les ventes avec d'autres faits, comme les retours ou les budgets.
- **Revisable si :** Une future seance introduit une nouvelle question qui exige une dimension supplementaire ou une historisation plus avancee.
- **References :** `sql/dims/dim_product.sql`, `sql/dims/dim_store.sql`, `sql/dims/dim_customer.sql`, `sql/dims/dim_channel.sql`, `sql/dims/dim_date.sql`, `docs/schema-v1.md`.
