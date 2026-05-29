#!/bin/sh
# Install the clean-room leak guard for this clone.
# Hooks are not cloned with the repo, so each clone / machine must run this once.
set -eu
ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

git config core.hooksPath .githooks
chmod +x .githooks/pre-commit .githooks/commit-msg

if [ ! -f leak-denylist.txt ]; then
  cp leak-denylist.example.txt leak-denylist.txt
  echo "Seeded leak-denylist.txt from the example. Edit it with the REAL terms to"
  echo "block (portfolio/LP/counterparty names, deal codenames, the principal's"
  echo "name and personal email domains, bank relationships). It is gitignored and"
  echo "never committed."
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "WARNING: gitleaks not found. Install it (e.g. 'brew install gitleaks') so the"
  echo "hook can scan staged changes for secrets."
fi

echo "Leak guard installed: core.hooksPath=.githooks (pre-commit + commit-msg)."
