# Trace d'usage IA - GIS805

> Chaque interaction significative avec un outil IA doit etre documentee ici.
> Ce fichier est obligatoire et evalue a chaque remise.

## Format par entree

```markdown
### YYYY-MM-DD - Seance SXX
- **Modele :** ChatGPT, Claude, Copilot, Codex, etc.
- **Prompt :** prompt exact ou resume fidele du prompt utilise.
- **Resultat :** ce que l'IA a produit ou aide a produire.
- **Validation :** comment le resultat a ete verifie ou corrige.
- **Justification :** pourquoi l'interaction etait utile pour le livrable.
```

---

### 2026-01-14 - Seance S01
- **Modele :** ChatGPT-5
- **Prompt :** "Donne des exemples d'agregations OLAP qui permettraient de repondre a la question : Quelles categories declinent dans quelles regions et pourquoi ? dans un entrepot de donnees."
- **Resultat :** L'IA a propose des agregations analytiques comme les ventes par categorie, les ventes par region, l'evolution temporelle des categories et la comparaison des performances selon les periodes.
- **Validation :** J'ai compare les exemples avec les dimensions disponibles ou a construire dans le futur schema en etoile (`dim_product`, `dim_store`, `dim_date`).
- **Justification :** Cette interaction m'a aide a structurer la recommandation executive et a identifier les analyses necessaires pour repondre a la question du CEO.

### 2026-01-14 - Seance S01
- **Modele :** ChatGPT-5
- **Prompt :** "Quels sont les principaux risques et limites lies a l'utilisation directe d'une table transactionnelle raw_fact_sales pour produire des analyses strategiques executives ?"
- **Resultat :** L'IA a identifie plusieurs limites : absence de hierarchies analytiques, difficulte a agreger les donnees, risque d'interpretation erronee et faible fiabilite pour des analyses multidimensionnelles.
- **Validation :** J'ai compare ces limites avec les attributs disponibles dans les tables brutes et avec les besoins analytiques par categorie, region et periode.
- **Justification :** Cette interaction m'a aide a completer la section "Risques / limites" avec des arguments relies aux concepts OLTP et OLAP vus dans le cours.

### 2026-01-14 - Seance S01
- **Modele :** ChatGPT-5
- **Prompt :** "Propose les decisions de modelisation necessaires pour transformer des donnees transactionnelles OLTP en un modele analytique OLAP permettant d'analyser les ventes par categorie et par region."
- **Resultat :** L'IA a recommande la creation d'un schema en etoile avec une table de faits `fact_sales` et des dimensions analytiques comme `dim_product`, `dim_store`, `dim_customer` et `dim_date`.
- **Validation :** J'ai compare les recommandations avec les concepts du cours sur les schemas en etoile et les entrepots dimensionnels.
- **Justification :** Cette interaction m'a aide a structurer la section "Decisions de modelisation" et a identifier les dimensions necessaires pour repondre a la question du CEO.

### 2026-01-14 - Seance S01
- **Modele :** ChatGPT-5
- **Prompt :** "Explique la difference entre le grain d'une table transactionnelle orientee commande et le grain d'une table de faits analytique orientee produit vendu. Donne un exemple dans un contexte de ventes."
- **Resultat :** L'IA a explique qu'un grain base seulement sur l'en-tete de commande ne permet pas certaines analyses detaillees par produit, tandis qu'un grain au niveau de la ligne de vente facilite les agregations multidimensionnelles.
- **Validation :** J'ai compare l'explication avec la structure de `raw_fact_sales` et avec les notions de granularite vues dans le cours.
- **Justification :** Cette interaction m'a aide a justifier pourquoi le grain de la future table de faits devait etre defini au niveau de la ligne de vente.

### 2026-05-12 - Seance S02
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Aide-moi a construire le livrable S02 pour NexaMart. Cree un schema en etoile avec `fact_sales` au grain d'une ligne de vente, les dimensions conformes `dim_product`, `dim_customer`, `dim_store`, `dim_date` et `dim_channel`, puis prepare une premiere version du brief executif `answers/S02_executive_brief.md`."
- **Resultat :** L'IA a cree les fichiers SQL des dimensions, la table de faits `fact_sales`, et une premiere version du brief executif S02.
- **Validation :** Les fichiers ont ete compares aux attentes du manifeste S02 : dimensions conformes, grain de `fact_sales`, mesures de vente et cles de jointure vers les dimensions.
- **Justification :** Cette interaction a servi a demarrer le livrable S02 avec une structure conforme au depot et aux attentes du cours.

### 2026-05-12 - Seance S02
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Complete le livrable S02 en ajoutant une requete SQL de preuve qui repond a la question du CEO : quelles categories de produits se vendent dans quelles regions, par trimestre ? La preuve doit regrouper `fact_sales` par categorie, region, annee et trimestre, puis retourner le revenu total, les unites vendues et le nombre de lignes de vente."
- **Resultat :** L'IA a ajoute `sql/analysis/s02-first-answer.sql`, ajoute `docs/board-briefs/s02-star-schema.md`, complete l'entree S02 dans `docs/decision-log.md`, puis ajuste le tableau de preuve dans `answers/S02_executive_brief.md` avec les resultats reels de DuckDB.
- **Validation :** La requete `sql/analysis/s02-first-answer.sql` a ete executee contre `db/nexamart.duckdb` et a retourne 10 lignes avec les colonnes attendues : `category`, `region`, `year`, `quarter`, `total_revenue`, `total_units`, `sales_lines`.
- **Justification :** Cette interaction a servi a completer les artefacts manquants du livrable S02 et a rendre la preuve SQL reproductible.

### 2026-05-15 - Seance S02
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Relis mon livrable S02 comme une revue avant remise. Compare `answers/S02_executive_brief.md` avec les consignes, le rubric, le sample brief et le manifeste S02. Dis-moi si le brief, la preuve SQL, les dimensions, la table de faits ou la validation ont des elements manquants."
- **Resultat :** L'IA a relu `answers/S02_executive_brief.md`, compare le brief avec `docs/s02-sample-brief.md`, `docs/board-briefs/s02-star-schema.md`, `docs/grading-rubric.md` et `validation/session_manifest.yaml`, puis a signale les points a ameliorer.
- **Validation :** Les artefacts S02 ont ete verifies dans le depot : `sql/analysis/s02-first-answer.sql`, `docs/schema-v1.md`, `diagrams/schema-v1.mmd`, `sql/facts/fact_sales.sql`, `sql/dims/dim_product.sql` et `sql/dims/dim_customer.sql`. Les controles S02 pertinents ont ete confirmes : `fact_sales` non vide, cles de dimensions uniques, cles etrangeres non nulles et grain unique `(order_number, sale_line_id)`.
- **Justification :** Cette interaction a servi de revue avant remise pour distinguer les vrais manques S02 des tables futures qui appartiennent aux seances suivantes.

### 2026-05-15 - Seance S03
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Explique-moi le prochain devoir apres S02. Lis le manifeste, les documents de reference et les templates SQL, puis resume les objectifs S03, les fichiers a creer ou modifier, les validations attendues et le concept de SCD Type 2 en mots simples."
- **Resultat :** L'IA a identifie que S03 porte sur les dimensions a changement lent, surtout `dim_customer`, et a explique qu'il faut conserver l'historique des changements de ville, province et segment de fidelite.
- **Validation :** Le resume a ete compare avec `validation/session_manifest.yaml`, `sql/templates/03_scd_type2.sql` et `docs/visuals/scd-type2-before-after.md`.
- **Justification :** Cette interaction a servi a comprendre le devoir S03 avant de modifier les fichiers du projet.

### 2026-05-15 - Seance S03
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Cree les nouveaux fichiers necessaires pour le devoir S03 et mets a jour les fichiers existants. Le livrable doit inclure un brief executif S03, une requete SQL de preuve, une dimension `dim_customer` en SCD Type 2 et une jointure de `fact_sales` vers la bonne version client selon la date de commande."
- **Resultat :** L'IA a transforme `sql/dims/dim_customer.sql` en dimension SCD2, ajuste la jointure client dans `sql/facts/fact_sales.sql`, cree `sql/analysis/s03-scd2-proof.sql`, ajoute `answers/S03_executive_brief.md` et documente la decision dans `docs/decision-log.md`.
- **Validation :** `.\run.ps1 load` a ete execute avec succes. `dim_customer` contient maintenant 235 versions pour 164 clients naturels. Les controles `dim_customer.customer_key` unique et une seule version courante par `customer_id` ont passe. La requete de preuve a montre deux versions pour `CUS-00007`.
- **Justification :** Cette interaction a servi a mettre en place les fichiers principaux du devoir S03 et a verifier que le modele preserve l'historique client.

### 2026-05-15 - Seance S03
- **Modele :** ChatGPT-5 / Codex
- **Prompt :** "Verifie le livrable S03 apres implementation. Execute le chargement, controle que `dim_customer` respecte le SCD Type 2, confirme qu'il existe une seule version courante par client, puis utilise une requete de preuve pour produire un exemple concret a mettre dans le brief executif."
- **Resultat :** L'IA a execute le pipeline, confirme la creation des versions historiques dans `dim_customer`, verifie les controles S03 et extrait un exemple avec deux versions pour `CUS-00007`.
- **Validation :** Le chargement DuckDB a reussi, les controles `customer_key` unique et `SCD2_ONE_CURRENT` ont passe, et le resultat de `sql/analysis/s03-scd2-proof.sql` a ete ajoute dans `answers/S03_executive_brief.md`.
- **Justification :** Cette interaction documente la validation humaine et technique du livrable, ce qui appuie la qualite de validation demandee dans la grille.
