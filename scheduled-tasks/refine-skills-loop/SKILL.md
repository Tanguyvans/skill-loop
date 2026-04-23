---
name: refine-skills-loop
description: Itère sur les skills avec du feedback, intègre les améliorations dans SKILL.md et GOTCHAS.md, puis commit et push sur une branche dédiée pour review.
---

Tu es un expert en structuration de skills Claude Code. Ta mission : améliorer les skills qui ont du feedback en attente, sur une branche dédiée.

## Contexte

```bash
SKILL_LOOP_REPO=$(cat ~/.claude/skill-loop-repo 2>/dev/null)
```

- **Repo** : `$SKILL_LOOP_REPO`
- **Skills dans le repo** : `$SKILL_LOOP_REPO/skills/`
- **Feedback** : `~/.claude/skills/{name}/FEEDBACK.md` ← c'est ICI que vit le feedback
- **Guidelines** : `$SKILL_LOOP_REPO/SKILL-GUIDELINES.md`
- **Branche de travail** : `skill-updates`

## Processus

### 1. Préparer la branche

```bash
SKILL_LOOP_REPO=$(cat ~/.claude/skill-loop-repo)
cd "$SKILL_LOOP_REPO"
git fetch origin
git checkout main && git pull origin main
git branch -D skill-updates 2>/dev/null || true
git checkout -b skill-updates
```

### 2. Scanner les skills avec du feedback

Pour chaque dossier dans `~/.claude/skills/` (sauf `refine-skills`) :
- Lire `~/.claude/skills/{name}/FEEDBACK.md`
- Si vide, contient seulement un commentaire HTML, ou inexistant → skip
- Si contient du feedback non traité → ajouter à la liste

Le SKILL.md à améliorer est dans `$SKILL_LOOP_REPO/skills/{name}/SKILL.md`.
Si le dossier n'existe pas encore dans le repo, le créer.

### 3. Si aucun skill n'a de feedback

Message : "Aucun feedback en attente. Rien à faire." et terminer.

### 4. Pour chaque skill avec du feedback

#### a. Analyser
- Lire SKILL.md, FEEDBACK.md, GOTCHAS.md (s'il existe) depuis le repo
- Lire SKILL-GUIDELINES.md pour les bonnes pratiques
- Identifier :
  - Feedback récurrent (2+ occurrences) pas encore dans SKILL.md
  - Règles dures manquantes
  - GOTCHAS.md absent ou incomplet
  - Checklist pré-livraison manquante
  - Anti-patterns

#### b. Appliquer les améliorations
- **Feedback récurrent** → Règle dure dans SKILL.md + GOTCHAS.md
- **Règle molle** → Reformuler en impératif
- **GOTCHAS.md manquant** → Créer
- **Checklist manquante** → Ajouter dans SKILL.md
- **Workflow sans lecture GOTCHAS** → Ajouter l'étape

#### c. Préparer le résumé avant/après
Créer `$SKILL_LOOP_REPO/skills/{nom-du-skill}/PENDING-REVIEW.md` avec :
- Changements proposés (bullet points)
- Feedback intégré (tableau avec occurrences et actions)
- Extraits AVANT modification (seulement les parties changées)
- Extraits APRÈS modification

#### d. Commit isolé par skill
```bash
cd "$SKILL_LOOP_REPO"
git add skills/{nom-du-skill}/
git commit -m "refine({nom-du-skill}): intègre feedback et améliore structure"
```

### 5. Règles importantes
- Ne PAS supprimer de contenu existant sans raison
- Ne PAS changer le format de sortie sans raison forte
- Préserver la voix/ton du skill
- Modifications minimales et ciblées
- NE PAS push sur main — rester sur skill-updates
- NE PAS reset FEEDBACK.md — c'est /review-skills qui le fera après validation

### 6. Push la branche
```bash
cd "$SKILL_LOOP_REPO"
git push origin skill-updates --force-with-lease
```

### 7. Rapport
Résume :
- Nombre de skills traités
- Pour chaque skill : nombre de feedback intégrés, fichiers modifiés
- Skills sans feedback (skippés)
- Message : "Lance /review-skills pour valider les changements"
