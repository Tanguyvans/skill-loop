---
name: refine-skills
description: Analyse la conversation courante pour extraire des feedbacks actionnables sur les skills utilisés. Lancer avant de quitter la session. Déclenche sur "refine", "/refine-skills", "feedback sur le skill", "qu'est-ce qui a mal marché", "améliorer le skill".
---

# Refine Skills

Analyse la conversation courante et propose des feedbacks actionnables pour chaque skill utilisé.

## Workflow

1. **Identifier les skills utilisés** dans cette conversation (appels à `/skill-name`)

2. **Analyser la conversation** pour chaque skill :
   - Problèmes rencontrés (erreurs, résultats incorrects, retries)
   - Corrections que l'utilisateur a dû faire après l'exécution
   - Plaintes ou frustrations explicites
   - Suggestions d'amélioration mentionnées
   - Ce qui a bien fonctionné (feedback positif)
   - Étapes manquantes ou superflues dans le workflow

3. **Proposer les feedbacks** :
   ```
   ## Skill `{skill-name}`

   - [amelioration] {description du problème + suggestion concrète}
   - [positif] {ce qui a bien marché}
   - [bug] {comportement incorrect observé}
   - [manque] {étape ou instruction manquante}

   Tu valides ? Tu veux modifier ou ajouter quelque chose ?
   ```

4. **Attendre la validation** — l'utilisateur peut modifier, ajouter, ou supprimer des points

5. **Sauvegarder** les feedbacks validés dans `~/.claude/skills/{skill-name}/FEEDBACK.md` :
   - Ajouter à la suite (ne pas écraser)
   - Format :
   ```markdown
   ## {YYYY-MM-DD}

   - [amelioration] {description}
   - [positif] {description}
   - [bug] {description}
   - [manque] {description}
   ```

6. Si aucun skill n'a été utilisé : "Aucun skill utilisé dans cette session."

## Règles

- Feedbacks **actionnables** uniquement — pas de généralités
- Concis : l'utilisateur veut valider vite
- Lire le FEEDBACK.md existant avant de proposer — éviter les doublons
- Toujours sauvegarder dans `~/.claude/skills/{name}/FEEDBACK.md`
