#!/system/bin/sh
# launch_genesis_batch.sh — fan-out parallel Genesis batch across cpu0..cpu5
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Adapted from dm3_parallel/scripts/launch_parallel_batch.sh
# POSIX-portable; busybox sh; no bash-isms.
set -eu

SCRIPT_DIR="/data/local/tmp/genesis/harness"
BINARY="/data/local/tmp/genesis/snic_rust"
OUT_ROOT="/data/local/tmp/genesis/cells"
LOG_DIR="/data/local/tmp/genesis/logs"
CELL=""
STEPS=""
INSTANCES="6"
TASK=""
EXPECTED_SHA=""
TEST_ID="batch"
TEST_BATTERY=""

# Per-instance taskset masks. RM10 / SD8 Gen 3 has Qualcomm core_ctl that
# dynamically pauses 1-2 cores in cluster cpu0-5; per-instance pinning to
# transiently-paused cores returns sched_setaffinity EINVAL, breaking 6/6
# parallel runs (instances pinned to cpu3-5 fail). Mitigation: pin the
# PARENT batch process to cpu0-6 (mask 7F, excludes cpu7=dm3) and pass
# "auto" to each instance so the kernel scheduler distributes the 6
# children across the active subset of cpu0-6. Determinism is unaffected
# (snic_rust output is byte-identical regardless of cpu).
DEFAULT_MASKS="auto auto auto auto auto auto"
PARENT_AFFINITY_MASK="7F"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --cell)         CELL="$2";         shift 2 ;;
    --steps)        STEPS="$2";        shift 2 ;;
    --instances)    INSTANCES="$2";    shift 2 ;;
    --task)         TASK="$2";         shift 2 ;;
    --expected-sha) EXPECTED_SHA="$2"; shift 2 ;;
    --binary)       BINARY="$2";       shift 2 ;;
    --out-root)     OUT_ROOT="$2";     shift 2 ;;
    --test-id)      TEST_ID="$2";      shift 2 ;;
    --test-battery) TEST_BATTERY="$2"; shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

[ -n "$CELL" ] || { printf "--cell required\n" >&2; exit 2; }

mkdir -p "$LOG_DIR"
mkdir -p "$OUT_ROOT/$CELL"

BATCH_LOG="$LOG_DIR/batch_${CELL}_${TEST_ID}.log"

_log() {
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*" >> "$BATCH_LOG"
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*"
}

_log "launch_genesis_batch: cell=$CELL instances=$INSTANCES task=${TASK:-<vanilla>}"

# ----------------------------------------------------------------
# Set parent affinity to cpu0-6 (mask 7F) so children inherit and the
# kernel scheduler distributes them away from cpu7=dm3-RESERVED.
# ----------------------------------------------------------------
if [ -n "$PARENT_AFFINITY_MASK" ]; then
  if taskset -p "$PARENT_AFFINITY_MASK" "$$" >/dev/null 2>&1; then
    _log "parent affinity set to mask=$PARENT_AFFINITY_MASK (cpu0-6)"
  else
    _log "WARNING: failed to set parent affinity to mask=$PARENT_AFFINITY_MASK; children may run on cpu7"
  fi
fi

# ----------------------------------------------------------------
# Collision check: dm3_runner namespace (log only; Genesis is independent)
# ----------------------------------------------------------------
dm3_pid="$(pidof dm3_runner 2>/dev/null || true)"
if [ -n "$dm3_pid" ]; then
  _log "WARNING: dm3_runner running (pid=$dm3_pid); Genesis namespace is independent; continuing"
fi

# ----------------------------------------------------------------
# SAFETY: refuse to use cpu7 (dm3-RESERVED)
# The mask 0x80 must never appear. cpu6 (0x40) is thermal margin,
# not in the default set; it is operator-controlled.
# ----------------------------------------------------------------
# Compute masks for INSTANCES up to 6 (cpu0..cpu5)
# If INSTANCES > 6, cap at 6 and warn.
if [ "$INSTANCES" -gt 6 ]; then
  _log "WARNING: --instances $INSTANCES > 6; capping at 6 (cpu0-cpu5 only; cpu6=margin cpu7=dm3-RESERVED)"
  INSTANCES=6
fi

# ----------------------------------------------------------------
# Spawn thermal coordinator
# ----------------------------------------------------------------
THERMAL_STOP="$LOG_DIR/thermal_stop_${CELL}.flag"
THERMAL_LOG="$LOG_DIR/thermal.log"
rm -f "$THERMAL_STOP"

"$SCRIPT_DIR/thermal_coordinator.sh" \
  --parent-pid "$$" \
  --stop-flag "$THERMAL_STOP" \
  --log "$THERMAL_LOG" &
thermal_pid="$!"
_log "thermal_coordinator spawned pid=$thermal_pid"

# ----------------------------------------------------------------
# Launch N instances across cpu0..cpuN-1
# Each instance gets exclusive mask for one cpu.
# ----------------------------------------------------------------
pids=""
instance=0

# Build the mask list for the requested count
masks="$DEFAULT_MASKS"
mask_idx=0
for m in $masks; do
  if [ "$mask_idx" -ge "$INSTANCES" ]; then
    break
  fi
  CELL_ARGS="--cell $CELL --instance $instance --core $m"
  CELL_ARGS="$CELL_ARGS --binary $BINARY"
  CELL_ARGS="$CELL_ARGS --out-root $OUT_ROOT"
  CELL_ARGS="$CELL_ARGS --test-id $TEST_ID"
  if [ -n "$EXPECTED_SHA" ]; then
    CELL_ARGS="$CELL_ARGS --expected-sha $EXPECTED_SHA"
  fi
  if [ -n "$TASK" ]; then
    CELL_ARGS="$CELL_ARGS --task $TASK"
    if [ -n "$STEPS" ]; then
      CELL_ARGS="$CELL_ARGS --steps $STEPS"
    fi
  fi
  if [ -n "$TEST_BATTERY" ]; then
    CELL_ARGS="$CELL_ARGS --test-battery $TEST_BATTERY"
  fi

  # shellcheck disable=SC2086
  "$SCRIPT_DIR/run_genesis_cell.sh" $CELL_ARGS &
  child_pid="$!"
  _log "spawned instance=$instance mask=$m pid=$child_pid"
  pids="$pids $child_pid"
  instance="$((instance + 1))"
  mask_idx="$((mask_idx + 1))"
done

# ----------------------------------------------------------------
# Wait for all instances
# ----------------------------------------------------------------
failures=0
for pid in $pids; do
  if ! wait "$pid"; then
    _log "instance pid=$pid exited non-zero"
    failures="$((failures + 1))"
  fi
done

_log "all instances finished; failures=$failures"

# ----------------------------------------------------------------
# Kill thermal coordinator gracefully
# ----------------------------------------------------------------
touch "$THERMAL_STOP"
# Give it a moment to write final entries, then kill if still alive
sleep 2
kill "$thermal_pid" 2>/dev/null || true
wait "$thermal_pid" 2>/dev/null || true
_log "thermal_coordinator stopped"

# ----------------------------------------------------------------
# Aggregate per-instance receipts into _summary.json
# ----------------------------------------------------------------
SUMMARY="$OUT_ROOT/$CELL/_summary.json"
TS_NOW="$(date -u +%Y%m%dT%H%M%SZ)"

# Collect canonical SHAs and best_uplift values
unique_shas=""
unique_uplifts=""
receipt_count=0

for receipt in "$OUT_ROOT/$CELL"/*/receipt.json; do
  [ -f "$receipt" ] || continue
  sha="$(grep '"canonical_sha"' "$receipt" \
    | sed -E 's/.*"canonical_sha": *"([^"]*)".*/\1/' || true)"
  uplift="$(grep '"best_uplift"' "$receipt" \
    | sed -E 's/.*"best_uplift": *([^,}]*).*/\1/' \
    | tr -d '"' || true)"
  unique_shas="$unique_shas $sha"
  unique_uplifts="$unique_uplifts $uplift"
  receipt_count="$((receipt_count + 1))"
done

unique_sha_count="$(printf "%s\n" $unique_shas | sort -u | sed '/^$/d' | wc -l | tr -d ' ')"
unique_uplift_count="$(printf "%s\n" $unique_uplifts \
  | grep -v '^null$' | grep -v '^$' | sort -u | wc -l | tr -d ' ')"

batch_verdict="FAIL"
if [ "$failures" = "0" ] && [ "$unique_sha_count" = "1" ]; then
  batch_verdict="PASS"
fi

cat > "$SUMMARY" <<SUMMARY_EOF
{
  "cell": "$CELL",
  "test_id": "$TEST_ID",
  "instances": $instance,
  "failures": $failures,
  "receipt_count": $receipt_count,
  "unique_canonical_sha_count": $unique_sha_count,
  "unique_best_uplift_count": $unique_uplift_count,
  "task": "${TASK:-null}",
  "steps": "${STEPS:-null}",
  "batch_verdict": "$batch_verdict",
  "timestamp_utc": "$TS_NOW"
}
SUMMARY_EOF

_log "summary written: $SUMMARY batch_verdict=$batch_verdict"
cat "$SUMMARY"

[ "$batch_verdict" = "PASS" ]
