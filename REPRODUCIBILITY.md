# Reproducibility

**Status:** always-in-beta. Phase 0 + Phase 1 canonical; Phase 2 sweep in progress on RM10.

---

## Source workspace

```
Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/
  00_GENESIS_ORGANISM/snic_workspace_a83f/
```

The `io_cli` crate (binary `snic_rust`) is the standalone Genesis-organism pipeline.
`genesis_cli` is a host-side meta-orchestrator (invokes `cargo`); do not deploy it to Android.

---

## Cross-compile recipe

Set NDK environment variables (NDK at `/usr/local/share/android-ndk`):

```bash
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=\
  /usr/local/share/android-ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android24-clang
export CC_aarch64_linux_android=\
  /usr/local/share/android-ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android24-clang
export AR_aarch64_linux_android=\
  /usr/local/share/android-ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar
```

Build from workspace root:

```bash
cd Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f
cargo build --release --target aarch64-linux-android -p io_cli
```

No `cargo-ndk` required. No system `cc` override needed — NDK env-var route is sufficient.

### Expected binary SHAs

| Phase | Binary | Host SHA-256 |
|-------|--------|--------------|
| 0 | `snic_rust` (4 subcommands: build-2d, lift-3d, solve-h2, verify) | `7abbf04a6656ef9f70d713e2fd8df1dafbb392a36ef75e6e8d74ea844922ac57` |
| 1 | `snic_rust` (5 subcommands incl. `k2-scars`) | `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1` |

Verify before pushing to phone: `sha256sum target/aarch64-linux-android/release/snic_rust`

---

## On-device deploy

```bash
# Sibling-lane independence check (must pass before any Genesis deploy)
adb shell pidof dm3_runner   # note PID; do not signal it

# Create namespace
adb shell mkdir -p /data/local/tmp/genesis/{harness,cells,logs,inputs,configs,artifacts}

# Push binary and inputs
adb push target/aarch64-linux-android/release/snic_rust /data/local/tmp/genesis/
adb push inputs/substrate_285v.json /data/local/tmp/genesis/inputs/
adb push configs/CONFIG.json /data/local/tmp/genesis/configs/

# Push harness scripts
adb push harness/phone/run_genesis_cell.sh     /data/local/tmp/genesis/harness/
adb push harness/phone/launch_genesis_batch.sh /data/local/tmp/genesis/harness/
adb push harness/phone/thermal_coordinator.sh  /data/local/tmp/genesis/harness/
adb push harness/phone/genesis_chain_v1.sh     /data/local/tmp/genesis/harness/
adb push harness/phone/master_watcher.sh       /data/local/tmp/genesis/harness/
adb push harness/phone/resume_chain.sh         /data/local/tmp/genesis/harness/

chmod +x: adb shell "chmod +x /data/local/tmp/genesis/snic_rust \
  /data/local/tmp/genesis/harness/*.sh"
```

---

## Smoke test

Run the 4-step pipeline pinned to a single core, then verify both canonical hashes:

```bash
adb shell "cd /data/local/tmp/genesis && \
  taskset 1 ./snic_rust build-2d  --config configs/CONFIG.json && \
  taskset 1 ./snic_rust lift-3d   --config configs/CONFIG.json && \
  taskset 1 ./snic_rust solve-h2  --config configs/CONFIG.json && \
  taskset 1 ./snic_rust verify    --config configs/CONFIG.json"
```

Expected canonical SHAs:

| Output | SHA-256 |
|--------|---------|
| `artifacts/verify.json` | `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89` |
| `artifacts/solve_h2.json` | `62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780` |

Both must match before proceeding to chain launch. Hash mismatch = stop and document; do not extend the BENIGN diagnosis from `harness/host/HASH_GATE_DISPOSITION.md` beyond the M1/aarch64 scope it covers.

**Note on `taskset` syntax:** RM10 ships Toybox; use bare hex masks (`taskset 1`, `taskset 3f`) not `--cpu-list` flags.

---

## Chain launch

```bash
# From Mac (harness controller), with device attached:
adb shell "cd /data/local/tmp/genesis && \
  nohup harness/master_watcher.sh > logs/watcher.log 2>&1 &"
adb shell "cd /data/local/tmp/genesis && \
  nohup harness/resume_chain.sh   > logs/resume.log  2>&1 &"
```

`resume_chain.sh` is idempotent — safe to re-run if chain died. `master_watcher.sh` polls every 30 s and re-launches chain master on death.

---

## Receipt schema

```
cells/
  <CELL_ID>/
    <INSTANCE>/
      stdout.log
      receipt.json
      canonical_stdout.sha256
      artifact_hashes.json
    outcome.json        # per-cell aggregate (pass/fail + unique_canonical_sha_count)
    _summary.json       # per-cell summary stats
```

`outcome.json` passes iff `unique_canonical_sha_count = 1` (all instances produced byte-identical output).

---

## Determinism property

Every iteration of every instance produces byte-identical `verify.json` (Phase 0 pipeline) or `k2_summary.json` (Phase 1+). The chain harness checks `unique_canonical_sha_count` per cell — must equal `1`. Any count > 1 is a determinism failure and must be filed as a FAIL receipt with full stdout captured before any further analysis.

---

## Hardware envelope

- **Device:** RedMagic 10 Pro (Snapdragon 8 Elite Gen 4; `FY25013101C8`)
- **CPU affinity:** parent-affinity mask `7F` (cpu0–6); per-instance `--core auto` (Qualcomm `core_ctl` quirk mitigation — transient pause-flapping on cluster cpu0–5 causes SIGSTOP/SIGCONT cascades without parent-affinity guard)
- **cpu7 reservation:** hard-blocked (`0x80` mask excluded) — reserved for sibling `dm3_runner` lane
- **Thermal ceiling:** 70 °C (`thermal_coordinator.sh` polls at 5 s; issues SIGSTOP above ceiling, SIGCONT once cool)
- **Sibling-lane check:** `adb shell pidof dm3_runner` before every deploy; never signal, kill, or alter any `dm3_runner` or `cells/G*/` artifact
