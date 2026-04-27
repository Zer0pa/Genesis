#!/system/bin/sh
# resume_chain.sh — idempotent re-launch of genesis_chain_v1.sh
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Reads master.pid; if master still alive, exits 0 (no double-launch).
# On dead or absent master: spawns genesis_chain_v1.sh with nohup.
# POSIX-portable; busybox sh; no bash-isms.
set -eu

HARNESS_DIR="/data/local/tmp/genesis/harness"
LOG_DIR="/data/local/tmp/genesis/logs"
MASTER_PID_FILE="/data/local/tmp/genesis/logs/master.pid"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness-dir)    HARNESS_DIR="$2";    shift 2 ;;
    --log-dir)        LOG_DIR="$2";        shift 2 ;;
    --master-pid-file) MASTER_PID_FILE="$2"; shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$LOG_DIR"

RESUME_LOG="$LOG_DIR/resume.log"

_log() {
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*" >> "$RESUME_LOG"
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*"
}

_log "resume_chain.sh invoked"

# ----------------------------------------------------------------
# Idempotency: check if a master is already live
# ----------------------------------------------------------------
if [ -f "$MASTER_PID_FILE" ]; then
  existing_pid="$(cat "$MASTER_PID_FILE" | tr -d '[:space:]')"
  if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
    _log "master already running (pid=$existing_pid); no action needed"
    exit 0
  fi
  _log "stale master.pid ($existing_pid); will re-launch"
fi

# ----------------------------------------------------------------
# Spawn genesis_chain_v1.sh with nohup
# ----------------------------------------------------------------
CHAIN_OUT="$LOG_DIR/chain.log"
CHAIN_ERR="$LOG_DIR/chain.err"

nohup "$HARNESS_DIR/genesis_chain_v1.sh" \
  >> "$CHAIN_OUT" 2>> "$CHAIN_ERR" &
new_pid="$!"

printf "%s\n" "$new_pid" > "$MASTER_PID_FILE"
_log "genesis_chain_v1.sh spawned pid=$new_pid; master.pid written"
