#!/bin/bash
# pull-receipts.sh — pull all completed cells from phone to a local dir
# Usage: pull-receipts.sh <DEST_DIR>
set -eu
DEV="${DEV:-FY25013101C8}"
DEST="${1:-$HOME/genesis-receipts-pull}"
mkdir -p "$DEST"
echo "Pulling /data/local/tmp/genesis/cells/ → $DEST/"
adb -s "$DEV" pull /data/local/tmp/genesis/cells/ "$DEST/"
echo "Done. Cells:"
ls "$DEST/cells/" 2>/dev/null | wc -l
echo
echo "If you need the σ″-curve aggregation, re-clone the repo and use:"
echo "  python3 scripts/aggregate_sigma_curve.py    # if such a script exists"
echo "or use the inline aggregator in proofs/artifacts/cells/ post-pull."
