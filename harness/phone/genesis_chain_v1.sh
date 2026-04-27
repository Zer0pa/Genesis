#!/system/bin/sh
# genesis_chain_v1.sh — master chain orchestrator (Genesis lane)
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Resume-safe: reads _state.json per cell; skips completed cells.
# Idempotent: if cells/<CELL>/outcome.json exists, cell is SKIP.
# POSIX-portable; busybox sh; no bash-isms.
#
# Manifest format: harness/cells.txt
#   One cell per line. Fields whitespace-separated:
#     CELL_ID [--task TASK] [--steps N] [--instances N]
#   Phase 0 example:
#     BITDET_01 --test-battery 10
#   Phase 1+ example:
#     K2_S30_01 --task exp_k2_scars --steps 30 --instances 6
#   Blank lines and lines starting with '#' are ignored.
set -eu

HARNESS_DIR="/data/local/tmp/genesis/harness"
CELLS_ROOT="/data/local/tmp/genesis/cells"
LOG_DIR="/data/local/tmp/genesis/logs"
MANIFEST="$HARNESS_DIR/cells.txt"
BINARY="/data/local/tmp/genesis/snic_rust"
EXPECTED_SHA=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --manifest)     MANIFEST="$2";     shift 2 ;;
    --binary)       BINARY="$2";       shift 2 ;;
    --expected-sha) EXPECTED_SHA="$2"; shift 2 ;;
    --cells-root)   CELLS_ROOT="$2";   shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$LOG_DIR" "$CELLS_ROOT"

CHAIN_LOG="$LOG_DIR/chain.log"

_log() {
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*" | tee -a "$CHAIN_LOG"
}

_log "genesis_chain_v1 starting manifest=$MANIFEST"

# ----------------------------------------------------------------
# Confirm namespace exists
# ----------------------------------------------------------------
if [ ! -d "/data/local/tmp/genesis" ]; then
  _log "ERROR: genesis deploy root does not exist; abort"
  exit 3
fi

if [ ! -f "$MANIFEST" ]; then
  _log "ERROR: manifest not found at $MANIFEST; abort"
  exit 4
fi

# ----------------------------------------------------------------
# Process each line of the manifest
# ----------------------------------------------------------------
while IFS= read -r raw_line; do
  # Strip leading/trailing whitespace
  line="$(printf "%s" "$raw_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # Skip blank lines and comments
  case "$line" in
    ''|\#*) continue ;;
  esac

  # ----------------------------------------------------------------
  # Parse: first token = CELL_ID, rest = per-cell args
  # ----------------------------------------------------------------
  CELL_ID=""
  CELL_TASK=""
  CELL_STEPS=""
  CELL_INSTANCES="6"
  CELL_TEST_BATTERY="10"
  parse_ok=1

  # Manual parse: read first token as CELL_ID then scan remaining pairs
  set -- $line
  CELL_ID="$1"
  shift

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --task)         CELL_TASK="$2";         shift 2 ;;
      --steps)        CELL_STEPS="$2";        shift 2 ;;
      --instances)    CELL_INSTANCES="$2";    shift 2 ;;
      --test-battery) CELL_TEST_BATTERY="$2"; shift 2 ;;
      *)
        _log "PARSE ERROR: cell=$CELL_ID unknown token '$1' in manifest line"
        parse_ok=0
        break
        ;;
    esac
  done

  # ----------------------------------------------------------------
  # On parse error: write KILL outcome and continue
  # ----------------------------------------------------------------
  if [ "$parse_ok" = "0" ] || [ -z "$CELL_ID" ]; then
    TS_ERR="$(date -u +%Y%m%dT%H%M%SZ)"
    if [ -n "$CELL_ID" ]; then
      CELL_DIR="$CELLS_ROOT/$CELL_ID"
      mkdir -p "$CELL_DIR"
      cat > "$CELL_DIR/outcome.json" <<OUTCOME_EOF
{
  "cell": "$CELL_ID",
  "verdict": "KILL",
  "summary": "manifest parse error on line",
  "metrics": {},
  "next_actions": ["fix manifest line for $CELL_ID"],
  "timestamp_utc": "$TS_ERR"
}
OUTCOME_EOF
    fi
    _log "KILL cell=${CELL_ID:-UNKNOWN}: manifest parse error; continuing"
    continue
  fi

  # ----------------------------------------------------------------
  # Idempotency: skip if outcome.json exists
  # ----------------------------------------------------------------
  CELL_DIR="$CELLS_ROOT/$CELL_ID"
  OUTCOME_FILE="$CELL_DIR/outcome.json"

  if [ -f "$OUTCOME_FILE" ]; then
    existing_verdict="$(grep '"verdict"' "$OUTCOME_FILE" \
      | sed -E 's/.*"verdict": *"([^"]*)".*/\1/' || printf "SKIP")"
    _log "SKIP cell=$CELL_ID: outcome.json exists (verdict=$existing_verdict)"
    continue
  fi

  mkdir -p "$CELL_DIR"

  # ----------------------------------------------------------------
  # State file: read _state.json for cell if present
  # (reserved for future partial-resume at instance granularity)
  # ----------------------------------------------------------------
  STATE_FILE="$CELL_DIR/_state.json"
  cell_state="pending"
  if [ -f "$STATE_FILE" ]; then
    cell_state="$(grep '"state"' "$STATE_FILE" \
      | sed -E 's/.*"state": *"([^"]*)".*/\1/' || printf "pending")"
    if [ "$cell_state" = "complete" ]; then
      _log "SKIP cell=$CELL_ID: _state.json shows complete"
      continue
    fi
  fi

  # Mark cell as in-progress
  TS_START="$(date -u +%Y%m%dT%H%M%SZ)"
  cat > "$STATE_FILE" <<STATE_EOF
{"cell": "$CELL_ID", "state": "in_progress", "started": "$TS_START"}
STATE_EOF

  _log "START cell=$CELL_ID task=${CELL_TASK:-<vanilla>} steps=${CELL_STEPS:-<none>} instances=$CELL_INSTANCES"

  # ----------------------------------------------------------------
  # Build launch_genesis_batch.sh args
  # ----------------------------------------------------------------
  BATCH_ARGS="--cell $CELL_ID --instances $CELL_INSTANCES"
  BATCH_ARGS="$BATCH_ARGS --binary $BINARY"
  BATCH_ARGS="$BATCH_ARGS --out-root $CELLS_ROOT"
  BATCH_ARGS="$BATCH_ARGS --test-id chain"
  if [ -n "$EXPECTED_SHA" ]; then
    BATCH_ARGS="$BATCH_ARGS --expected-sha $EXPECTED_SHA"
  fi
  if [ -n "$CELL_TASK" ]; then
    BATCH_ARGS="$BATCH_ARGS --task $CELL_TASK"
  fi
  if [ -n "$CELL_STEPS" ]; then
    BATCH_ARGS="$BATCH_ARGS --steps $CELL_STEPS"
  fi
  if [ -n "$CELL_TEST_BATTERY" ]; then
    BATCH_ARGS="$BATCH_ARGS --test-battery $CELL_TEST_BATTERY"
  fi

  # ----------------------------------------------------------------
  # Execute batch; capture verdict
  # ----------------------------------------------------------------
  batch_exit=0
  # shellcheck disable=SC2086
  "$HARNESS_DIR/launch_genesis_batch.sh" $BATCH_ARGS || batch_exit="$?"

  TS_END="$(date -u +%Y%m%dT%H%M%SZ)"

  # Derive verdict from batch outcome
  if [ "$batch_exit" = "0" ]; then
    cell_verdict="PASS"
  elif [ -f "$LOG_DIR/thermal_kill.log" ]; then
    cell_verdict="KILL"
  else
    cell_verdict="PARTIAL"
  fi

  # ----------------------------------------------------------------
  # Read summary metrics from batch _summary.json if present
  # ----------------------------------------------------------------
  SUMMARY_FILE="$CELLS_ROOT/$CELL_ID/_summary.json"
  summary_metrics="{}"
  if [ -f "$SUMMARY_FILE" ]; then
    summary_metrics="$(cat "$SUMMARY_FILE")"
  fi

  # ----------------------------------------------------------------
  # Write outcome.json
  # ----------------------------------------------------------------
  cat > "$OUTCOME_FILE" <<OUTCOME_EOF
{
  "cell": "$CELL_ID",
  "verdict": "$cell_verdict",
  "summary": "batch_exit=$batch_exit",
  "metrics": $summary_metrics,
  "next_actions": [],
  "timestamp_utc": "$TS_END"
}
OUTCOME_EOF

  # Update state to complete
  cat > "$STATE_FILE" <<STATE_EOF
{"cell": "$CELL_ID", "state": "complete", "started": "$TS_START", "ended": "$TS_END", "verdict": "$cell_verdict"}
STATE_EOF

  _log "DONE cell=$CELL_ID verdict=$cell_verdict"

done < "$MANIFEST"

_log "genesis_chain_v1 finished all manifest cells"
