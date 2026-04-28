# Determinism Discipline

This document is the entry point for a researcher who needs to understand **how byte-identity
is enforced** in Genesis. The determinism property is not a target engineered separately; it
is a necessary consequence of the exact-rational arithmetic discipline described here.

---

## The Property

Genesis exhibits **byte-identical canonical output across re-execution, hardware platform,
thermal conditions, and time.**

Specifically, `sha256(artifacts/verify.json)` returns:

```
97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89
```

and `sha256(artifacts/solve_h2.json)` returns:

```
62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780
```

for ANY invocation of the `snic_rust` 4-step pipeline:

```
snic_rust build-2d && snic_rust lift-3d && snic_rust solve-h2 && snic_rust verify
```

with `configs/CONFIG.json` as input, on ANY supported platform. These values are
source-hardcoded in `genesis_cli/src/main.rs:11-14` as `CANONICAL_VERIFY_HASH` and
`CANONICAL_SOLVE_HASH` — the source author's reproducible reference.

**Note on the M1 host build:** The M1 host build of `genesis_cli` (wrapper layer) produces
`verify.json = e8941414...` (not `97bd7d...`) due to a trailing-newline serialization-layer
difference in the `refresh_receipts` rewrite path. This is documented as a BENIGN disposition
(Decision D1). The actual snic_rust standalone pipeline (`io_cli`) produces `97bd7d...`
exactly on both M1 and RM10. All receipt `canonical_sha` fields in this experiment reference
the `snic_rust` direct output. See [`../harness/host/HASH_GATE_DISPOSITION.md`](../harness/host/HASH_GATE_DISPOSITION.md)
for the full D1 narrative.

---

## The Three Sources of Non-Determinism (and How Genesis Avoids Them)

| Source | Genesis disposition |
|---|---|
| Floating-point arithmetic | Forbidden in core crates by POLICY_CHECK.sh (`f32`/`f64` triggers exit 14); `num_rational::BigRational` throughout all computational paths |
| RNG / randomness | Forbidden in core crates by POLICY_CHECK.sh (`rand::`, `thread_rng`, `StdRng`, `ChaCha` triggers exit 13); K2 noise uses deterministic SHA-256 derivation only (see §Deterministic Pseudo-Random) |
| Concurrency / scheduler | `snic_rust` subcommands are single-threaded; workspace declares `rayon` but zero crates use threading primitives; 6-instance parallelism in the chain harness is observational (6 independent pipelines each producing the same output), not algorithmic |

All three sources are controlled at the **source level**, not the build level. No compiler
flags, linker options, or platform ABI properties can reintroduce these sources because they
are removed from the code.

---

## Rational Arithmetic Throughout

The core computational discipline is `num_rational::BigRational` — arbitrary-precision exact
rational arithmetic — for every number in every core crate.

The covered crates (enforced by POLICY_CHECK.sh) are:
- `geometry_core` — coordinate geometry on T²
- `yantra_2d` — base graph construction
- `lift_3d` — 3D helix embedding
- `dynamics_deq` — linear system solver (solve-h2 step)
- `invariants` — graph invariant computation
- `proof_gates` — verification gate checks

**Example from `dynamics_deq/src/lib.rs:122-123`:**

```rust
let alpha = Rat::new(BigInt::from(164), BigInt::from(165));
let one_minus_alpha = Rat::new(BigInt::one(), BigInt::from(165));
```

The spectral convergence parameter α = 164/165 is stored and propagated as an exact rational
numerator-denominator pair. The floating-point approximation 0.993939... is never computed.
Every intermediate value in the Gauss-Jordan solve (`solve_linear_gauss_jordan`) accumulates
in `Rat` arithmetic; no rounding error is possible.

**K2 task (`k2_scars` module):** `eta = Rat::new(BigInt::from(eta_num), BigInt::from(eta_den))`
for the default eta = 1/5. Scar weights `S += eta · p_centered ⊗ p_centered` are BigRational
tensor products. Modified row-stochastic dynamics `x_{t+1} = α · P_mod · x_t + (1−α) · p_noisy`
operates entirely in BigRational. The only floats in the K2 code path are the **output
formatters** (`fmt_sci`, `fmt_fixed6`) used to write the KPI log lines — these are display
transformations of already-computed exact rationals, not part of the computation.

**Consequence:** Two machines running the same `snic_rust` binary on the same `CONFIG.json`
must produce byte-identical JSON output. There is no IEEE-754 rounding mode, no
platform-dependent floating-point library, no non-deterministic scheduler choice that can
cause divergence — because none of these mechanisms participate in the computation.

---

## Deterministic Pseudo-Random (Where Needed)

The K2 protocol introduces "noise" by flipping a pattern vertex's binary state with
probability p_noise (typically 1/10 or 2/10). This appears random but is deterministically
derived.

**Derivation mechanism:** for each flip decision, K2 computes:

```
hash_input = cfg_hash || lesson || noise_idx || pattern_idx || vertex_idx
flip = sha256(hash_input)[0] < floor(256 × noise_num / noise_den)
```

For `noise = 1/10`: threshold = floor(256/10) = 25. A first byte of sha256 in [0..24] (out of
[0..255]) gives probability ≈ 9.77%. For `noise = 2/10`: threshold = 51, probability ≈ 19.92%.
The rational threshold is computed with integer arithmetic; no floats are used in the
threshold comparison.

**Same input → same hash → same flip decision → same noise pattern.**

The `cfg_hash` is the SHA-256 of the serialized `CONFIG.json` content, computed at binary
startup. It ensures that different configs (different substrate, different eta, different build
parameters) produce different noise seeds even at identical lesson/noise/pattern/vertex indices.

The result: two invocations of `snic_rust k2-scars --substrate inputs/substrate_285v.json --steps 30`
on any platform, at any time, under any thermal condition, produce byte-identical
`artifacts/k2_summary.json`.

---

## Canonical Hash Layer

The `snic_rust` pipeline writes 4 JSON artifact files to `artifacts/`:

| File | Produced by | SHA-256 (canonical) |
|---|---|---|
| `artifacts/yantra_2d.json` | `snic_rust build-2d` | (varies with CONFIG.json; content is the base graph) |
| `artifacts/lift_3d.json` | `snic_rust lift-3d` | (depends on yantra_2d.json) |
| `artifacts/solve_h2.json` | `snic_rust solve-h2` | `62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780` |
| `artifacts/verify.json` | `snic_rust verify` | `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89` |

The `verify.json` and `solve_h2.json` hashes are the canonical fingerprints. `solve_h2.json`
is the load-bearing scientific output (the linear-system solution vector); `verify.json` is
the verification summary (7 gate verdicts). Both are source-hardcoded in the genesis source.

The `k2_summary.json` produced by the K2 task has its own canonical hash, currently:

```
0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372
```

(from Phase 1 host-side two-run check; see `.gpd/STATE.md` Phase 1 K2 BITDET entry).

---

## Cross-Iter Byte-Identity Check

The phone-side harness script `run_genesis_cell.sh` runs the pipeline N times per instance
(`--test-battery N` semantics, forwarded from the chain manifest). Each iteration:

1. Runs `snic_rust build-2d && lift-3d && solve-h2 && verify`.
2. Computes `sha256(artifacts/verify.json)` via `sha256sum`.
3. Compares against the previous iteration's hash. If they diverge: sets `bitdet_pass=0`
   and logs `BITDET-BREACH` with both hashes.

**Cross-iter determinism** is the fundamental check: the same binary on the same hardware in
the same process environment produces the same output on every re-run. Any divergence here
is a determinism breach, not a statistical fluctuation — `bitdet_pass=0` halts the chain.

As of 2026-04-28: `bitdet_pass=1` for every cell run to date.

---

## Cross-Instance Byte-Identity Check

`launch_genesis_batch.sh` fans out 6 independent instances per cell, pinned to cpu0-5 via
`taskset` masks `0x01, 0x02, 0x04, 0x08, 0x10, 0x20`. Each instance:

- Runs its own pipeline in its own working directory.
- Produces its own `artifacts/verify.json`.
- Computes its own `canonical_sha`.

After all 6 instances complete, `_summary.json` aggregates the 6 receipts and computes
`unique_canonical_sha_count` — the number of distinct hash values across the 6 instances.

**Expected:** 1 (all 6 produce the same hash).
**Observed for every completed cell:** 1.

This cross-instance check is independent of cross-iter: it validates that 6 processes
running concurrently on different CPU cores, scheduled by the Linux kernel at different
times, produce byte-identical output — confirming no scheduler-induced non-determinism.

---

## Cross-Platform Parity (Claim τ)

**M1 (aarch64-apple-darwin, native build) and RM10 (aarch64-linux-android, NDK
cross-compiled build) both produce the same canonical hashes.**

Verified:
- M1 `snic_rust` (host SHA `e21208a6...`): `verify.json = 97bd7d...`, `solve_h2.json = 62897b...`
- RM10 `snic_rust` (on-device SHA matching host SHA after `adb push`): `verify.json = 97bd7d...`,
  `solve_h2.json = 62897b...`

This is **claim τ** in `project_contract.json`. It holds because the computation is
exact-rational: the same BigRational arithmetic on the same inputs produces the same
BigInteger quotients regardless of platform ABI, OS, or instruction set. There is no
IEEE-754 rounding mode to differ between platforms.

The Phase 0 binary (host SHA `7abbf04a...`) and Phase 1 binary (host SHA `e21208a6...`)
both produce the same canonical pipeline hashes. The K2 subcommand addition in Phase 1
extends `main.rs` dispatch but does not modify the upstream 4-step pipeline crates.

---

## Hardware/Thermal Invariance (Claim ξ)

Phase 0 BITDET cells accumulated 1560 + 30000 cross-checked `verify.json` hashes across
varied thermal and scheduling conditions:

| Cell | Iterations × Instances | Total hashes | Result |
|---|---|---|---|
| BITDET_01 | 10 × 6 | 60 | All = `97bd7d...` |
| BITDET_02 | 50 × 6 | 300 | All = `97bd7d...` |
| BITDET_03 | 200 × 6 | 1200 | All = `97bd7d...` |
| BITDET_5K | 5000 × 6 | 30000 | All = `97bd7d...` (confirmed) |

**Conditions varied across these cells:**

- **Thermal:** RM10 operating range 44–60°C; some cells run with device at ambient temperature,
  some with active cooling (fridge + fan + Game Zone). No thermal-induced divergence observed.
- **Time:** cells span tens of minutes of wall-clock time across different RM10 power states.
- **CPU scheduler:** the Linux kernel's `core_ctl` subsystem on the RM10 Qualcomm SoC
  dynamically pauses 1–2 cores for power management during execution. The harness parent
  process holds taskset mask `0x7F` (cpu0-6); child instances are pinned to individual cores
  `0x01..0x20` (cpu0-5). Scheduler variance across 6 cores running concurrently does not
  produce divergence.

---

## What's Verified Today, What's Pending

| Property | Status | Evidence |
|---|---|---|
| 4-step pipeline canonical match (M1 + RM10) | VERIFIED | `97bd7d...` and `62897b...` on both platforms; BITDET_01-03 + 5K cells |
| Cross-iter byte-identity (snic_rust direct) | VERIFIED | 1560 + 30000 cross-checked hashes; `bitdet_pass=1` all cells |
| Cross-instance byte-identity (6 parallel) | VERIFIED | `unique_canonical_sha_count = 1` for every completed cell |
| Cross-platform parity at pipeline level (M1 ↔ RM10) | VERIFIED | Both produce `97bd7d...` + `62897b...` (STATE.md §Phase 0) |
| K2 task BITDET (M1 host) | VERIFIED | Two consecutive `k2-scars --steps 30` runs: `k2_summary.json` SHA `0b5442f9...` byte-identical |
| K2 task BITDET (phone, RM10) | PENDING | Phase 2 K2_SWEEP running on phone; receipts pull on reconnect |
| Cross-platform parity at K2 level (M1 ↔ RM10) | PENDING | Requires explicit `k2_summary.json` SHA comparison across platforms; not yet automated |
| Cross-thermal invariance at K2 level | PENDING | Falls out of phone K2_SWEEP if all 30 cells produce identical `k2_summary.json` SHA across thermal range |
| Cross-time invariance (long-horizon, >24 hr) | PENDING | Requires multi-day re-execution evidence |

---

## Falsification Path

The chain harness produces receipts; each receipt carries `canonical_sha`. The audit path:

1. **Per-cell:** read `cells/<CELL>/_summary.json`. Check `unique_canonical_sha_count == 1`
   and `failures == 0`. A cell with `unique_canonical_sha_count > 1` is a determinism breach.
2. **Per-receipt:** read `canonical_sha` field. Must equal `97bd7d...` (pipeline) or the
   K2-task canonical hash for K2 cells. Any receipt with a different value is a substantive
   finding.
3. **Cross-cell:** aggregate `unique_canonical_sha_count` across all cells in a chain run.
   If any cell breaks, the determinism claim is not uniform and the specific conditions
   (thermal, cpu, steps value) become the investigation target.

The receipts include:
- `canonical_sha` (the pipeline output hash)
- `binary_sha256` (which snic_rust binary was used)
- `taskset_mask` (which CPU cores were active)
- `env_pre.thermal_zone0_c` and `env_post.thermal_zone0_c` (thermal bracket)
- `timestamp_utc` (wall-clock anchor)

A single receipt with `canonical_sha != 97bd7d...` (Phase 0 pipeline) does not just fail
that one cell — it breaks the uniformity of the determinism claim. The correct response is
not to discard the receipt but to interrogate it: which binary, which thermal, which CPU,
which steps value. The breach is the finding; the conditions around it are the mechanism to
recover from.

---

## References

- [`../harness/host/HASH_GATE_DISPOSITION.md`](../harness/host/HASH_GATE_DISPOSITION.md) — D1 BENIGN disposition; M1 vs source-canonical hash narrative
- [`../.gpd/STATE.md`](../.gpd/STATE.md) — Phase 0 BITDET evidence; Phase 1 K2 BITDET check; canonical hash ledger
- `/Users/Zer0pa/DM3/recovery/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/scripts/POLICY_CHECK.sh` — float/RNG policy enforcement
- `/Users/Zer0pa/DM3/recovery/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/crates/dynamics_deq/src/lib.rs` — BigRational α=164/165 example
- `/Users/Zer0pa/DM3/recovery/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/crates/io_cli/src/main.rs` — 4-step pipeline + K2 dispatch
- [`../project_contract.json`](../project_contract.json) — claim-bitdet, claim-parity, test-bitdet-N10, test-parity-M1-RM10 formal encoding
- [`../docs/SUBSTRATE.md`](SUBSTRATE.md) — substrate identity (Q-Pythagorean rationals; foundation of determinism)
