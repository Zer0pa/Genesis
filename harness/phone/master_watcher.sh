#!/system/bin/sh
# master_watcher.sh — watchdog for genesis_chain_v1.sh master process
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Polls master PID every 30s; invokes resume_chain.sh if master dies.
# POSIX-portable; busybox sh; no bash-isms.
set -eu

MASTER_PID=""
LOG_DIR="/data/local/tmp/genesis/logs"
HARNESS_DIR="/data/local/tmp/genesis/harness"
POLL_INTERVAL=30

while [ "$#" -gt 0 ]; do
  case "$1" in
    --master-pid) MASTER_PID="$2"; shift 2 ;;
    --log-dir)    LOG_DIR="$2";    shift 2 ;;
    --harness-dir) HARNESS_DIR="$2"; shift 2 ;;
    --interval)   POLL_INTERVAL="$2"; shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

[ -n "$MASTER_PID" ] || { printf "--master-pid required\n" >&2; exit 2; }

mkdir -p "$LOG_DIR"

WATCHER_LOG="$LOG_DIR/watcher.log"

_log() {
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*" >> "$WATCHER_LOG"
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*"
}

_log "master_watcher started watching master_pid=$MASTER_PID interval=${POLL_INTERVAL}s"

while true; do
  sleep "$POLL_INTERVAL"

  if kill -0 "$MASTER_PID" 2>/dev/null; then
    _log "master pid=$MASTER_PID alive"
  else
    _log "master pid=$MASTER_PID DEAD; invoking resume_chain.sh"
    "$HARNESS_DIR/resume_chain.sh"
    _log "resume_chain.sh returned; watcher exiting"
    exit 0
  fi
done
