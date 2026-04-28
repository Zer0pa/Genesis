# Changelog

All research-significant changes are recorded here. This is a research repository; "release" entries reflect phase completions and verified result boundaries, not software distribution events.

---

## [0.1.0] — 2026-04-28

### Phase 0 — Foundation, cross-compile, BITDET (commits up to `425647f`)

- Established workspace at `genesis_comparative/` under `Zer0pa/Genesis` (branch `inspection-2026-04-28`, cut from `main@c43a402`).
- Identified `io_cli` (binary `snic_rust`) as the correct standalone Genesis-organism pipeline; retracted `genesis_cli`-as-organism as `fp-shapematch` corruption (see `.gpd/STATE.md` retractions).
- Cross-compiled `snic_rust` for `aarch64-linux-android` via NDK env-var route (no `cargo-ndk`); host SHA `7abbf04a6656ef9f70d713e2fd8df1dafbb392a36ef75e6e8d74ea844922ac57` (Phase 0 binary, 4-step pipeline).
- Deployed to RedMagic 10 Pro (`FY25013101C8`); on-device smoke test passed; pipeline produces source-canonical hashes directly (`verify.json = 97bd7d…`, `solve_h2.json = 62897b…`).
- BITDET cells BITDET_01 (60 runs), BITDET_02 (300 runs), BITDET_03 (1200 runs) all PASS: `unique_canonical_sha_count = 1` across all 1 560 `verify.json` instances.
- Authored 6 harness scripts (`run_genesis_cell.sh`, `launch_genesis_batch.sh`, `thermal_coordinator.sh`, `genesis_chain_v1.sh`, `master_watcher.sh`, `resume_chain.sh`; ~960 lines total, busybox-sh portable).
- Hardware envelope characterised: parent-affinity mask `7F`; per-instance `--core auto`; cpu7 reserved for sibling `dm3_runner` lane; 70 °C thermal ceiling.
- Substrate identity settled (from `substrate-reconstruction-2026-04-26` lane): T(3,21) torus link, D₆ symmetry, 285 vertices, 567 edges, 48 D₆ orbits, Q-Pythagorean number field.
- Long-running BITDET cells (5 K, 50 K, 500 K iter) launched autonomously; receipts pending on RM10 reconnect.

### Phase 1 — K2 port (commit `c43a402`)

- Ported `exp_k2_scars` as 5th subcommand of `io_cli` (`crates/io_cli/src/k2_scars.rs`, 506 lines + main.rs updates).
- Algorithm: Hebbian scar weights (S += η · p_centered ⊗ p_centered on edge support); modified row-stochastic dynamics x_{t+1} = α·P_mod·x_t + (1−α)·p_noisy with α = 164/165; deterministic Bernoulli noise via SHA-256(cfg_hash ‖ lesson ‖ noise_idx ‖ pattern ‖ vertex); recall_err = Hamming distance after threshold at 1/2.
- All numeric work via `num_rational::BigRational`; no floating-point in math path. Workspace `#![deny(warnings)]` honoured.
- D₆-orbit analog pre-registered: 47 size-6 orbits = Bhupura analog (full D₆ stabilizer); 1 size-3 waist orbit = Lotus analog (mirror-fixed singular). Baked into `inputs/substrate_285v.json`.
- BITDET at K2 task level (M1 host): two consecutive `k2-scars --steps 30` runs produce byte-identical `artifacts/k2_summary.json` (SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`).
- Cross-compiled Phase 1 `snic_rust`; host SHA `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1`.
- Curious-number finding pre-registered for Phase 2: Genesis K2 at `--steps 30` yields uniform |scar| = 1.2 across all 567 edges + perfect recall (avg_recall_err = 0.0) + best_uplift = 3.0. Mathematical origin: rank-1 effect of disjoint Bhupura(282) + Lotus(3) outer products. Possible degenerate K2 dynamics; Phase 2 sweep will test whether value is constant (degenerate) or varies (real substrate effect).

### Phase 2 — Autonomous K2 sweep (in progress on RM10)

- K2 sweep over `--steps ∈ {20, 28, 29, …, 56}` running autonomously on RM10 via `genesis_chain_v1.sh`; receipts will land in `cells/K2_SWEEP_S*/` on next RM10 reconnect.
- Four pre-registered cross-lane comparisons pending: cycle-7, s50-cliff, σ″-curve diff, D₆-vs-C₃ symmetry.
- **Receipts not yet pulled.** Verdicts for this phase are UNTESTED until receipts are available.

### Phase 3 — Synthesis (pending)

- Cross-lane synthesis against pre-registered comparisons.
- Final report.
- Not started.

---

## Open Workstreams

The following categories of work are active, open, or blocked. This section carries the honest-blocker posture required by the Zer0pa portfolio ethos.

### Infrastructure / unblocked

- Phase 2 K2 sweep receipts: pending RM10 reconnect. No engineering blocker; device-availability only.
- `genesis_meta.txt` deploy convention: 5-line shell snippet to write `build_hash` + `target_triple` at adb-push time; not yet authored as a script.

### Blocked on external input

- RM10 device offline as of 2026-04-28: `adb devices` returns empty. Reconnect required before Phase 2 receipt pull.
- Cross-lane D₆-vs-C₃ symmetry comparison: `dm3_runner` source recovery (separate `Zer0pa/DM3` workstream) must reach substrate characterisation before this comparison can be resolved.

### Open scientific questions

- Genesis K2 degenerate dynamics: whether uniform |scar| = 1.2 is a property of the D₆/D₃-orbit pattern choice or a property of the substrate itself. Phase 2 sweep over `--steps` range is the primary discriminant; alternative orbit picks are a secondary test if sweep shows constant behaviour.
- Cycle-7 Lomb-Scargle CI width: at N = 3 per step over a 30-point range, 95% CI may not cleanly separate period 7 from 6 or 8. Pre-registered disambiguator (`test-cycle7-disambiguator`) may be the load-bearing test.

### Deferred

- dm3 task types beyond `exp_k2_scars` (11 task types): deferred per D2. No timeline until Phase 3 synthesis indicates value.
- GPU/multi-device scaling: not in scope for this experiment.
