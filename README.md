# skill-loop

A self-improving skill management system for [Claude Code](https://claude.ai/code).

Your skills get better automatically — feedback flows in after each session, a routine refines the SKILL.md files, and you review the diff before it merges.

## How it works

```
Session ends
    ↓
/refine-skills          ← you run this, Claude extracts feedback
    ↓
~/.claude/skills/{name}/FEEDBACK.md
    ↓
refine-skills-loop      ← runs automatically on a schedule
    ↓
skill-updates branch    ← SKILL.md improvements, one commit per skill
    ↓
/review-skills          ← you validate the diff, then merge
    ↓
main branch             ← feedback reset, cycle restarts
```

## The 3 components

### `/refine-skills` — Collect feedback

Run at the end of a Claude session. Claude analyses the conversation, extracts what worked and what didn't for each skill used, proposes feedback, and saves it to `~/.claude/skills/{name}/FEEDBACK.md` after your validation.

### `refine-skills-loop` — Auto-refine routine

A scheduled task that runs automatically (daily/weekly). It scans `~/.claude/skills/` for pending feedback, applies improvements to the SKILL.md files in this repo (new rules, GOTCHAS.md, checklists), and pushes a `skill-updates` branch for review.

### `/review-skills` — Validate changes

Shows you a before/after diff for each modified skill. You validate all at once or one by one. Validated skills get merged into main and their FEEDBACK.md is reset for the next cycle.

## Install

```bash
git clone https://github.com/YOUR_USER/skill-loop.git
cd skill-loop
chmod +x install.sh
./install.sh
```

This will:
- Link `/refine-skills` skill → `~/.claude/skills/refine-skills/`
- Link `/review-skills` command → `~/.claude/commands/review-skills.md`
- Install the scheduled task → `~/.claude/scheduled-tasks/refine-skills-loop/`
- Save the repo path to `~/.claude/skill-loop-repo` (used by commands)

Then schedule the routine in a Claude session:
```
/schedule
→ create a scheduled task named "refine-skills-loop", weekly
```

## Adding your own skills

Drop a `SKILL.md` into `skills/{your-skill-name}/`. The loop will pick up feedback and refine it automatically.

```
skills/
└── your-skill/
    ├── SKILL.md        ← required
    ├── FEEDBACK.md     ← auto-managed (leave empty)
    └── GOTCHAS.md      ← created automatically when feedback recurs
```

See `SKILL-GUIDELINES.md` for best practices on writing skills.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- Git + a GitHub account (for the skill-updates branch workflow)
- A Claude Code session with `/schedule` available (for the routine)
