# skill-loop

A self-improving skill management system for [Claude Code](https://claude.ai/code).

Collect feedback → auto-refine → review diff → merge. Every skill gets better over time, with full git history so you can always revert.

## How it works

```
Session ends
    ↓
/refine-skills          ← extract feedback from the conversation
    ↓
~/.claude/skills/{name}/FEEDBACK.md
    ↓
refine-skills-loop      ← scheduled routine, runs automatically
    ↓
skill-updates branch    ← improved SKILL.md files, one commit per skill
    ↓
/review-skills          ← validate the diff, then merge
    ↓
main branch             ← feedback reset, cycle restarts
```

## Install

```bash
git clone https://github.com/Tanguyvans/skill-loop
cd skill-loop
chmod +x install.sh
./install.sh
```

`install.sh` will:
1. Link `/refine-skills` and `/review-skills` into your Claude Code setup
2. Install the auto-refine routine
3. Ask how you want to version your skills:
   - **Create a new GitHub repo** — we run `gh repo create` for you
   - **Use an existing repo** — provide a remote URL
   - **Local only** — git history without push (you can still revert)

Your skills live in `~/.claude/skills/`, which becomes a git repo during install.

## The 3 components

### `/refine-skills`
Run at the end of a session. Claude analyses the conversation, extracts what worked and what didn't for each skill, and saves validated feedback to `~/.claude/skills/{name}/FEEDBACK.md`.

### `refine-skills-loop`
Scheduled routine (daily/weekly). Reads pending feedback, improves SKILL.md files, creates a `skill-updates` branch with one commit per skill.

Schedule it in a Claude Code session:
```
/schedule → create "refine-skills-loop" weekly
```

### `/review-skills`
Shows before/after diffs for each modified skill. Validate all at once or one by one. Merged skills get their FEEDBACK.md reset for the next cycle.

## Adding your own skills

Drop a `SKILL.md` into `~/.claude/skills/{your-skill-name}/`. The loop picks up feedback automatically.

```
~/.claude/skills/
└── your-skill/
    ├── SKILL.md        ← required
    ├── FEEDBACK.md     ← auto-managed (start empty)
    └── GOTCHAS.md      ← created automatically when feedback recurs
```

See `SKILL-GUIDELINES.md` (copied to `~/.claude/skills/` during install) for best practices.

## Reverting a skill

Since `~/.claude/skills/` is a git repo:

```bash
cd ~/.claude/skills
git log --oneline           # find the commit to revert to
git checkout <sha> -- {skill-name}/SKILL.md
git commit -m "revert: {skill-name} to working version"
```

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Git
- `gh` CLI (only for GitHub sync — optional)
