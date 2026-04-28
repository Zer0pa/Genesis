#!/system/bin/sh
# run_genesis_cell.sh — per-invocation Genesis cell harness
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Adapted from dm3_parallel/scripts/run_cell_parallel.sh
# POSIX-portable; busybox sh; no bash-isms.
set -eu

BINARY="/data/local/tmp/genesis/snic_rust"
CONFIG="/data/local/tmp/genesis/configs/CONFIG.json"
OUT_ROOT="/data/local/tmp/genesis/cells"
CELL=""
INSTANCE=""
CORE=""
STEPS=""
TEST_ID="manual"
EXPECTED_SHA=""
TASK=""
TEST_BATTERY="1"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --binary)       BINARY="$2";       shift 2 ;;
    --out-root)     OUT_ROOT="$2";     shift 2 ;;
    --cell)         CELL="$2";         shift 2 ;;
    --instance)     INSTANCE="$2";     shift 2 ;;
    --core)         CORE="$2";         shift 2 ;;
    --steps)        STEPS="$2";        shift 2 ;;
    --test-id)      TEST_ID="$2";      shift 2 ;;
    --expected-sha) EXPECTED_SHA="$2"; shift 2 ;;
    --task)         TASK="$2";         shift 2 ;;
    --test-battery) TEST_BATTERY="$2"; shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

[ -n "$CELL" ]     || { printf "--cell required\n" >&2;     exit 2; }
[ -n "$INSTANCE" ] || { printf "--instance required\n" >&2; exit 2; }
[ -n "$CORE" ]     || { printf "--core required\n" >&2;     exit 2; }

# --steps required only for Phase 1+ (task mode)
if [ -n "$TASK" ]; then
  [ -n "$STEPS" ] || { printf "--steps required when --task is set\n" >&2; exit 2; }
fi

# ----------------------------------------------------------------
# Namespace pre-flight: confirm genesis deploy root exists
# ----------------------------------------------------------------
if [ ! -d "/data/local/tmp/genesis" ]; then
  printf "genesis deploy root /data/local/tmp/genesis does not exist\n" >&2
  exit 3
fi

# Confirm thermal zone read works
if ! ls /sys/class/thermal/thermal_zone*/temp >/dev/null 2>&1; then
  printf "WARNING: no thermal zones readable; continuing\n" >&2
fi

TS="$(date -u +%Y%m%dT%H%M%SZ)"
CELL_DIR="$OUT_ROOT/$CELL"
INST_DIR="$CELL_DIR/${INSTANCE}_${TS}"
DONE_FLAG="$CELL_DIR/${INSTANCE}_done.flag"

# ----------------------------------------------------------------
# Idempotency: skip if already done
# ----------------------------------------------------------------
if [ -f "$DONE_FLAG" ]; then
  printf "instance %s cell %s already done; skipping\n" "$INSTANCE" "$CELL" >&2
  exit 0
fi

mkdir -p "$INST_DIR"

LOG="$INST_DIR/stdout.log"

# ----------------------------------------------------------------
# Binary pre-flight: sha256sum gate
# ----------------------------------------------------------------
if ! command -v sha256sum >/dev/null 2>&1; then
  printf "sha256sum not found; required on device\n" >&2
  exit 4
fi

actual_sha="$(sha256sum "$BINARY" | awk '{print $1}')"

if [ -n "$EXPECTED_SHA" ]; then
  if [ "$actual_sha" != "$EXPECTED_SHA" ]; then
    printf "binary hash mismatch: got %s expected %s\n" "$actual_sha" "$EXPECTED_SHA" \
      > "$INST_DIR/error.txt"
    exit 10
  fi
fi

# Build taskset mask from CORE.
# CORE values:
#   "auto" or "-" or empty   → no per-instance pin; rely on parent affinity
#                              (parent should be pinned to cpu0-6 = mask 7F via
#                              taskset before launching this script). Required
#                              for RM10 because Qualcomm core_ctl dynamically
#                              pauses cores in the cluster, causing
#                              sched_setaffinity EINVAL on transiently-paused
#                              cpus when 6 instances spawn in parallel.
#   0x-prefixed hex          → strip 0x; use as taskset mask
#   bare hex (a-f)           → use as-is
#   integer (cpu index)      → 1<<index
case "$CORE" in
  ""|auto|"-") MASK="" ;;
  0x*|0X*)     MASK="$(printf '%s' "$CORE" | sed 's/^0[xX]//')" ;;
  *[!0-9a-fA-F]*) MASK="$CORE" ;;
  *[a-fA-F]*)  MASK="$CORE" ;;
  *)           MASK="$(printf '%x' "$((1 << CORE))")" ;;
esac

# Build the run-prefix string (taskset MASK if pinned, empty otherwise).
# We use a string prefix rather than a function so subshells via ( ) work
# uniformly across busybox sh variants.
if [ -n "$MASK" ]; then
  RUN_PREFIX="taskset $MASK"
else
  RUN_PREFIX=""
fi

# ----------------------------------------------------------------
# Execution: 4-step Genesis snic_rust pipeline, looped TEST_BATTERY iters
#   build-2d  -> artifacts/yantra_2d.json
#   lift-3d   -> artifacts/lift_3d.json
#   solve-h2  -> artifacts/solve_h2.json
#   verify    -> artifacts/verify.json   (canonical scientific output)
# Each iter writes into per-instance working dir to avoid cross-instance
# artifact collision. canonical_sha = sha256(artifacts/verify.json).
# Cross-iter byte-identity (bit-determinism) is enforced explicitly.
# (Phase 1+ K2 task mode: not yet implemented; --task flag reserved.)
# ----------------------------------------------------------------
start_epoch="$(date +%s)"
start_utc="$TS"

WD="$INST_DIR/wd"
mkdir -p "$WD/artifacts" "$WD/configs"
cp "$CONFIG" "$WD/configs/CONFIG.json"

set +e
run_status=0
verify_hash=""
solve_h2_hash=""
yantra_2d_hash=""
lift_3d_hash=""
bitdet_pass=1
prev_verify=""
prev_solve=""
iter_count=0

if [ -n "$TASK" ]; then
  # Phase 1+ path: K2 task mode via snic_rust k2-scars (or any subcommand)
  # Loops TEST_BATTERY iters; cross-iter byte-identity check on artifacts/k2_summary.json.
  # canonical_sha = sha256(artifacts/k2_summary.json) — the K2 protocol's deterministic output.
  SUBSTRATE="/data/local/tmp/genesis/inputs/substrate_285v.json"
  prev_summary=""
  for iter in $(seq 1 "$TEST_BATTERY"); do
    iter_count="$iter"
    rm -f "$WD/artifacts"/*.json
    # shellcheck disable=SC2086
    (cd "$WD" && $RUN_PREFIX "$BINARY" "$TASK" --substrate "$SUBSTRATE" --steps "$STEPS" --config configs/CONFIG.json) \
      >> "$LOG" 2>&1 || { run_status=$?; printf "FAIL %s iter=%d status=%d\n" "$TASK" "$iter" "$run_status" >> "$LOG"; break; }
    iter_summary_hash="$(sha256sum "$WD/artifacts/k2_summary.json" | awk '{print $1}')"
    printf "iter=%d k2_summary=%s\n" "$iter" "$iter_summary_hash" >> "$LOG"
    if [ -z "$prev_summary" ]; then
      prev_summary="$iter_summary_hash"
    else
      if [ "$iter_summary_hash" != "$prev_summary" ]; then
        bitdet_pass=0
        printf "K2-BITDET-BREACH iter=%d: hash diverged from iter=1\n" "$iter" >> "$LOG"
        run_status=20
        break
      fi
    fi
  done
  verify_hash="$iter_summary_hash"
  # Extract KPI fields from log for receipt
  best_uplift="$(grep "KPI_K2_SUMMARY" "$LOG" | tail -1 | grep -oE 'best_uplift=[0-9]+(\.[0-9]+)?' | head -1 | cut -d= -f2)"
  max_scar_weight="$(grep "KPI_K2_SUMMARY" "$LOG" | tail -1 | grep -oE 'max_scar_weight=[0-9]+(\.[0-9]+)?' | head -1 | cut -d= -f2)"
else
  # Phase 0 path: snic_rust pipeline N times with cross-iter byte-identity check
  for iter in $(seq 1 "$TEST_BATTERY"); do
    iter_count="$iter"
    rm -f "$WD/artifacts"/*.json
    # shellcheck disable=SC2086
    (cd "$WD" && $RUN_PREFIX "$BINARY" build-2d --config configs/CONFIG.json) \
      >> "$LOG" 2>&1 || { run_status=$?; printf "FAIL build-2d iter=%d status=%d\n" "$iter" "$run_status" >> "$LOG"; break; }
    # shellcheck disable=SC2086
    (cd "$WD" && $RUN_PREFIX "$BINARY" lift-3d  --config configs/CONFIG.json) \
      >> "$LOG" 2>&1 || { run_status=$?; printf "FAIL lift-3d iter=%d status=%d\n" "$iter" "$run_status" >> "$LOG"; break; }
    # shellcheck disable=SC2086
    (cd "$WD" && $RUN_PREFIX "$BINARY" solve-h2 --config configs/CONFIG.json) \
      >> "$LOG" 2>&1 || { run_status=$?; printf "FAIL solve-h2 iter=%d status=%d\n" "$iter" "$run_status" >> "$LOG"; break; }
    # shellcheck disable=SC2086
    (cd "$WD" && $RUN_PREFIX "$BINARY" verify   --config configs/CONFIG.json) \
      >> "$LOG" 2>&1 || { run_status=$?; printf "FAIL verify iter=%d status=%d\n" "$iter" "$run_status" >> "$LOG"; break; }
    yantra_2d_hash="$(sha256sum "$WD/artifacts/yantra_2d.json" | awk '{print $1}')"
    lift_3d_hash="$(sha256sum  "$WD/artifacts/lift_3d.json"  | awk '{print $1}')"
    solve_h2_hash="$(sha256sum "$WD/artifacts/solve_h2.json" | awk '{print $1}')"
    verify_hash="$(sha256sum    "$WD/artifacts/verify.json"   | awk '{print $1}')"
    printf "iter=%d verify=%s solve_h2=%s lift_3d=%s yantra_2d=%s\n" \
      "$iter" "$verify_hash" "$solve_h2_hash" "$lift_3d_hash" "$yantra_2d_hash" >> "$LOG"
    if [ -z "$prev_verify" ]; then
      prev_verify="$verify_hash"
      prev_solve="$solve_h2_hash"
    else
      if [ "$verify_hash" != "$prev_verify" ] || [ "$solve_h2_hash" != "$prev_solve" ]; then
        bitdet_pass=0
        printf "BITDET-BREACH iter=%d: hash diverged from iter=1\n" "$iter" >> "$LOG"
        run_status=20
        break
      fi
    fi
  done
fi
set -e

end_epoch="$(date +%s)"
end_utc="$(date -u +%Y%m%dT%H%M%SZ)"

# canonical_sha = sha256(artifacts/verify.json) — the authoritative scientific output
canonical_sha="$verify_hash"
printf "%s\n" "$canonical_sha" > "$INST_DIR/canonical_stdout.sha256"
# Persist artifact-level hashes for chain-level cross-instance comparison
cat > "$INST_DIR/artifact_hashes.json" <<HASHES_EOF
{
  "verify_sha":    "$verify_hash",
  "solve_h2_sha":  "$solve_h2_hash",
  "lift_3d_sha":   "$lift_3d_hash",
  "yantra_2d_sha": "$yantra_2d_hash",
  "iter_count":    $iter_count,
  "bitdet_pass":   $bitdet_pass
}
HASHES_EOF

# ----------------------------------------------------------------
# Extract KPI fields from log (dm3 schema mirrors)
# ----------------------------------------------------------------
best_uplift="$(grep -oE 'best_uplift=[0-9]+(\.[0-9]+)?' "$LOG" \
  | tail -1 | cut -d= -f2 || true)"
max_scar_weight="$(grep -oE 'max_scar_weight=[0-9]+(\.[0-9]+)?' "$LOG" \
  | tail -1 | cut -d= -f2 || true)"

# ----------------------------------------------------------------
# env_pre / env_post: thermal snapshot
# ----------------------------------------------------------------
_read_max_temp() {
  _max="0"
  for _tp in /sys/class/thermal/thermal_zone*/temp; do
    [ -r "$_tp" ] || continue
    _tr="$(cat "$_tp")"
    _tc="$(awk "BEGIN { printf \"%.3f\", $_tr / 1000 }")"
    _max="$(awk "BEGIN { print ($_tc > $_max) ? _tc : $_max }" _tc="$_tc" _max="$_max")"
  done
  printf "%s" "$_max"
}
env_pre_temp="$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | \
  awk '{printf "%.3f", $1/1000}' || printf "NA")"
env_post_temp="$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | \
  awk '{printf "%.3f", $1/1000}' || printf "NA")"

# ----------------------------------------------------------------
# genesis_meta: build hash and target triple baked at deploy time
# Read from /data/local/tmp/genesis/genesis_meta.txt if present,
# else emit "unknown" (deploy script writes this file).
# ----------------------------------------------------------------
if [ -f "/data/local/tmp/genesis/genesis_meta.txt" ]; then
  genesis_build_hash="$(grep '^build_hash=' /data/local/tmp/genesis/genesis_meta.txt \
    | cut -d= -f2 || printf "unknown")"
  genesis_target="$(grep '^target=' /data/local/tmp/genesis/genesis_meta.txt \
    | cut -d= -f2 || printf "unknown")"
else
  genesis_build_hash="unknown"
  genesis_target="unknown"
fi

# ----------------------------------------------------------------
# Verdict
# ----------------------------------------------------------------
verdict="FAIL"
if [ "$run_status" = "0" ]; then
  if [ -n "$TASK" ]; then
    # Phase 1+ K2 task: require best_uplift present + cross-iter byte-identity
    if [ -n "$best_uplift" ] && [ "$bitdet_pass" = "1" ]; then
      verdict="PASS"
    fi
  else
    # Phase 0 pipeline: all iters succeeded + cross-iter byte-identity holds
    if [ -n "$canonical_sha" ] && [ "$bitdet_pass" = "1" ]; then
      verdict="PASS"
    fi
  fi
fi

# ----------------------------------------------------------------
# dm3-mirror JSON receipt
# Field-for-field mirror per PRD §Receipts:
#   canonical_sha, receipt_sha, env_pre, env_post, task, --steps,
#   best_uplift, timestamp_utc, plus genesis_meta sub-object.
# Additional fields carried from dm3 template: cell, instance,
#   binary_sha256, taskset_mask, status.
# ----------------------------------------------------------------
RECEIPT="$INST_DIR/receipt.json"

# steps field: emit null when not in task mode
if [ -n "$STEPS" ]; then
  steps_val="$STEPS"
else
  steps_val="null"
fi
if [ "$steps_val" != "null" ]; then
  steps_json="$steps_val"
else
  steps_json="null"
fi

# best_uplift: null when absent (Phase 0)
if [ -n "$best_uplift" ]; then
  best_uplift_json="\"$best_uplift\""
else
  best_uplift_json="null"
fi

# max_scar_weight: null when absent
if [ -n "$max_scar_weight" ]; then
  max_scar_weight_json="\"$max_scar_weight\""
else
  max_scar_weight_json="null"
fi

# task: null when absent
if [ -n "$TASK" ]; then
  task_json="\"$TASK\""
else
  task_json="null"
fi

cat > "$RECEIPT" <<RECEIPT_EOF
{
  "canonical_sha": "$canonical_sha",
  "receipt_sha": "PENDING",
  "env_pre": {
    "timestamp_utc": "$start_utc",
    "thermal_zone0_c": "$env_pre_temp",
    "binary_sha256": "$actual_sha",
    "taskset_mask": "$MASK"
  },
  "env_post": {
    "timestamp_utc": "$end_utc",
    "thermal_zone0_c": "$env_post_temp",
    "run_status": $run_status,
    "verdict": "$verdict"
  },
  "task": $task_json,
  "steps": $steps_json,
  "best_uplift": $best_uplift_json,
  "max_scar_weight": $max_scar_weight_json,
  "timestamp_utc": "$start_utc",
  "cell": "$CELL",
  "instance": $INSTANCE,
  "test_id": "$TEST_ID",
  "binary_sha256": "$actual_sha",
  "taskset_mask": "$MASK",
  "genesis_meta": {
    "build_hash": "$genesis_build_hash",
    "target_triple": "$genesis_target",
    "expected_sha": "$EXPECTED_SHA"
  }
}
RECEIPT_EOF

# Compute receipt_sha over the receipt file itself (minus the placeholder line),
# then patch it in via string replacement.
receipt_sha="$(sha256sum "$RECEIPT" | awk '{print $1}')"
# Rewrite PENDING with the actual hash using a tmp file (no sed -i on busybox)
TMP_RECEIPT="${RECEIPT}.tmp"
sed "s/\"receipt_sha\": \"PENDING\"/\"receipt_sha\": \"$receipt_sha\"/" \
  "$RECEIPT" > "$TMP_RECEIPT"
mv "$TMP_RECEIPT" "$RECEIPT"

# ----------------------------------------------------------------
# Done flag (idempotency marker)
# ----------------------------------------------------------------
printf "%s\n" "$end_utc" > "$DONE_FLAG"

printf "cell=%s instance=%s verdict=%s canonical_sha=%s\n" \
  "$CELL" "$INSTANCE" "$verdict" "$canonical_sha"

[ "$verdict" = "PASS" ]
