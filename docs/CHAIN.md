# Genesis Chain — Operations Manual

This document is for a researcher or operator who needs to extend, operate, or recover the autonomous Genesis chain on RM10. For architecture context see [`ARCHITECTURE.md`](ARCHITECTURE.md). For full reproduce-from-scratch procedure see [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md).

---

## Manifest Format (cells.txt)

Source: [`harness/phone/cells.txt`](../harness/phone/cells.txt)

One cell per non-blank non-comment line. Comments begin with `#`. Blank lines are ignored.

**Format:**

```
<CELL_ID> [--task TASK] [--steps N] [--test-battery N] [--instances N]
```

**Defaults if flags are omitted:**
- `--instances 6` (cpu0–cpu5 fan-out via parent-affinity mask `7F`)
- `--test-battery 10` for Phase 0 (vanilla pipeline); `3` for Phase 1+ K2 cells (set explicitly in manifest)
- `--task` absent → Phase 0 pipeline mode (`build-2d → lift-3d → solve-h2 → verify`)
- `--steps` required when `--task` is set; absent → Phase 0 (no steps parameter)

**Examples from the current manifest:**

```
# Phase 0 BITDET (vanilla pipeline, 10 iters × 6 instances)
# BITDET_01 --test-battery 10
# (completed; skipped on idempotent re-read)

# Phase 1+ K2_SWEEP cells
K2_S20 --task k2-scars --steps 20 --instances 6 --test-battery 3
K2_S30 --task k2-scars --steps 30 --instances 6 --test-battery 3
K2_S50 --task k2-scars --steps 50 --instances 6 --test-battery 3

# Cycle-7 disambiguation probe (multiples of 7)
K2_CYC7_S7  --task k2-scars --steps 7  --instances 6 --test-battery 3
K2_CYC7_S14 --task k2-scars --steps 14 --instances 6 --test-battery 3
```

The `CELL_ID` must be unique. It becomes the directory name under `cells/`. The manifest is read top-to-bottom; cells run in manifest order.

---

## Adding a New Cell

1. Edit `harness/phone/cells.txt` on the host — append one line with a unique `CELL_ID` and the appropriate flags.
2. Push the updated manifest to the phone:
   ```bash
   adb -s FY25013101C8 push harness/phone/cells.txt \
     /data/local/tmp/genesis/harness/cells.txt
   ```
3. The running chain reads the manifest once at startup. To pick up the new cell without waiting for the current chain to finish naturally, kill the master and let the watcher restart it (see §Stopping the Chain Cleanly and §Launching the Chain). The new master reads the updated manifest; all cells with existing `outcome.json` are SKIPped immediately.

**Idempotency guarantee:** a cell is SKIPped if and only if `cells/<CELL_ID>/outcome.json` exists. Appending a new `CELL_ID` that has never run is safe; removing a cell from the manifest does not delete its receipts on the phone.

---

## Adding a New Task Subcommand

New task subcommands must be implemented in the upstream Genesis source workspace, not in the `genesis_comparative` repository.

1. In `crates/io_cli/src/main.rs` (upstream source): add a `Cmd::<NewTask>` variant to the `enum Cmd` and a dispatch arm in `fn main()`. Create the module at `crates/io_cli/src/<new_task>.rs`. All numeric work must use `num_rational::BigRational`; floats only for `printf` output. The workspace `#![deny(warnings)]` is enforced.
2. Cross-compile for aarch64-linux-android:
   ```bash
   cargo build --release --target aarch64-linux-android -p io_cli
   ```
   (NDK env-var route; see [REPRODUCIBILITY.md](../REPRODUCIBILITY.md) §Cross-compile recipe.)
3. Capture the new binary SHA-256:
   ```bash
   sha256sum target/aarch64-linux-android/release/snic_rust
   ```
4. Push to phone:
   ```bash
   adb -s FY25013101C8 push target/aarch64-linux-android/release/snic_rust \
     /data/local/tmp/genesis/snic_rust
   # Update genesis_meta.txt with new build hash:
   adb -s FY25013101C8 shell \
     "printf 'build_hash=<NEW_SHA>\ntarget=aarch64-linux-android\n' \
       > /data/local/tmp/genesis/genesis_meta.txt"
   ```
5. Run a BITDET cell for the new task before any science cells, to confirm determinism:
   ```bash
   # Add to cells.txt: BITDET_NEWTASK --task <new-task> --steps 30 --test-battery 10
   ```
6. Update the manifest with science cells using `--task <new-task>`.

The harness dispatches the `--task` value directly as the `snic_rust` subcommand: `snic_rust <task> --substrate ... --steps ... --config ...`. Any subcommand that is not one of `{k2-scars}` and that does not read `--substrate` and `--steps` will need a patch to `run_genesis_cell.sh`'s Phase 1+ execution path.

---

## Launching the Chain

Full deploy sequence is in [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md). To re-launch an already-deployed chain after a stop:

```bash
# 1. Sibling-lane check (must pass before any Genesis operation)
adb -s FY25013101C8 shell pidof dm3_runner    # note PID; do not signal it

# 2. Launch master via resume_chain.sh (idempotent; no-op if master already alive)
adb -s FY25013101C8 shell \
  "cd /data/local/tmp/genesis && \
   nohup harness/resume_chain.sh >> logs/resume.log 2>&1 &"

# 3. Get the new master PID
MASTER_PID=$(adb -s FY25013101C8 shell cat /data/local/tmp/genesis/logs/master.pid | tr -d '\r\n')

# 4. Launch watcher for the new master
adb -s FY25013101C8 shell \
  "cd /data/local/tmp/genesis && \
   nohup harness/master_watcher.sh --master-pid $MASTER_PID \
     >> logs/watcher.log 2>&1 &"
```

After launch: advise the operator to enable game-cooling mode on the phone, point a fan at it, and optionally place it in a refrigerator for thermal headroom. The chain runs fully autonomously after this point; ADB can be disconnected.

---

## Stopping the Chain Cleanly

Kill in this order to avoid race conditions:

```bash
# 1. Kill watcher first (prevent auto-restart of master after you kill it)
WATCHER_PID=$(adb -s FY25013101C8 shell pgrep -f master_watcher.sh | tr -d '\r\n')
adb -s FY25013101C8 shell kill "$WATCHER_PID" 2>/dev/null || true

# 2. Kill master
MASTER_PID=$(adb -s FY25013101C8 shell cat /data/local/tmp/genesis/logs/master.pid | tr -d '\r\n')
adb -s FY25013101C8 shell kill "$MASTER_PID" 2>/dev/null || true

# 3. Kill any in-flight batch, thermal coordinator, and run_genesis_cell instances
adb -s FY25013101C8 shell "pkill -f launch_genesis_batch.sh; \
  pkill -f thermal_coordinator.sh; \
  pkill -f run_genesis_cell.sh; \
  pkill -f snic_rust" 2>/dev/null || true
```

**To preserve in-flight cell progress:** wait for the current cell's `outcome.json` to appear before killing, by polling:

```bash
# Wait until cells/<CURRENT_CELL>/outcome.json appears, then kill
adb -s FY25013101C8 shell "until [ -f /data/local/tmp/genesis/cells/<CELL>/outcome.json ]; \
  do sleep 10; done; echo done"
```

Killing the chain mid-cell loses that cell's `outcome.json` (in-flight instances do not write receipts on SIGKILL). The cell will re-run from scratch on next master start.

---

## Reading Chain Progress

**See which cells have completed (from Mac):**

```bash
adb -s FY25013101C8 shell ls /data/local/tmp/genesis/cells/
```

**Tail the chain log live:**

```bash
adb -s FY25013101C8 shell "tail -f /data/local/tmp/genesis/logs/chain.log"
```

**Read a cell's verdict:**

```bash
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/cells/K2_S30/outcome.json
```

**Extract KPI lines for a cell (best_uplift per instance):**

```bash
adb -s FY25013101C8 shell \
  "grep KPI_K2_SUMMARY /data/local/tmp/genesis/cells/K2_S30/*/stdout.log"
```

**Read cell-level summary (unique SHA count, batch verdict):**

```bash
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/cells/K2_S30/_summary.json
```

**Verdict roll-up across all completed cells:**

```bash
adb -s FY25013101C8 shell \
  "for f in /data/local/tmp/genesis/cells/*/outcome.json; do \
     cell=\$(grep '\"cell\"' \"\$f\" | sed 's/.*: *\"//;s/\".*//'); \
     verd=\$(grep '\"verdict\"' \"\$f\" | sed 's/.*: *\"//;s/\".*//'); \
     printf '%s %s\n' \"\$cell\" \"\$verd\"; \
   done"
```

---

## Pulling Receipts

Pull all cell directories from device to host:

```bash
adb -s FY25013101C8 pull \
  /data/local/tmp/genesis/cells/ \
  proofs/artifacts/
```

(Run from the `genesis_comparative/` repo root.)

After pull, verify receipt integrity and produce a verdict roll-up:

```bash
cd proofs/artifacts
find . -name "outcome.json" \
  | xargs -I{} sh -c 'jq -r ".cell + \" \" + .verdict" "{}"'
```

Check determinism verdict across all cells (all should be 1):

```bash
find . -name "_summary.json" \
  | xargs -I{} sh -c 'jq -r ".cell + \" sha_count=\" + (.unique_canonical_sha_count|tostring)" "{}"'
```

After pull, commit the receipts on a sibling branch (not `inspection-2026-04-28`):

```bash
git checkout -b receipts-<DATE>
git add proofs/artifacts/
git commit -m "Pull Phase 2 receipts from RM10 at chain close <DATE>"
```

HF dataset push to `Zer0pa/DM3-artifacts` under `genesis/` subdirectory is a manual step at chain close per PRD §Receipts.

---

## Recovering from a Stuck State

**Master dead, watcher dead, no auto-recovery:**
```bash
# Run directly on device:
adb -s FY25013101C8 shell \
  "cd /data/local/tmp/genesis && \
   nohup harness/resume_chain.sh >> logs/resume.log 2>&1 &"
# Then relaunch watcher with new master PID (see §Launching the Chain)
```

**Cell stuck in-progress (no outcome.json, instances all dead):**

The cell directory exists but `outcome.json` is absent. The next master start will attempt to re-run it. If the cell keeps failing, remove the directory first:
```bash
adb -s FY25013101C8 shell rm -rf /data/local/tmp/genesis/cells/<STUCK_CELL>/
# Then relaunch chain; the cell will re-run from scratch.
```

**ADB hung (unresponsive to commands):**
```bash
adb kill-server && adb start-server
adb -s FY25013101C8 shell "echo alive"
```

**Phone offline entirely:** The chain runs fully autonomously on-device. No recovery action is needed from the host. The chain will continue processing the manifest, writing receipts locally. Pull with `adb pull` once the phone is reachable. The watcher will restart the master on death regardless of host ADB connection state.

**thermal_kill.log present (chain killed a cell for thermal):**
```bash
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/logs/thermal_kill.log
# If resolved: rm the log and relaunch the chain.
# The killed cell has outcome.json with verdict KILL; to re-run it,
# remove that outcome.json first.
adb -s FY25013101C8 shell rm /data/local/tmp/genesis/cells/<CELL>/outcome.json
adb -s FY25013101C8 shell rm /data/local/tmp/genesis/logs/thermal_kill.log
# Then relaunch chain.
```

---

## Extending to More Cores or Different Hardware

**Enabling cpu6 (thermal-margin core) on RM10:**

cpu6 is excluded from the default `7F` parent affinity mask by convention (it is the "thermal margin" core per `.gpd/PROJECT.md` §Hard constraints). To include it, edit `launch_genesis_batch.sh` on host:

```bash
# Change PARENT_AFFINITY_MASK from 7F to FF
# (7F = cpu0-6; FF = cpu0-7; but cpu7=dm3-RESERVED — use 7F only if dm3 is gone)
# To add cpu6 only (mask 7F is cpu0-6; this is already the parent mask):
# The per-instance DEFAULT_MASKS list also needs to grow from 6 entries to 7.
```

Wait: the parent mask `7F` already includes cpu6. The default `--instances 6` limits fan-out to 6 processes. To use cpu6 as a seventh instance, increase `--instances 7` in the manifest cell line and ensure `DEFAULT_MASKS` in `launch_genesis_batch.sh` has 7 `auto` entries. Operator decision required; thermal validation of 7-core sustained load is a prerequisite.

**To repurpose cpu7 for Genesis (if dm3 lane finishes):**

Edit `PARENT_AFFINITY_MASK` in `launch_genesis_batch.sh` from `7F` to `FF`. Increase `--instances` to 8. The safety cap at `INSTANCES > 6` in the script must also be updated. Requires operator-visible decision; do not do this while dm3_runner is still active on cpu7.

**Running on a different aarch64-android phone:**

1. Confirm that `taskset` on the device accepts bare-hex masks (Toybox format: `taskset <hex_mask> <cmd>`). Some devices ship with different `taskset` that requires `--cpu-list`.
2. Identify the device's cluster topology and the PID of any sibling workloads running on specific cores.
3. Rebuild `snic_rust` targeting the correct Android API level:
   ```bash
   # Replace android24 with the target device's API level
   export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=.../aarch64-linux-android<API>-clang
   cargo build --release --target aarch64-linux-android -p io_cli
   ```
4. Update `PARENT_AFFINITY_MASK` and `DEFAULT_MASKS` in `launch_genesis_batch.sh` for the new core layout.
5. Update `thermal_coordinator.sh` sensor-type filter if the device uses different thermal zone naming (not all devices use `cpu-*`/`cpuss-*`/`gpuss-*` prefixes).
6. Run a BITDET cell (`--test-battery 10`) before any science cells to confirm byte-determinism on the new device.

---

## What's Out of Scope

These items are not supported by the current chain and require separate work:

- **Cross-platform parity at K2 task level (M1 ↔ RM10 byte-identity for `k2_summary.json`)** — current parity is established at the canonical-pipeline level (`solve_h2.json`); extending to K2 byte-identity requires a PARITY harness cell that runs the same K2 invocation on M1 host and compares SHA against an RM10 receipt. Not yet automated; tagged as Active Engineering in `README.md` §Upcoming Workstreams.

- **Source recovery for dm3_runner** — separate workstream; no Genesis harness involvement.

- **Multi-device chain orchestration** — one phone at a time. The chain has no inter-device coordination; running Genesis on two phones simultaneously requires two separate `cells.txt` manifests and two separate `genesis_comparative/` workspace copies.

- **HF dataset push (`Zer0pa/DM3-artifacts`, `genesis/` subdir)** — manual after chain close per PRD §Receipts. Not automated by the chain.

- **`SYMMETRY` and `CROSSBUILD` cells** — listed as DEFERRED in `cells.txt` pending host-side prep (D₆ Z₂-mirror probe observable design; `CONFIG.json` variants with `turns` knob varied). These require operator-visible decisions before cells can be added to the manifest.

- **`DISCONT` cell** — only triggered if K2_SWEEP Phase 2 shows a cliff or sharp drop near a step boundary. Not in the current manifest; add after K2_SWEEP receipts are pulled and inspected.
