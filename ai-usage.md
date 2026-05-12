# Trace d'usage IA — GIS805

> Chaque interaction significative avec un outil IA doit être documentée ici.
> Ce fichier est **obligatoire** et évalué à chaque remise.

## Format par entrée

```
### YYYY-MM-DD — Séance SXX
- **Modèle :** (ChatGPT-4o, Claude, Copilot, etc.)
- **Prompt :** (copier-coller exact)
- **Résultat :** (résumé de ce que l'IA a produit)
- **Validation :** (comment vous avez vérifié/modifié le résultat)
- **Justification :** (pourquoi cette interaction était nécessaire)
```

---

### 2026-01-XX — Séance S00 *(exemple — supprimez cette entrée quand vous ajoutez les vôtres)*
- **Modèle :** GitHub Copilot Chat
- **Prompt :** « Qu'est-ce qui se trouve dans mon dépôt ? Explique-moi la structure du projet. »
- **Résultat :** Copilot a listé les dossiers principaux (sql/, answers/, data/, docs/) et expliqué le rôle de chacun dans le contexte d'un entrepôt dimensionnel.
- **Validation :** J'ai comparé la réponse avec le README.md et le contenu réel des dossiers — tout correspondait.
- **Justification :** Première prise de contact avec le dépôt ; je voulais comprendre l'organisation avant de lancer les commandes.

<!-- Ajoutez vos entrées ci-dessous -->
### 2026-05-12 — Séance S02
- **Modèle :** ChatGPT-5 / Codex
- **Prompt :** « ok can you create those files for me: sql/dims/dim_product.sql sql/dims/dim_customer.sql sql/dims/dim_store.sql sql/dims/dim_date.sql sql/dims/dim_channel.sql sql/facts/fact_sales.sql answers/S02_executive_brief.md »
- **Résultat :** L'IA a créé les fichiers SQL de dimensions, la table de faits `fact_sales`, et une première version du brief exécutif S02.
- **Validation :** À valider avec `.\run.ps1 load` puis `.\run.ps1 check`; les résultats réels de la requête de preuve doivent être ajoutés dans le brief.
- **Justification :** Cette interaction sert à démarrer le livrable S02 avec une structure conforme au dépôt et aux attentes du manifeste.

2026-01-14 — Séance S01
Modèle : ChatGPT-5
Prompt :
« Donne des exemples d’agrégations OLAP qui permettraient de répondre à la question : “Quelles catégories déclinent dans quelles régions et pourquoi ?” dans un entrepôt de données. »
Résultat :
L’IA a proposé plusieurs agrégations analytiques comme : ventes par catégorie, ventes par région, évolution temporelle des catégories et comparaison des performances selon les périodes.
Validation :
J’ai validé les exemples en les comparant avec les dimensions disponibles ou à construire dans le futur schéma en étoile (dim_product, dim_store, dim_date).
Justification :
Cette interaction m’a permis de structurer la section « Prochaine recommandation » et d’identifier les analyses nécessaires pour répondre à la question exécutive.

Modèle : ChatGPT-5
Prompt :
« Quels sont les principaux risques et limites liés à l’utilisation directe d’une table transactionnelle raw_fact_sales pour produire des analyses stratégiques exécutives ? »
Résultat :
L’IA a identifié plusieurs limites : absence de hiérarchies analytiques, difficulté à agréger les données, risque d’interprétation erronée et incapacité à produire des analyses multidimensionnelles fiables.
Validation :
J’ai validé les éléments en comparant les attributs disponibles dans les tables avec les besoins analytiques nécessaires pour produire des indicateurs par catégorie, région et période temporelle.
Justification :
Cette interaction m’a aidé à compléter la section « Risques / limites » avec des arguments cohérents reliés aux concepts OLTP et OLAP vus dans le cours.

2026-01-14 — Séance S01
Modèle : ChatGPT-5
Prompt :
« Propose les décisions de modélisation nécessaires pour transformer des données transactionnelles OLTP en un modèle analytique OLAP permettant d’analyser les ventes par catégorie et par région. »
Résultat :
L’IA a recommandé la création d’un schéma en étoile avec une table de faits fact_sales ainsi que plusieurs dimensions analytiques comme dim_product, dim_store, dim_customer et dim_date.
Validation :
J’ai comparé les recommandations avec les concepts vus en cours sur les schémas en étoile et les entrepôts dimensionnels afin de confirmer leur cohérence avec les bonnes pratiques OLAP.
Justification :
Cette interaction m’a aidé à structurer la section « Décisions de modélisation » et à identifier les dimensions nécessaires pour répondre à la question du CEO.

2026-01-14 — Séance S01
Modèle : ChatGPT-5
Prompt :
« Explique la différence entre le grain d’une table transactionnelle orientée commande et le grain d’une table de faits analytique orientée produit vendu. Donne un exemple dans un contexte de ventes. »
Résultat :
L’IA a expliqué que le grain actuel basé sur la commande ne permet pas certaines analyses détaillées par produit, tandis qu’un grain ajusté au niveau du produit vendu facilite les agrégations analytiques et les analyses multidimensionnelles.
Validation :
J’ai comparé l’explication avec la structure de raw_fact_sales et les concepts de granularité vus en cours afin de confirmer que le niveau transactionnel actuel était insuffisant pour les besoins analytiques.
Justification :
Cette interaction m’a aidé à mieux justifier pourquoi une modification du grain de la table de faits était nécessaire dans la section « Décisions de modélisation ».
