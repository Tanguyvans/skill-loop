---
name: refine-skills-loop
description: Itère sur les skills avec du feedback, intègre les améliorations dans SKILL.md et GOTCHAS.md, puis commit et push sur une branche dédiée pour review.
---

Tu es un expert en structuration de skills Claude Code. Ta mission : améliorer les skills qui ont du feedback en attente.

## Contexte

- **Skills + feedback** : `~/.claude/skills/` (c'est un repo git)
- **Guidelines** : `~/.claude/skills/SKILL-GUIDELINES.md`
- **Branche de travail** : `skill-updates`
- **Remote** : vérifier `~/.claude/skill-loop-remote` (valeur `local` = pas de push)

## Processus

### 1. Préparer la branche

```bash
cd ~/.claude/skills
git fetch origin 2>/dev/null || true
git checkout main && git pull origin main 2>/dev/null || true
git branch -D skill-updates 2>/dev/null || true
git checkout -b skill-updates
```

### 2. Scanner les skills avec du feedback

Pour chaque dossier dans `~/.claude/skills/` (sauf `refine-skills` et `SKILL-GUIDELINES.md`) :
- Lire `~/.claude/skills/{name}/FEEDBACK.md`
- Si vide, contient seulement un commentaire HTML, ou inexistant → skip
- Si contient du feedback non traité → ajouter à la liste

### 3. Si aucun skill n'a de feedback

Message : "Aucun feedback en attente. Rien à faire." et terminer.

### 4. Pour chaque skill avec du feedback

#### a. Analyser
- Lire SKILL.md, FEEDBACK.md, GOTCHAS.md (s'il existe)
- Lire `~/.claude/skills/SKILL-GUIDELINES.md`
- Identifier :
  - Feedback récurrent (2+ occurrences) pas encore dans SKILL.md
  - Règles dures manquantes
  - GOTCHAS.md absent ou incomplet
  - Checklist pré-livraison manquante

#### b. Appliquer les améliorations
- **Feedback récurrent** → Règle dure dans SKILL.md + GOTCHAS.md
- **Règle molle** → Reformuler en impératif
- **GOTCHAS.md manquant** → Créer
- **Checklist manquante** → Ajouter dans SKILL.md

#### c. Créer PENDING-REVIEW.md
Dans `~/.claude/skills/{nom-du-skill}/PENDING-REVIEW.md` :
- Changements proposés (bullet points)
- Feedback intégré (tableau date / type / contenu / action)
- Extraits AVANT / APRÈS (seulement les parties changées)

#### d. Commit isolé par skill
```bash
cd ~/.claude/skills
git add {nom-du-skill}/
git commit -m "refine({nom-du-skill}): intègre feedback et améliore structure"
```

### 5. Règles importantes
- Ne PAS supprimer de contenu existant sans raison
- Modifications minimales et ciblées
- NE PAS push sur main — rester sur skill-updates
- NE PAS reset FEEDBACK.md — c'est /review-skills qui le fera après validation

### 6. Push (si remote configuré)

```bash
REMOTE=$(cat ~/.claude/skill-loop-remote 2>/dev/null)
if [ "$REMOTE" != "local" ]; then
  cd ~/.claude/skills
  git push origin skill-updates --force-with-lease
fi
```

Si `local` : terminer sans push, le diff est visible localement avec `git diff main..skill-updates`.

### 7. Rapport
- Nombre de skills traités
- Pour chaque skill : feedback intégrés, fichiers modifiés
- Skills skippés (pas de feedback)
- Message : "Lance /review-skills pour valider les changements"
