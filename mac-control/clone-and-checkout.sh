#!/bin/bash
# clone-and-checkout.sh — re-clone genesis_comparative to a working dir
# Usage: clone-and-checkout.sh [WORK_DIR] [BRANCH]
set -eu
WORK="${1:-$HOME/genesis-comparative-clone}"
BRANCH="${2:-phase-3-prep-receipts-2026-04-29}"
if [ -d "$WORK" ]; then
  echo "ERROR: $WORK already exists. Remove it or pick a different path."
  exit 1
fi
git clone git@github.com:Zer0pa/Genesis.git "$WORK"
cd "$WORK"
git checkout "$BRANCH"
echo
echo "Cloned into: $WORK"
echo "Branch: $BRANCH"
echo "Latest commit:"
git log --oneline -1
echo
echo "Remember: when done, push your commits and DELETE this clone to keep Mac storage tight."
echo "  git push"
echo "  cd ~ && rm -rf $WORK"
