#!/bin/bash
# skill-loop install
# Sets up refine-skills, review-skills, and the auto-refine routine.
# Creates or connects a personal skills repo at ~/.claude/skills/.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo ""
echo "skill-loop installer"
echo "===================="
echo ""

# ── 0. Ensure ~/.claude/skills/ exists ───────────────────────────────────────

mkdir -p "$SKILLS_DIR"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/scheduled-tasks"

# ── 1. Link refine-skills tool ────────────────────────────────────────────────

if [ -e "$SKILLS_DIR/refine-skills" ] && [ ! -L "$SKILLS_DIR/refine-skills" ]; then
  mv "$SKILLS_DIR/refine-skills" "$SKILLS_DIR/refine-skills.bak"
fi
ln -sfn "$REPO_DIR/skills/refine-skills" "$SKILLS_DIR/refine-skills"
echo "✓ /refine-skills skill linked"

# ── 2. Link review-skills command ─────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR/commands"
CMD_DST="$CLAUDE_DIR/commands/review-skills.md"
if [ -e "$CMD_DST" ] && [ ! -L "$CMD_DST" ]; then
  mv "$CMD_DST" "$CMD_DST.bak"
fi
ln -sfn "$REPO_DIR/commands/review-skills.md" "$CMD_DST"
echo "✓ /review-skills command linked"

# ── 3. Install scheduled task ─────────────────────────────────────────────────

mkdir -p "$CLAUDE_DIR/scheduled-tasks"
TASK_DST="$CLAUDE_DIR/scheduled-tasks/refine-skills-loop"
rm -rf "$TASK_DST"
cp -r "$REPO_DIR/scheduled-tasks/refine-skills-loop" "$TASK_DST"
echo "✓ refine-skills-loop routine installed"

# ── 4. Setup skills git repo ──────────────────────────────────────────────────

echo ""
echo "Your skills will be versioned in ~/.claude/skills/"
echo "This lets you revert any skill at any time with git."
echo ""
echo "Do you want to sync to GitHub? (recommended)"
echo "  [1] Create a new GitHub repo"
echo "  [2] Use an existing repo (fork or your own)"
echo "  [3] Local only — git history, no push"
echo ""
read -p "Choice [1/2/3]: " choice

# Init git in ~/.claude/skills/ if not already a repo
if [ ! -d "$SKILLS_DIR/.git" ]; then
  cd "$SKILLS_DIR"
  git init -b main
  # Copy SKILL-GUIDELINES.md for the routine to use
  cp "$REPO_DIR/SKILL-GUIDELINES.md" "$SKILLS_DIR/SKILL-GUIDELINES.md"
  git add .
  git commit -m "init: personal skills repo" 2>/dev/null || true
  echo "✓ Git initialized in ~/.claude/skills/"
fi

cd "$SKILLS_DIR"

case $choice in
  1)
    echo ""
    read -p "Name for your new GitHub repo [my-skills]: " repo_name
    repo_name="${repo_name:-my-skills}"
    if command -v gh &>/dev/null; then
      gh repo create "$repo_name" --public --source=. --remote=origin --push
      echo "✓ Created and pushed to github.com/$(gh api user --jq .login)/$repo_name"
    else
      echo ""
      echo "  'gh' CLI not found. Create the repo manually:"
      echo "  1. Go to https://github.com/new"
      echo "  2. Name it '$repo_name', leave it empty (no README)"
      echo "  3. Copy the HTTPS or SSH URL and paste below"
      echo ""
      read -p "  Remote URL: " remote_url
      cd "$SKILLS_DIR"
      git remote add origin "$remote_url" 2>/dev/null || git remote set-url origin "$remote_url"
      git push -u origin main
      echo "✓ Connected and pushed to $remote_url"
    fi
    echo "origin" > "$CLAUDE_DIR/skill-loop-remote"
    ;;
  2)
    echo ""
    read -p "Remote URL (e.g. git@github.com:you/my-skills.git): " remote_url
    git remote add origin "$remote_url" 2>/dev/null || git remote set-url origin "$remote_url"
    git push -u origin main
    echo "✓ Connected to $remote_url"
    echo "origin" > "$CLAUDE_DIR/skill-loop-remote"
    ;;
  3)
    echo "✓ Local only — git revert works, no push"
    echo "local" > "$CLAUDE_DIR/skill-loop-remote"
    ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done! Your skill-loop is ready."
echo ""
echo "  /refine-skills    — collect feedback at end of sessions"
echo "  /review-skills    — validate and merge skill improvements"
echo "  routine           — runs automatically (schedule it below)"
echo ""
echo "NEXT — Schedule the auto-refine routine:"
echo "  In a Claude Code session, type /schedule"
echo "  Ask Claude to schedule 'refine-skills-loop' weekly."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
