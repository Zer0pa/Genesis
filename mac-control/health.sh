#!/bin/bash
# health.sh — quick chain status snapshot
set -eu
DEV="${DEV:-FY25013101C8}"
adb -s "$DEV" shell '
mp=$(cat /data/local/tmp/genesis/logs/master.pid 2>/dev/null)
if [ -n "$mp" ] && kill -0 "$mp" 2>/dev/null; then
  printf "MASTER pid=%s ALIVE\n" "$mp"
else
  printf "MASTER pid=%s DEAD or no master.pid\n" "${mp:-NONE}"
fi
echo "---"
echo "Cells: $(ls /data/local/tmp/genesis/cells/ 2>/dev/null | wc -l)"
echo "DM3 sibling:"; ps -A | grep dm3_runner | grep -v grep | head -1
echo "Live snic_rust workers: $(ps -A | grep snic_rust | grep -v grep | wc -l)"
echo "---"
echo "Chain log tail:"; tail -5 /data/local/tmp/genesis/logs/chain.log
echo "---"
echo "Thermal tail:"; tail -3 /data/local/tmp/genesis/logs/thermal.log
echo "---"
echo "Battery: $(cat /sys/class/power_supply/battery/capacity)% / $(cat /sys/class/power_supply/battery/temp)dC / $(cat /sys/class/power_supply/battery/status)"
'
