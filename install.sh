#!/bin/bash
# skill-loop install script
# Wires up refine-skills, review-skills, and the auto-refine routine into your Claude Code setup.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "skill-loop installer"
echo "===================="
echo "Repo: $REPO_DIR"
echo ""

# 1. Save repo path for commands/scheduled-tasks to reference
echo "$REPO_DIR" > "$CLAUDE_DIR/skill-loop-repo"
echo "✓ Saved repo path → ~/.claude/skill-loop-repo"

# 2. Link refine-skills skill
SKILL_DST="$CLAUDE_DIR/skills/refine-skills"
if [ -e "$SKILL_DST" ] && [ ! -L "$SKILL_DST" ]; then
  mv "$SKILL_DST" "$SKILL_DST.bak"
  echo "  Backed up existing refine-skills → refine-skills.bak"
fi
ln -sfn "$REPO_DIR/skills/refine-skills" "$SKILL_DST"
echo "✓ Linked skills/refine-skills → ~/.claude/skills/refine-skills"

# 3. Link review-skills command
mkdir -p "$CLAUDE_DIR/commands"
CMD_DST="$CLAUDE_DIR/commands/review-skills.md"
if [ -e "$CMD_DST" ] && [ ! -L "$CMD_DST" ]; then
  mv "$CMD_DST" "$CMD_DST.bak"
  echo "  Backed up existing review-skills.md"
fi
ln -sfn "$REPO_DIR/commands/review-skills.md" "$CMD_DST"
echo "✓ Linked commands/review-skills.md → ~/.claude/commands/review-skills.md"

# 4. Install scheduled task (copy, not symlink — path substitution needed)
TASK_DST="$CLAUDE_DIR/scheduled-tasks/refine-skills-loop"
mkdir -p "$CLAUDE_DIR/scheduled-tasks"
rm -rf "$TASK_DST"
cp -r "$REPO_DIR/scheduled-tasks/refine-skills-loop" "$TASK_DST"
echo "✓ Installed scheduled-tasks/refine-skills-loop → ~/.claude/scheduled-tasks/refine-skills-loop"

echo ""
echo "Done! Three components are now active:"
echo ""
echo "  /refine-skills     → collect feedback at end of sessions"
echo "  /review-skills     → validate and merge skill updates"
echo "  refine-skills-loop → auto-refine routine (needs scheduling, see below)"
echo ""
echo "─────────────────────────────────────────────────────"
echo "NEXT STEP — Schedule the auto-refine routine:"
echo ""
echo "  In a Claude Code session, run:"
echo "  /schedule"
echo ""
echo "  Then ask Claude to create a scheduled task named 'refine-skills-loop'"
echo "  pointing to: ~/.claude/scheduled-tasks/refine-skills-loop/SKILL.md"
echo "  Suggested frequency: daily or weekly"
echo "─────────────────────────────────────────────────────"
echo ""
echo "Also make sure this repo is connected to a GitHub remote:"
echo "  git remote add origin git@github.com:YOUR_USER/skill-loop.git"
echo "  git push -u origin main"
echo ""
