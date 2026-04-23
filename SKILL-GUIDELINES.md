# Skill Guidelines

Guide pour structurer et maintenir des skills Claude Code de qualité.

## Structure d'un skill

```
skill-name/
├── SKILL.md           # Instruction principale (obligatoire)
├── FEEDBACK.md        # Historique du feedback utilisateur (auto-alimenté par /refine-skills)
├── GOTCHAS.md         # Erreurs connues et règles dures extraites du feedback
├── evals/             # Tests de non-régression (optionnel)
│   └── evals.json
├── scripts/           # Scripts shell auxiliaires (optionnel)
├── templates/         # Fichiers de référence (optionnel)
├── references/        # Exemples, docs de référence (optionnel)
└── .env               # Secrets (gitignored)
```

## SKILL.md — Le coeur du skill

### Frontmatter obligatoire

```yaml
---
name: skill-name
description: >
  Quand déclencher ce skill. Doit lister les mots-clés et phrases
  qui activent le skill. Sois explicite et exhaustif.
---
```

### Sections recommandées

1. **Contexte** — En 2-3 phrases, qu'est-ce que ce skill fait et pourquoi
2. **Workflow** — Étapes numérotées du processus
3. **Format de sortie** — Template exact ou structure attendue
4. **Contraintes de style** — Règles de formatage, ton, langue
5. **Règles dures** — Interdictions explicites (ex: "JAMAIS de tirets longs")
6. **Checklist pré-livraison** — Vérifications à faire avant de rendre le résultat

### Bonnes pratiques

- Les règles dures doivent être dans SKILL.md, pas seulement dans FEEDBACK.md
- Utiliser des formulations impératives : "Toujours X", "Jamais Y"
- Mettre les contraintes les plus violées en haut (visibilité maximale)
- Inclure des exemples concrets pour les règles ambiguës

## GOTCHAS.md — Le filet de sécurité

Fichier qui liste les erreurs **récurrentes** extraites du feedback. Le skill DOIT lire ce fichier avant chaque exécution.

### Format

```markdown
# Gotchas

Erreurs récurrentes à vérifier AVANT de livrer.

## Style
- [ ] Pas de tirets longs (—) → utiliser des virgules ou points
- [ ] Pas de deux-points (:) dans le corps du texte
- [ ] CTA par défaut : "Voilà l'URL et à demain."

## Contenu
- [ ] Fact-checker les claims techniques (lire le README, pas juste le résumé)
- [ ] Pas de jargon technique sauf si le public est explicitement dev

## Process
- [ ] Lire FEEDBACK.md avant de générer
- [ ] Proposer 3+ options de hook avant validation
```

### Quand créer un GOTCHAS.md

Dès qu'un feedback apparaît **2+ fois** dans FEEDBACK.md, il devient un gotcha. C'est le signal qu'une contrainte n'est pas assez visible dans SKILL.md.

## FEEDBACK.md — L'historique

Alimenté automatiquement par `/refine-skills`. Ne pas éditer manuellement sauf pour nettoyer.

### Cycle de vie du feedback

```
1. Utilisateur utilise le skill
2. /refine-skills collecte le feedback → FEEDBACK.md
3. Scheduled task analyse FEEDBACK.md
4. Feedback récurrent → intégré dans SKILL.md (règles dures) + GOTCHAS.md
5. Feedback ponctuel → reste dans FEEDBACK.md comme historique
6. Commit + push pour versionner le changement
```

## evals/ — Tests de non-régression

Fichier `evals.json` avec des cas de test pour vérifier que le skill ne régresse pas.

```json
[
  {
    "input": "description du cas de test",
    "expected": "comportement attendu",
    "checks": ["pas de tirets longs", "CTA correct", "hook avec tension"]
  }
]
```

## Checklist de qualité pour un skill

- [ ] Le `description` dans le frontmatter est assez spécifique pour bien trigger
- [ ] Le workflow est numéroté et séquentiel
- [ ] Les règles dures sont explicites et en haut du fichier
- [ ] Le format de sortie est un template concret, pas une description vague
- [ ] GOTCHAS.md existe si le skill a 2+ sessions de feedback
- [ ] Le skill lit FEEDBACK.md et GOTCHAS.md dans son workflow
- [ ] Pas de dépendance à des fichiers .env non documentés
- [ ] Le skill propose des options (hooks, angles) avant de livrer une version finale

## Anti-patterns à éviter

1. **Feedback fantôme** — Le feedback est dans FEEDBACK.md mais jamais intégré dans SKILL.md
2. **Règle molle** — "Essayer d'éviter les tirets longs" vs "JAMAIS de tirets longs (—)"
3. **Skill amnésique** — Ne lit pas son propre FEEDBACK.md/GOTCHAS.md avant de générer
4. **Sur-description** — 500 lignes de SKILL.md quand 100 suffisent
5. **Pas de checklist** — Le skill livre sans vérifier ses propres contraintes
