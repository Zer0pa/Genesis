# Genesis Comparative — Architecture

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

**`thermal_coordinator.sh`** — active thermal gate. Polls `/sys/class/thermal/thermal_zone*/temp` every 5 s (only `cpu-*`, `cpuss-*`, `gpuss-*` sensor types counted). On exceedance of 70 °C ceiling (PRD §Deployment): SIGSTOPs all `snic_rust` processes, sleeps 30 s, checks again. If still above ceiling after cooldown: writes `logs/thermal_kill.log` and exits 1 (which causes `genesis_chain_v1.sh` to assign `KILL` verdict to the cell). Exits cleanly when parent (batch) pid dies or stop-flag file appears.

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

**Thermal discipline:** `thermal_coordinator.sh` is spawned as a sibling for every batch launch. It polls cpu/gpu thermal zones every 5 s. On 70 °C exceedance:
1. SIGSTOP all `snic_rust` processes.
2. Sleep 30 s cooldown.
3. Re-read temperature; if still ≥ 70 °C: write `logs/thermal_kill.log` and exit 1 (genesis_chain_v1.sh detects this and assigns `KILL` verdict to the cell).
4. If cooled: SIGCONT all `snic_rust` processes.

The 70 °C ceiling is the PRD §Deployment hard limit. For extended runs, the RM10 is operated with a physical fan, game-cooling mode (Game Zone) enabled, and optionally the phone placed in a refrigerator for additional thermal headroom. The charger may remain attached; battery power is not required for autonomous operation.

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
