---
name: review-skills
description: >
  Review des mises à jour de skills proposées par la routine automatique.
  Affiche les avant/après pour chaque skill modifié et permet de valider
  individuellement ou tout d'un coup.
---

# Review Skills

Tu es un assistant de review. L'utilisateur veut valider les mises à jour de skills proposées automatiquement.

## Étape 1 — Localiser le repo skill-loop

```bash
SKILL_LOOP_REPO=$(cat ~/.claude/skill-loop-repo 2>/dev/null)
if [ -z "$SKILL_LOOP_REPO" ]; then
  echo "Erreur : ~/.claude/skill-loop-repo introuvable. Relancer ./install.sh"
  exit 1
fi
cd "$SKILL_LOOP_REPO"
git fetch origin
```

Vérifier si la branche `skill-updates` existe sur le remote :
```bash
git branch -r | grep skill-updates
```

Si elle n'existe pas : "Aucune mise à jour en attente. La prochaine exécution est planifiée automatiquement."

## Étape 2 — Lister les skills modifiés

```bash
git log origin/main..origin/skill-updates --oneline
```

Pour chaque commit, identifier le skill concerné (format : `refine(skill-name): ...`).

## Étape 3 — Présenter les reviews

Pour chaque skill modifié :

1. Lire le fichier `PENDING-REVIEW.md` sur la branche skill-updates :
   ```bash
   git show origin/skill-updates:skills/{nom}/PENDING-REVIEW.md
   ```

2. Afficher clairement :
   - Nom du skill
   - Changements proposés (bullet points)
   - Feedback intégré
   - Diff avant/après (les extraits clés)

3. Si `PENDING-REVIEW.md` n'existe pas :
   ```bash
   git diff origin/main..origin/skill-updates -- skills/{nom}/
   ```

## Étape 4 — Demander validation

Proposer :
- **"Valider tout"** — Merge toute la branche skill-updates dans main
- **"Valider un par un"** — Pour chaque skill, demander oui/non
- **"Tout rejeter"** — Supprimer la branche skill-updates

### Si "Valider tout"

```bash
cd "$SKILL_LOOP_REPO"
git checkout main
git merge origin/skill-updates --no-ff -m "merge: skill updates validées"
```

Pour chaque skill validé, reset le FEEDBACK.md dans `~/.claude/skills/{name}/` :
- Archiver le contenu dans `~/.claude/skills/{name}/FEEDBACK-ARCHIVE.md`
- Remplacer `~/.claude/skills/{name}/FEEDBACK.md` par :
  ```
  <!-- Feedback collecté par /refine-skills. Intégré périodiquement dans SKILL.md et GOTCHAS.md. -->
  ```

Supprimer les `PENDING-REVIEW.md` dans le repo.

Commit final :
```bash
cd "$SKILL_LOOP_REPO"
git add .
git commit -m "review: reset feedback après validation"
git push origin main
git push origin --delete skill-updates
```

### Si "Valider un par un"

Pour chaque skill :
- Si oui → cherry-pick le commit correspondant sur main
- Si non → skip

Après tous les reviews :
- Reset `~/.claude/skills/{name}/FEEDBACK.md` pour les skills validés
- Supprimer les `PENDING-REVIEW.md` correspondants
- Commit et push main
- Supprimer la branche skill-updates

### Si "Tout rejeter"

```bash
cd "$SKILL_LOOP_REPO"
git push origin --delete skill-updates
```

"Branche supprimée. Le feedback reste intact pour la prochaine itération."

## Règles

- Toujours montrer le contenu AVANT de demander validation
- Ne jamais modifier main sans validation explicite
- Après validation, toujours push pour que le repo soit à jour
