# Genesis Comparative — Architecture and Operations

This document covers both the architectural model (Layers 1/2/3 — computation, orchestration, evidence) and the chain operations manual (manifest format, adding cells, launching/stopping, recovery). The architecture half explains the moving parts; the operations half tells you how to use them. The earlier `docs/CHAIN.md` was folded into the operations half on 2026-05-01 as part of the v1.0 reviewer-pack consolidation.

---

## Three Layers

The experiment is organized in three layers: **Layer 1** is deterministic computation — the `snic_rust` binary runs a pure-rational pipeline (and K2 scar-formation protocol) on a 285-vertex settled-identity substrate, all numeric work via `num_rational::BigRational` with no floating-point in the math path. **Layer 2** is phone-side autonomous chain orchestration — six shell scripts manage fan-out execution across cpu0–cpu6, thermal gating, idempotent resume, and per-cell receipt aggregation on RM10. **Layer 3** is the evidence surface — dm3-mirror JSON receipts written per instance per cell form the proof surface against which the four pre-registered falsifiable comparisons are adjudicated. See [`README.md`](../README.md) §Repository Layout for the file tree that separates these three layers into `harness/`, `inputs/`, `proofs/`, and `artifacts/`.

---

## The snic_rust Pipeline (Layer 1: Computation)

Source: `crates/io_cli/src/main.rs` in the upstream Genesis workspace (`snic_workspace_a83f`). The binary `snic_rust` exposes five subcommands.

**The four-step canonical pipeline:**

```
build-2d   →   artifacts/yantra_2d.json
lift-3d    →   artifacts/lift_3d.json
solve-h2   →   artifacts/solve_h2.json
verify     →   artifacts/verify.json   ← canonical scientific output
```

Each step reads `configs/CONFIG.json` and writes its artifact before the next step reads it. The canonical scientific output is `artifacts/verify.json`; its SHA-256 is the `canonical_sha` in every Phase 0 receipt. Source-hardcoded canonical hash: `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89`. The `verify` step runs 7 internal proof gates (`gates_ok`, `dep_cert`, `gc_invariants`, `lift`, `stab`, `cad_sos`, `egraph`); all 7 must pass or the process exits non-zero.

All numeric computation — graph construction, lift, spectral solve, gate verification — uses `num_rational::BigRational`. Floats appear only in `printf` timestamp output. This is the source of byte-identical determinism across hardware and thermal states.

**The fifth subcommand — `k2-scars` (Phase 1+):**

Implements Hebbian scar formation on the 285-vertex Genesis substrate. All numeric work remains `BigRational`; `f64` is used only for KPI stdout lines and wall-clock reporting.

Key parameters:
- `--steps N`: number of dynamics iteration steps (the sweep variable for Phase 2)
- `--substrate`: path to `inputs/substrate_285v.json` fixture (285v / 567e / 48 D₆ orbits; Bhupura pattern = 47 size-6 D₆ orbits, Lotus pattern = 1 size-3 waist orbit per decision D3)
- `--config`: drives `cfg_hash` seed for the deterministic Bernoulli noise RNG
- `--test-battery`: not a `k2-scars` flag; it is handled by the harness loop in `run_genesis_cell.sh`

Algorithm (from `crates/io_cli/src/k2_scars.rs` in the upstream Genesis source — this module is not present in the `genesis_comparative` repository; it lives in the upstream source workspace):

1. Load substrate edges and pattern indices from JSON fixture.
2. For each lesson in `lesson_counts` (default `[0, 3]`): apply Hebbian update `S[e] += eta * (p_centered ⊗ p_centered)[e]` for each lesson presentation, where `eta = eta_num/eta_den` (default `1/5 = 0.2`).
3. Build row-stochastic dynamics matrix `P_mod` from scar weights.
4. For each noise level in `noise_levels` (default `[1/10, 2/10]`): run consensus dynamics `x_{t+1} = α · P_mod · x_t + (1−α) · p_noisy` for `--steps` iterations, with `α = 164/165`. Bernoulli noise is deterministic: each vertex flip determined by `sha256(cfg_hash ‖ lesson ‖ noise_idx ‖ pattern_id ‖ vertex)[0]` compared to `floor(noise_rate * 256)`.
5. Compute `recall_err` = Hamming distance after rounding state vector to {0,1} at threshold 1/2. `uplift = baseline_recall_err − lesson3_recall_err`. `best_uplift` = max uplift across patterns and noise levels.

Output: `artifacts/k2_summary.json`. Its SHA-256 is the `canonical_sha` in Phase 1+ receipts.

---

## The Phone-Side Harness (Layer 2: Orchestration)

Six POSIX shell scripts (busybox sh, no bash-isms) under [`harness/phone/`](../harness/phone/). All scripts are namespace-scoped to `/data/local/tmp/genesis/`.

**Script relationships:**

```
genesis_chain_v1.sh  (master)
  └─ for each cell in cells.txt:
       launch_genesis_batch.sh  (per-cell batch)
         ├─ thermal_coordinator.sh  (sibling, per batch)
         └─ run_genesis_cell.sh × N  (N=6 instances, parallel)
               └─ snic_rust  (per iteration, ephemeral)

master_watcher.sh  (sibling of master, launched separately)
  └─ resume_chain.sh  (on master death)
```

**`genesis_chain_v1.sh`** — master orchestrator. Reads `harness/cells.txt` manifest at startup. For each non-blank non-comment line: parses `CELL_ID` and per-cell flags (`--task`, `--steps`, `--instances`, `--test-battery`). Idempotent: if `cells/<CELL_ID>/outcome.json` already exists, logs `SKIP` and moves to the next cell. Writes `_state.json` (in-progress) before batch launch; writes `outcome.json` (PASS/PARTIAL/KILL) after batch returns. Log: `logs/chain.log`.

**`launch_genesis_batch.sh`** — fan-out for one cell. Sets parent affinity to mask `7F` (cpu0–cpu6, excluding cpu7=dm3-reserved) before spawning children, so all 6 child processes inherit the affinity mask. Spawns `thermal_coordinator.sh` as a sibling before the instance loop. Spawns N instances of `run_genesis_cell.sh` in parallel (all with `--core auto` so the kernel scheduler distributes across the active cpu0–cpu6 subset — see §CPU Pinning). Waits all instances; tracks `failures` count. After all instances complete, aggregates `receipt.json` files into `cells/<CELL>/_summary.json` with `unique_canonical_sha_count`, `batch_verdict`, `unique_best_uplift_count`. Exits 0 only if `batch_verdict = PASS`.

**`run_genesis_cell.sh`** — per-instance harness. Pre-flight: verifies `sha256sum $BINARY` matches `--expected-sha` if provided (exits 10 with `error.txt` on mismatch). Creates per-instance working directory `cells/<CELL>/<INSTANCE>_<TS>/wd/`. Phase 0 (no `--task`): loops `--test-battery` iterations of the 4-step pipeline; cross-iter byte-identity check on `verify.json` (BITDET breach exits with status 20). Phase 1+ (`--task k2-scars`): loops `--test-battery` iterations of `snic_rust k2-scars`; cross-iter byte-identity check on `k2_summary.json`. Writes `receipt.json` (dm3-mirror schema), `canonical_stdout.sha256`, `artifact_hashes.json`. Computes `receipt_sha` over the receipt file itself (self-certifying). Log: `<INST_DIR>/stdout.log`.

**`thermal_coordinator.sh`** — active thermal gate. Polls `/sys/class/thermal/thermal_zone*/temp` every 5 s, counting only Genesis-relevant `cpu-0-*`, `cpuss-0-*`, and `gpuss-*` sensor types. The dm3-reserved prime cluster (`cpu-1-*` / `cpuss-1-*`) is excluded. On 3 consecutive polls at or above the 80 °C ceiling: SIGSTOPs all `snic_rust` processes, sleeps 30 s, checks again, then SIGCONTs after cooldown or before thermal-kill exit. If still above ceiling after cooldown: writes `logs/thermal_kill.log` and exits 1 (which causes `genesis_chain_v1.sh` to assign `KILL` verdict to the cell). Exits cleanly when parent (batch) pid dies or stop-flag file appears.

**`master_watcher.sh`** — watchdog for the chain master. Requires `--master-pid`. Polls every 30 s with `kill -0`; on master death: invokes `resume_chain.sh` then exits (the new master becomes the watched process — operator must relaunch watcher manually after auto-recover).

**`resume_chain.sh`** — idempotent re-launch. Reads `logs/master.pid`; if master is still alive, exits 0 (no double-launch). On dead or absent master: `nohup genesis_chain_v1.sh >> logs/chain.log 2>> logs/chain.err &`; writes new PID to `master.pid`.

**Process-tree ASCII diagram:**

```
adb shell
  └─ genesis_chain_v1.sh (master; pid in logs/master.pid)
       ├─ [per cell, sequential]
       │   launch_genesis_batch.sh
       │     ├─ thermal_coordinator.sh  ← sibling; exits when batch exits
       │     ├─ run_genesis_cell.sh (instance 0)  ─┐
       │     ├─ run_genesis_cell.sh (instance 1)   │  parallel
       │     ├─ run_genesis_cell.sh (instance 2)   │  all inherit
       │     ├─ run_genesis_cell.sh (instance 3)   │  parent affinity
       │     ├─ run_genesis_cell.sh (instance 4)   │  mask 7F
       │     └─ run_genesis_cell.sh (instance 5)  ─┘
       │           └─ snic_rust (per iter; ephemeral; exits after each run)
       │
       └─ [returns after all cells]

master_watcher.sh  ← separate nohup process; watches master pid; calls resume_chain.sh on death
```

---

## The Receipt Schema (Layer 3: Evidence)

Per-cell directory structure under `/data/local/tmp/genesis/cells/` (on device) and `artifacts/genesis_<TS>/cells/` (on host after pull):

```
cells/<CELL_ID>/
├── _state.json             {"cell", "state", "started", [ended], [verdict]}
├── _summary.json           instances, failures, receipt_count,
│                           unique_canonical_sha_count, unique_best_uplift_count,
│                           task, steps, batch_verdict, timestamp_utc
├── outcome.json            cell, verdict, summary, metrics, next_actions, timestamp_utc
└── <INSTANCE>_<TS>/
    ├── receipt.json         dm3-mirror schema (see below)
    ├── canonical_stdout.sha256   SHA-256 of canonical output file (one line)
    ├── artifact_hashes.json      verify_sha, solve_h2_sha, lift_3d_sha, yantra_2d_sha,
    │                             iter_count, bitdet_pass
    ├── stdout.log           full combined stdout of all snic_rust invocations
    └── wd/                  per-instance working directory
        ├── configs/CONFIG.json
        └── artifacts/       {yantra_2d,lift_3d,solve_h2,verify}.json or k2_summary.json
```

**`receipt.json` fields (dm3-mirror schema):**

```json
{
  "canonical_sha":   "<sha256 of verify.json or k2_summary.json>",
  "receipt_sha":     "<sha256 of this receipt file; self-certifying>",
  "env_pre": {
    "timestamp_utc":      "<ISO-8601 UTC at instance start>",
    "thermal_zone0_c":    "<float °C from /sys/class/thermal/thermal_zone0/temp>",
    "binary_sha256":      "<sha256sum of snic_rust binary>",
    "taskset_mask":       "<hex mask or empty for auto>"
  },
  "env_post": {
    "timestamp_utc":      "<ISO-8601 UTC at instance end>",
    "thermal_zone0_c":    "<float °C>",
    "run_status":         <int exit code>,
    "verdict":            "<PASS|FAIL>"
  },
  "task":           "<k2-scars or null for Phase 0>",
  "steps":          <int or null>,
  "best_uplift":    "<float string or null>",
  "max_scar_weight": "<float string or null>",
  "timestamp_utc":  "<instance start>",
  "cell":           "<CELL_ID>",
  "instance":       <int>,
  "test_id":        "<chain|manual|batch>",
  "binary_sha256":  "<sha256sum of snic_rust binary>",
  "taskset_mask":   "<hex mask>",
  "genesis_meta": {
    "build_hash":     "<from genesis_meta.txt; deploy-time baked>",
    "target_triple":  "<aarch64-linux-android>",
    "expected_sha":   "<sha256 passed via --expected-sha or empty>"
  }
}
```

`_summary.json` carries the key determinism verdict: `unique_canonical_sha_count = 1` means all instances in the cell produced byte-identical output. Any count > 1 is a determinism failure and the cell verdict is `FAIL`.

---

## Process Tree on RM10

Full process topology on the device (Snapdragon 8 Elite Gen 4, RedMagic 10 Pro, serial `FY25013101C8`):

```
PID 1 (init)
└─ adb shell session
     ├─ genesis_chain_v1.sh (master)   cpu0–cpu6 via inherited 7F mask
     │    └─ launch_genesis_batch.sh   cpu0–cpu6 parent affinity 7F
     │         ├─ thermal_coordinator.sh   no cpu pin; kernel-scheduled
     │         ├─ run_genesis_cell.sh (inst 0)   core=auto; inherits 7F
     │         │    └─ snic_rust ...   ephemeral per iter
     │         ├─ run_genesis_cell.sh (inst 1–5)   same
     │         └─ ...
     │
     ├─ master_watcher.sh (separate nohup)   watches master pid
     │    └─ resume_chain.sh (on master death)
     │
     └─ dm3_runner   cpu7 only (mask 0x80)   SEPARATE PROCESS TREE
                     namespace: /data/local/tmp/dm3_harness/
                     NEVER signaled, never collided with
```

Genesis and dm3_runner share the same adb session but are fully isolated by cpu affinity and filesystem namespace. `pidof dm3_runner` is checked as a warning at every batch launch; Genesis proceeds regardless (they are independent).

---

## CPU Pinning + Thermal Discipline

**Qualcomm `core_ctl` quirk:** On RM10's Snapdragon 8 Elite Gen 4, the `core_ctl` kernel power-management module dynamically pauses 1–2 cores in the cpu0–cpu5 cluster at any moment. A `taskset --cpu-list <cpu>` call to pin an instance to a transiently-paused cpu returns `sched_setaffinity EINVAL`, causing that instance's `run_genesis_cell.sh` to fail before `snic_rust` launches. With 6 parallel instances pinned 1:1 to cpu0–cpu5, this breaks 1–2 of the 6 every time a core is paused.

**Mitigation:** `launch_genesis_batch.sh` sets parent affinity to mask `7F` (cpu0–cpu6, excluding cpu7=dm3) via `taskset -p 7F $$` before spawning children. Each `run_genesis_cell.sh` instance is passed `--core auto` (which sets `RUN_PREFIX=""` — no per-instance `taskset` call). The 6 instances inherit the parent's `7F` mask and the kernel scheduler distributes them across whichever subset of cpu0–cpu6 is currently active.

**Determinism is invariant:** `snic_rust` output is byte-identical regardless of which physical cpu computed it. The `BigRational` math path has no cpu-topology dependency. Cross-core scheduling only affects wall-clock runtime, not scientific output.

**cpu7 hard-block:** Mask `0x80` (cpu7) is never used by Genesis. `launch_genesis_batch.sh` caps `--instances` at 6 and warns if any caller attempts to exceed it. cpu7 is the Qualcomm prime core, reserved permanently for the sibling dm3_runner lane.

**Thermal discipline:** `thermal_coordinator.sh` is spawned as a sibling for every batch launch. It polls Genesis-relevant cpu/gpu thermal zones every 5 s after a 15 s startup grace period, excluding dm3's hot `cpu-1-*` / `cpuss-1-*` prime cluster. On 3 consecutive polls at or above 80 °C:
1. SIGSTOP all `snic_rust` processes.
2. Sleep 30 s cooldown.
3. Re-read temperature; if still ≥ 80 °C: SIGCONT workers, write `logs/thermal_kill.log`, and exit 1 (genesis_chain_v1.sh detects this and assigns `KILL` verdict to the cell).
4. If cooled: SIGCONT all `snic_rust` processes.

The active ceiling is 80 °C: PRD §Deployment's 75 °C discipline plus headroom for worker-spawn transients. For extended runs, the RM10 is operated with a physical fan, game-cooling mode (Game Zone) enabled, and optionally the phone placed in a refrigerator for additional thermal headroom. The charger may remain attached; battery power is not required for autonomous operation.

---

## Sibling Lane Isolation (dm3_runner)

Cross-lane framing per [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md): Genesis (285v, D₆, T(3,21), source-available) and dm3_runner (380v, C₃, source-unrecovered) are different mathematical objects running on the same physical device in separate namespaces. Independence is enforced at two levels:

**CPU-level:** dm3_runner is pinned to cpu7 exclusively (mask `0x80`). Genesis uses cpu0–cpu6 (mask `7F`). These masks are disjoint. Genesis scripts never write or set mask `0x80`.

**Filesystem-level:** Genesis namespace is `/data/local/tmp/genesis/`. dm3_runner namespace is `/data/local/tmp/dm3_harness/`. Genesis scripts have no write access to any `dm3_harness/` path. Reading `phase_g_chain.log` from the dm3 side is permitted for passive observation; writes are forbidden.

**Process-level:** `launch_genesis_batch.sh` logs a warning if `pidof dm3_runner` returns a PID, but does not block (the lanes are independent). This is a collision-awareness check, not a gate. Genesis never sends signals to any dm3_runner process.

**Namespace summary:**

| Property | Genesis | dm3_runner |
|---|---|---|
| Deploy root | `/data/local/tmp/genesis/` | `/data/local/tmp/dm3_harness/` |
| CPU affinity | cpu0–cpu6 (mask `7F`) | cpu7 (mask `0x80`) |
| Binary | `snic_rust` | `dm3_runner` |
| Substrate | 285v, D₆, T(3,21) | 380v, C₃, source-unrecovered |

---

## Substrate Coupling

The Genesis K2 task reads substrate geometry from [`inputs/substrate_285v.json`](../inputs/substrate_285v.json): 285 vertices, 567 edges, 48 D₆ orbits (47 size-6 full-stabilizer orbits + 1 size-3 waist orbit), with `bhupura_pattern_indices` (the 47 size-6 orbits, decision D3) and `lotus_pattern_indices` (the size-3 waist orbit) baked in as vertex index lists.

This fixture was derived from the `substrate-reconstruction-2026-04-26` workstream's settled-identity NPZ and `orbit_decomposition.json`. The substrate identity — T(3,21) torus link on T², D₆ = S₃ × Z₂ automorphism group, Q over Pythagorean rationals, 190 distinct eigenvalue levels — is settled and not in scope for re-derivation here.

The canonical 4-step pipeline is driven by `configs/CONFIG.json` (deployed on-device at `/data/local/tmp/genesis/configs/CONFIG.json`; not committed to `inputs/` in this repo). The CONFIG drives `TEST_TRIADS` layout, `eta_num`/`eta_den`, `drive_mode`, and the cfg_hash seed for the deterministic noise RNG.

The sibling document [SUBSTRATE.md](SUBSTRATE.md) (authored separately) documents the substrate identity in detail. ARCHITECTURE.md cross-references it; the two documents are complementary.

---

## Failure Modes + Resume Semantics

| Failure | Detection | Recovery |
|---|---|---|
| master_watcher.sh dies | Not auto-detected; nothing monitors the watcher | Manual: `nohup harness/master_watcher.sh --master-pid <pid> >> logs/watcher.log 2>&1 &` |
| master (genesis_chain_v1.sh) dies mid-cell | watcher detects within 30 s via `kill -0` poll | `resume_chain.sh` re-spawns master; in-flight cell has no `outcome.json` → re-run from scratch on next master pass |
| instance dies mid-iter | parent batch's `wait` returns non-zero; `failures` counter increments | Other 5 instances continue; cell `batch_verdict` = FAIL or PASS depending on whether any instance completed successfully with matching SHA |
| thermal exceedance | `thermal_coordinator.sh` polls every 5 s | SIGSTOP all `snic_rust` processes; 30 s cooldown; SIGCONT; if still hot: write `thermal_kill.log` and exit 1; cell verdict = KILL |
| ADB disconnect (mid-run) | Not visible to the chain (fully autonomous on-device) | Chain runs to completion; receipts persist on phone; pull with `adb pull` on reconnect |
| Binary missing or SHA mismatch | `run_genesis_cell.sh` pre-flight `sha256sum` check | Exit 10; `error.txt` written to instance dir; that instance counts as a failure |
| cells.txt manifest missing | `genesis_chain_v1.sh` pre-flight check | Exit 4 with log; must redeploy manifest and relaunch master |

**Resume semantics:** `cells.txt` is read once at master start. To extend the manifest after the chain is already running:

1. Edit `cells.txt` on host and `adb push` to device.
2. Kill the watcher (`kill <watcher_pid>`) first so it does not auto-restart.
3. Kill the master (`kill <master_pid>`).
4. `resume_chain.sh` to spawn a new master — it reads the updated manifest.
5. Relaunch `master_watcher.sh` with the new master PID.

Cells with existing `outcome.json` are SKIPped by the new master. Only cells added to the manifest (or cells whose `outcome.json` was manually removed) will run.

---

# Operations Manual

The remainder of this document is the chain-operator's reference: manifest format, cell/task procedures, launching, stopping, monitoring, pulling, recovery, hardware extension, and out-of-scope items. As of 2026-05-01 the v1.0 backend chain is closed; this section is preserved for v2.0 reactivation and for auditor reference.

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

**Examples from the historical manifest:**

```
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
3. The running chain reads the manifest once at startup. To pick up the new cell without waiting for the current chain to finish, kill the master and let the watcher restart it (see §Stopping the Chain Cleanly and §Launching the Chain). The new master reads the updated manifest; cells with existing `outcome.json` are SKIPped immediately.

**Idempotency guarantee:** a cell is SKIPped if and only if `cells/<CELL_ID>/outcome.json` exists. Appending a new `CELL_ID` that has never run is safe; removing a cell from the manifest does not delete its receipts on the phone.

---

## Adding a New Task Subcommand

New task subcommands must be implemented in the upstream Genesis source workspace, not in the `genesis_comparative` repository.

1. In `crates/io_cli/src/main.rs` (upstream source): add a `Cmd::<NewTask>` variant to the `enum Cmd` and a dispatch arm in `fn main()`. Create the module at `crates/io_cli/src/<new_task>.rs`. All numeric work must use `num_rational::BigRational`; floats only for `printf` output. The workspace `#![deny(warnings)]` is enforced.
2. Cross-compile for aarch64-linux-android (NDK env-var route; see [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md) §Cross-compile recipe).
3. Capture the new binary SHA-256 with `sha256sum target/aarch64-linux-android/release/snic_rust`.
4. Push to phone and update `genesis_meta.txt` with the new build hash.
5. Run a BITDET cell for the new task before any science cells, to confirm determinism.
6. Update the manifest with science cells using `--task <new-task>`.

The harness dispatches the `--task` value directly as the `snic_rust` subcommand. Any subcommand that is not one of `{k2-scars}` and that does not read `--substrate` and `--steps` will need a patch to `run_genesis_cell.sh`'s Phase 1+ execution path.

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

After launch: enable game-cooling mode on the phone, point a fan at it, and optionally place it in a refrigerator for thermal headroom. The chain runs fully autonomously after this point; ADB can be disconnected.

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

**To preserve in-flight cell progress:** wait for the current cell's `outcome.json` to appear before killing.

Killing the chain mid-cell loses that cell's `outcome.json` (in-flight instances do not write receipts on SIGKILL). The cell will re-run from scratch on next master start.

---

## Reading Chain Progress

```bash
# See which cells have completed
adb -s FY25013101C8 shell ls /data/local/tmp/genesis/cells/

# Tail chain log live
adb -s FY25013101C8 shell "tail -f /data/local/tmp/genesis/logs/chain.log"

# Read a cell's verdict
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/cells/K2_S30/outcome.json

# Extract KPI summaries for a cell
adb -s FY25013101C8 shell \
  "grep KPI_K2_SUMMARY /data/local/tmp/genesis/cells/K2_S30/*/stdout.log"

# Read cell-level summary
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/cells/K2_S30/_summary.json
```

---

## Pulling Receipts

Pull all cell directories from device to host:

```bash
adb -s FY25013101C8 pull \
  /data/local/tmp/genesis/cells/ \
  proofs/artifacts/
```

After pull, verify receipt integrity and produce a verdict roll-up:

```bash
cd proofs/artifacts
find . -name "outcome.json" \
  | xargs -I{} sh -c 'jq -r ".cell + \" \" + .verdict" "{}"'

# Determinism verdict across all cells (all should be 1)
find . -name "_summary.json" \
  | xargs -I{} sh -c 'jq -r ".cell + \" sha_count=\" + (.unique_canonical_sha_count|tostring)" "{}"'
```

Before commit, strip the heavyweight `wd/` working directories from each per-instance dir — only `receipt.json`, `canonical_stdout.sha256`, `artifact_hashes.json`, `stdout.log` are committed (the receipts are self-certifying via `receipt_sha`; the `wd/` content is reproducible from the binary + config).

---

## Recovering from a Stuck State

```bash
# Master dead, watcher dead, no auto-recovery
adb -s FY25013101C8 shell \
  "cd /data/local/tmp/genesis && \
   nohup harness/resume_chain.sh >> logs/resume.log 2>&1 &"

# Cell stuck in-progress (no outcome.json, instances all dead)
adb -s FY25013101C8 shell rm -rf /data/local/tmp/genesis/cells/<STUCK_CELL>/

# ADB hung
adb kill-server && adb start-server

# thermal_kill.log present (chain killed a cell for thermal)
adb -s FY25013101C8 shell cat /data/local/tmp/genesis/logs/thermal_kill.log
adb -s FY25013101C8 shell rm /data/local/tmp/genesis/cells/<CELL>/outcome.json
adb -s FY25013101C8 shell rm /data/local/tmp/genesis/logs/thermal_kill.log
```

The chain runs fully autonomously on-device. ADB disconnect does not affect chain progress; receipts persist on phone and pull on reconnect.

---

## Extending to More Cores or Different Hardware

**cpu7 hard-block:** Mask `0x80` (cpu7) is permanently reserved for the sibling dm3_runner lane. Genesis never uses it.

**To repurpose cpu6 (currently the thermal-margin core):** edit `PARENT_AFFINITY_MASK` in `launch_genesis_batch.sh` and increase `--instances` to 7 in the manifest. Requires operator-visible decision; thermal validation of 7-core sustained load is a prerequisite.

**To run on a different aarch64-android phone:**
1. Confirm `taskset` accepts bare-hex masks (Toybox format). Some devices require `--cpu-list`.
2. Identify cluster topology and any sibling workload PIDs.
3. Rebuild `snic_rust` targeting the device's Android API level.
4. Update `PARENT_AFFINITY_MASK` and `DEFAULT_MASKS` in `launch_genesis_batch.sh`.
5. Update `thermal_coordinator.sh` sensor filter for the device's thermal-zone naming convention.
6. Run a BITDET cell (`--test-battery 10`) before any science cells to confirm byte-determinism on the new device.

---

## What's Out of Scope (for the v1.0 chain)

- **K2-task cross-platform parity beyond S30 (host-side)** — RM10 anchors at S20 / S40 / S50 are now in-repo; host-side byte comparison at those step values is a small host-only task. Not yet automated.
- **Source recovery for dm3_runner** — separate workstream.
- **Multi-device chain orchestration** — one phone at a time. The chain has no inter-device coordination.
- **`SYMMETRY` cell with Z₂-asymmetric pattern** — listed as DEFERRED. Requires operator-visible decision plus a Z₂-asymmetric pattern design before adding to manifest.
- **`DISCONT` cell** — only triggered if K2_SWEEP shows a cliff. Phase 2 settled this question (no Genesis cliff at S50). Not in the manifest.
- **HF dataset push** (`Zer0pa/DM3-artifacts`, `genesis/` subdir) — manual after chain close per PRD §Receipts.
