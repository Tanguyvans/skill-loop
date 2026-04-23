---
name: review-skills
description: >
  Review des mises à jour de skills proposées par la routine automatique.
  Affiche les avant/après pour chaque skill modifié et permet de valider
  individuellement ou tout d'un coup.
---

# Review Skills

Tu es un assistant de review. L'utilisateur veut valider les mises à jour proposées par la routine.

## Étape 1 — Vérifier les updates en attente

```bash
REMOTE=$(cat ~/.claude/skill-loop-remote 2>/dev/null || echo "local")
cd ~/.claude/skills

if [ "$REMOTE" != "local" ]; then
  git fetch origin
fi

git branch -r | grep skill-updates || git branch | grep skill-updates
```

Si la branche `skill-updates` n'existe pas : "Aucune mise à jour en attente."

## Étape 2 — Lister les skills modifiés

```bash
cd ~/.claude/skills
# Remote
git log origin/main..origin/skill-updates --oneline 2>/dev/null
# ou local
git log main..skill-updates --oneline 2>/dev/null
```

## Étape 3 — Présenter les reviews

Pour chaque skill modifié, lire le `PENDING-REVIEW.md` :
```bash
# Remote
git show origin/skill-updates:{nom}/PENDING-REVIEW.md
# Local
git show skill-updates:{nom}/PENDING-REVIEW.md
```

Si absent, afficher le diff :
```bash
git diff main..skill-updates -- {nom}/
```

Afficher pour chaque skill :
- Changements proposés
- Feedback intégré
- Extraits avant/après

## Étape 4 — Demander validation

- **"Valider tout"** — merge skill-updates dans main
- **"Valider un par un"** — oui/non par skill
- **"Tout rejeter"** — supprimer la branche

### Si "Valider tout"

```bash
cd ~/.claude/skills
git checkout main
git merge skill-updates --no-ff -m "merge: skill updates validées"
```

Pour chaque skill validé, reset le FEEDBACK.md :
```bash
# Archiver
cat ~/.claude/skills/{name}/FEEDBACK.md >> ~/.claude/skills/{name}/FEEDBACK-ARCHIVE.md
# Vider
echo '<!-- Feedback collecté par /refine-skills. Intégré périodiquement dans SKILL.md et GOTCHAS.md. -->' \
  > ~/.claude/skills/{name}/FEEDBACK.md
```

Supprimer les PENDING-REVIEW.md, commit final :
```bash
cd ~/.claude/skills
git add .
git commit -m "review: reset feedback après validation"

REMOTE=$(cat ~/.claude/skill-loop-remote 2>/dev/null || echo "local")
if [ "$REMOTE" != "local" ]; then
  git push origin main
  git push origin --delete skill-updates
else
  git branch -D skill-updates
fi
```

### Si "Valider un par un"

Pour chaque skill :
- Oui → `git cherry-pick` le commit sur main
- Non → skip

Reset FEEDBACK.md des skills validés, commit + push/branch cleanup.

### Si "Tout rejeter"

```bash
cd ~/.claude/skills
REMOTE=$(cat ~/.claude/skill-loop-remote 2>/dev/null || echo "local")
if [ "$REMOTE" != "local" ]; then
  git push origin --delete skill-updates
else
  git branch -D skill-updates
fi
```

"Branche supprimée. Le feedback reste intact pour la prochaine itération."

## Règles
- Toujours montrer le contenu AVANT de demander validation
- Ne jamais modifier main sans validation explicite
- Après validation, toujours pousser (si remote configuré)
