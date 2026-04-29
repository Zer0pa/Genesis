#!/system/bin/sh
# thermal_coordinator.sh — Genesis thermal monitor
# Genesis lane: /data/local/tmp/genesis/  (NOT dm3_harness)
# Adapted from dm3_parallel/scripts/thermal_coordinator.sh
# POSIX-portable; busybox sh; no bash-isms.
#
# Threshold: 80C Genesis-zone ceiling (PRD §Deployment 75C + headroom).
# Only cpu-0-* / cpuss-0-* / gpuss-* thermal zones are counted; dm3's
# cpu-1-* / cpuss-1-* prime cluster is intentionally excluded.
#
# On exceedance:
#   1. SIGSTOP all snic_rust PIDs
#   2. Sleep 30s (cool-down)
#   3. SIGCONT
#   4. If still over threshold after resume: SIGCONT, write
#      thermal_kill.log, and exit 1
#
# Lifetime: exits when parent PID dies or stop-flag file appears.
set -eu

PARENT_PID=""
STOP_FLAG=""
LOG="/data/local/tmp/genesis/logs/thermal.log"
THERMAL_KILL_LOG="/data/local/tmp/genesis/logs/thermal_kill.log"
POLL_INTERVAL=5
# CEILING raised from 70 to 80 C: per PRD §Deployment, Genesis-side ceiling
# is 75C with cpu0-6 mask + thermal margin (cpu6); 80C provides additional
# headroom against transient spikes when 6 snic_rust workers spawn
# simultaneously (we observed 98C transients on cpu-0-* at launch).
CEILING_C=80
# Require N consecutive over-threshold polls before SIGSTOPping (debounce
# transient spikes that resolve within one poll cycle).
DEBOUNCE_SAMPLES=3
# Grace period (seconds) after start: skip first GRACE_S seconds entirely
# to allow worker spawn / cargo-loaded binaries to settle.
GRACE_S=15

while [ "$#" -gt 0 ]; do
  case "$1" in
    --parent-pid) PARENT_PID="$2"; shift 2 ;;
    --stop-flag)  STOP_FLAG="$2";  shift 2 ;;
    --log)        LOG="$2";        shift 2 ;;
    --interval)   POLL_INTERVAL="$2"; shift 2 ;;
    --ceiling-c)  CEILING_C="$2";  shift 2 ;;
    *) printf "unknown arg: %s\n" "$1" >&2; exit 2 ;;
  esac
done

[ -n "$PARENT_PID" ] || { printf "--parent-pid required\n" >&2; exit 2; }
[ -n "$STOP_FLAG" ]  || { printf "--stop-flag required\n" >&2; exit 2; }

mkdir -p "$(dirname "$LOG")"

_log() {
  printf "%s %s\n" "$(date -u +%Y%m%dT%H%M%SZ)" "$*" >> "$LOG"
}

_log "thermal_coordinator started parent_pid=$PARENT_PID ceiling=${CEILING_C}C poll=${POLL_INTERVAL}s"

# Read max temp (integer Celsius) across CPU thermal zones.
# /sys/class/thermal/thermal_zone*/temp is in milli-Celsius; pure-shell integer
# comparison (busybox awk's `var=value` post-script form doesn't reliably set
# awk variables across iters; that was the cause of blank "temp=C" log lines).
_max_temp_c() {
  _max_milli=0
  for _tp in /sys/class/thermal/thermal_zone*/temp; do
    [ -r "$_tp" ] || continue
    _zone_dir="$(dirname "$_tp")"
    _type_file="$_zone_dir/type"
    if [ -r "$_type_file" ]; then
      _sensor_type="$(cat "$_type_file")"
      # FILTER: only Genesis-cluster CPU zones (cpu-0-* + cpuss-0-*).
      # The cpu-1-* / cpuss-1-* cluster is the SD8 Elite Gen 4 prime cluster
      # which is pinned to cpu7 = dm3_runner's reserved core. dm3 keeps that
      # cluster hot continuously; including those zones in our max would
      # SIGSTOP Genesis workers for dm3-caused heat that has nothing to do
      # with our cpu0-6 workload. (Cause of 2026-04-28T15:52Z chain-hang:
      # transient cpu-1-1-1 spike to 98C at launch killed the chain.)
      case "$_sensor_type" in
        cpu-0-*|cpuss-0-*|gpuss-*) ;;
        *) continue ;;
      esac
    fi
    _tr="$(cat "$_tp" 2>/dev/null || printf "0")"
    # Strip leading sign / non-digits; default to 0 if unparseable.
    _tr_clean="${_tr#-}"
    _tr_clean="${_tr_clean%%[!0-9]*}"
    [ -z "$_tr_clean" ] && _tr_clean=0
    if [ "$_tr_clean" -gt "$_max_milli" ]; then
      _max_milli="$_tr_clean"
    fi
  done
  # Integer milli-C to integer C
  printf "%d" "$((_max_milli / 1000))"
}

# Send signal to all running snic_rust processes (Genesis pipeline binary).
# (Earlier name 'genesis_runner' referred to the cross-compiled genesis_cli
# meta-orchestrator which we retracted as fp-shapematch; the actual deployed
# binary is snic_rust.)
_signal_genesis() {
  _sig="$1"
  _pids="$(pidof snic_rust 2>/dev/null || true)"
  if [ -n "$_pids" ]; then
    _log "sending SIG${_sig} to snic_rust pids: $_pids"
    for _p in $_pids; do
      kill "-${_sig}" "$_p" 2>/dev/null || true
    done
  fi
}

throttle_active=0
over_count=0
start_epoch="$(date +%s)"

# Grace period: don't trigger throttle in the first GRACE_S seconds.
# Worker spawn + cargo-loaded binary mmap can briefly spike cpu-0-*.
_log "grace period: ${GRACE_S}s startup hold (no throttling) before active monitoring"
sleep "$GRACE_S"

while true; do
  # Exit if parent is dead
  if ! kill -0 "$PARENT_PID" 2>/dev/null; then
    _log "parent pid=$PARENT_PID gone; exiting"
    exit 0
  fi

  # Exit if stop flag touched
  if [ -n "$STOP_FLAG" ] && [ -f "$STOP_FLAG" ]; then
    _log "stop flag found; exiting"
    exit 0
  fi

  temp="$(_max_temp_c)"

  if [ "$temp" -ge "$CEILING_C" ]; then
    over=1
    over_count=$((over_count + 1))
  else
    over=0
    over_count=0
  fi

  _log "poll temp=${temp}C throttle_active=${throttle_active} over_count=${over_count}/${DEBOUNCE_SAMPLES}"

  # Only trigger throttle after DEBOUNCE_SAMPLES consecutive over-threshold polls
  if [ "$over" = "1" ] && [ "$over_count" -ge "$DEBOUNCE_SAMPLES" ]; then
    if [ "$throttle_active" = "0" ]; then
      _log "CEILING EXCEEDED: ${temp}C >= ${CEILING_C}C for ${over_count} consecutive polls; SIGSTOPping snic_rust"
      _signal_genesis "STOP"
      throttle_active=1
      _log "sleeping 30s for cool-down"
      sleep 30
      temp_after="$(_max_temp_c)"
      _log "post-cooldown temp=${temp_after}C"
      if [ "$temp_after" -ge "$CEILING_C" ]; then
        still_over=1
      else
        still_over=0
      fi
      if [ "$still_over" = "1" ]; then
        _log "THERMAL KILL: still over ${CEILING_C}C after cooldown (${temp_after}C)"
        printf "%s thermal_kill temp_after=%s ceiling=%s\n" \
          "$(date -u +%Y%m%dT%H%M%SZ)" "$temp_after" "$CEILING_C" \
          > "$THERMAL_KILL_LOG"
        # CRITICAL: SIGCONT before exiting so workers don't hang in T state.
        # On exit our parent batch will reap them; without SIGCONT they
        # remain SIGSTOPped indefinitely and the chain hangs forever.
        _log "issuing SIGCONT to all snic_rust pids before exit (avoid hung-T-state chain)"
        _signal_genesis "CONT"
        exit 1
      fi
      _log "cooled to ${temp_after}C; SIGCONTing snic_rust"
      _signal_genesis "CONT"
      throttle_active=0
    fi
  else
    throttle_active=0
  fi

  sleep "$POLL_INTERVAL"
done
