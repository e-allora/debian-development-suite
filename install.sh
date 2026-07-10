#!/bin/bash
# Debian Development Suite — Installer
# Symlinks all role skills into ~/.hermes/skills/
set -euo pipefail

SKILLS_DIR="$HOME/.hermes/skills"
SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing Debian Development Suite..."

# Symlink role skills
for skill_dir in "$SUITE_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    target="$SKILLS_DIR/$skill_name"

    if [ -L "$target" ] || [ -d "$target" ]; then
        echo "  SKIP $skill_name (already exists)"
    else
        ln -s "$skill_dir" "$target"
        echo "  LINK $skill_name → $target"
    fi
done

echo "Done. Suite installed at $SUITE_DIR"
echo "Load with: hermes -s debian-orchestrator-skill"
