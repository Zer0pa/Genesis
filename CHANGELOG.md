# Changelog

All research-significant changes are recorded here. This is a research repository; "release" entries reflect phase completions and verified result boundaries, not software distribution events.

---

## [1.0.0] — 2026-05-01

### v1.0 closure — Backend chain CLOSED; phone released

- Pulled `BITDET_K2_S40_PARITY` and `BITDET_K2_S50_PARITY` from RM10 — the two remaining parity-sweep extension cells. Both PASS, `unique_canonical_sha_count = 1`, 6 instances × 50 iters = 300 K2 invocations per cell. SHAs `38be38e2…` (S40, matches handover-expected) and `f5cd3876…` (S50, new — wasn't recorded at handover time). Brings the in-repo receipt surface to 74 cells / 74 PASS / 0 divergences.
- Phase 3 parity-sweep extension is now COMPLETE in-repo: three RM10-side comparison anchors at S20 / S40 / S50 ready for any future host-side widen-coverage byte-comparison (host-only; no chain reactivation required).
- Aggregated curve [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv) extended to 75 lines (1 header + 74 cell rows).
- Authored [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md) — the v1.0 final synthesis. Renders the four pre-registered comparison verdicts with receipt evidence (Comparisons #1–#3 settle empirically; Comparison #4 lands as analytic disposition: structural inclusion D₆ ⊃ C₃ confirmed, D3 pattern map proven exactly Z₂-invariant by construction, numerical Z₂-projection observable deferred to v2.0 because it requires a Z₂-asymmetric pattern, i.e. a new chain run). Determinism scorecard, settled / pending / falsification path, and v2.0 outlook included.
- Curated the 10-doc reviewer pack and merged overlapping documents:
  - `docs/CHAIN.md` folded into `docs/ARCHITECTURE.md` as a new "Operations Manual" section. Architecture and operations now under one document.
  - `docs/FAQ.md` folded into `AUDITOR_PLAYBOOK.md` as a new "Frequently Asked Questions" section. Audit Q&A and reviewer FAQ under one document.
  - `FINDINGS.md` folded into `reports/GENESIS_FINAL_REPORT_2026-05-01.md` (the new report supersedes FINDINGS as the live source of truth).
- Updated `CURRENT_AUTHORITY_PACKET.md`, `proofs/artifacts/README.md`, `README.md`, `AUDITOR_PLAYBOOK.md` to reflect the 74-cell count, the closed-backend posture, the host-side-only remaining work, and the v2.0 outlook for Comparison #4 + alternative-pattern K2.
- Updated three pre-registered claim verdicts from "PENDING" to settled in authority artifacts. Comparison #4 verdict updated to STRUCTURAL INCLUSION CONFIRMED + NUMERICAL Z₂-PROJECTION DEFERRED with explicit pointer to the analytic disposition in the final report.
- Phone released for other experiments (per operator directive). v2.0 reactivation is a separate operator-visible decision; this repo at the v1.0 closure commit is the canonical reviewer surface.

---

## [0.1.1] — 2026-04-29

### Phase 3 prep — At-scale transient receipts, parity, and operational fix

- Rebased the Phase 3 prep receipts branch onto current `main`, preserving the computation-portfolio stakes paragraph, DM3 sibling-lane figure, and Genesis-DM3 RRL v1.0 license work already landed after PR #1.
- Fixed `harness/phone/thermal_coordinator.sh` after the live RM10 chain exposed a real hang condition: previous thermal-zone matching included dm3's cpu7/prime-cluster sensors (`cpu-1-*` / `cpuss-1-*`), so dm3-caused heat could SIGSTOP Genesis workers. The filter now counts only Genesis-relevant `cpu-0-*`, `cpuss-0-*`, and `gpuss-*` zones.
- Raised the Genesis-side thermal ceiling from 70 C to 80 C, added 3-poll debounce, added 15 s startup grace, and SIGCONT on thermal-kill exit to prevent workers remaining stuck in T state.
- Landed `BITDET_K2_S1_BIG`..`S9_BIG`: 9 cells × 600 K2 invocations each, all byte-identical (`unique_canonical_sha_count = 1`) with deterministic transient structure `5.5, 6.5, 4.0, 3.5, 4.0, 4.0, 3.0, 3.5, 3.5`.
- Landed `BITDET_K2_S30_BIG`: 6 instances × 200 iters = 1,200 K2 invocations at `--steps 30`, all byte-identical, `best_uplift = 3.000000`, `max_scar = 1.200000`.
- K2-task cross-platform parity now confirmed at S30: RM10 `BITDET_K2_S30_BIG` reproduces the same `k2_summary.json` SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372` as the M1 host Phase 1 BITDET run.
- Remaining Phase 3 prep receipt `BITDET_K2_S56_BIG` remains chain-operator scope and will be appended after completion/pull.

### Front-door alignment

- Updated README/FINDINGS/authority/auditor docs to reflect 70 PASS cells, at-scale S1..S9/S30 evidence, and K2-task parity confirmed at S30 without changing the settled comparison verdicts.
- Updated license references to `LicenseRef-Zer0pa-GDM3-RRL-1.0` after the repository license switched to Zer0pa Genesis-DM3 Research and Receipt License v1.0.

## [0.1.2] — 2026-04-30

### Phase 3 prep — Complete receipt surface + parity-sweep launch

- Landed `BITDET_K2_S56_BIG`: 6 instances × 50 iters = 300 K2 invocations at `--steps 56`, all byte-identical, `best_uplift = 3.000000`, `max_scar = 1.200000`, SHA `fccbdf3d776c1a77dd5e50486e9ddfb427bf11840b082cebbfa9115aa300e60d`.
- Phase 3 prep BIG program now complete in-repo: `BITDET_K2_S1_BIG`..`S9_BIG`, `S30_BIG`, `S56_BIG` = 6,900 additional byte-identical `k2_summary.json` hashes across the transient and steady-state regions.
- Strengthened the operational determinism claim: `BITDET_K2_S56_BIG` preserved `unique_canonical_sha_count = 1` across repeated thermal-cycle SIGSTOP/SIGCONT events at the heaviest steady-state point.
- Launched parity-sweep extension and landed `BITDET_K2_S20_PARITY`: 6 instances × 50 iters = 300 K2 invocations at `--steps 20`, all byte-identical, SHA `74fa0b8a7082b76370db8cf05f0baf520534e5def11edfccd698f26ad914e432`.
- Preserved honest scope on K2-task parity: still `CONFIRMED at S30`; S20 now has an RM10-side target SHA in-repo for the next host-side comparison, while broader multi-step coverage remains active engineering.

### Front-door alignment

- Updated README/FINDINGS/authority/auditor docs to reflect 72 PASS cells, complete Phase 3 prep BIG coverage through S56, the landed S20 parity receipt, and the live parity-sweep follow-on scope without changing the settled scientific verdicts.

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
- BITDET_5K receipts pulled and verified: 30,000 additional `verify.json` hashes, all source-canonical. BITDET_50K/500K were operator-trimmed in favor of K2 science cells; no claim is made from discarded partials.

### Phase 1 — K2 port (commit `c43a402`)

- Ported `exp_k2_scars` as 5th subcommand of `io_cli` (`crates/io_cli/src/k2_scars.rs`, 506 lines + main.rs updates).
- Algorithm: Hebbian scar weights (S += η · p_centered ⊗ p_centered on edge support); modified row-stochastic dynamics x_{t+1} = α·P_mod·x_t + (1−α)·p_noisy with α = 164/165; deterministic Bernoulli noise via SHA-256(cfg_hash ‖ lesson ‖ noise_idx ‖ pattern ‖ vertex); recall_err = Hamming distance after threshold at 1/2.
- All numeric work via `num_rational::BigRational`; no floating-point in math path. Workspace `#![deny(warnings)]` honoured.
- D₆-orbit analog pre-registered: 47 size-6 orbits = Bhupura analog (full D₆ stabilizer); 1 size-3 waist orbit = Lotus analog (mirror-fixed singular). Baked into `inputs/substrate_285v.json`.
- BITDET at K2 task level (M1 host): two consecutive `k2-scars --steps 30` runs produce byte-identical `artifacts/k2_summary.json` (SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`).
- Cross-compiled Phase 1 `snic_rust`; host SHA `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1`.
- Curious-number finding pre-registered for Phase 2: Genesis K2 at `--steps 30` yields uniform |scar| = 1.2 across all 567 edges + perfect recall (avg_recall_err = 0.0) + best_uplift = 3.0. Mathematical origin: rank-1 effect of disjoint Bhupura(282) + Lotus(3) outer products. Possible degenerate K2 dynamics; Phase 2 sweep will test whether value is constant (degenerate) or varies (real substrate effect).

### Phase 2 — Autonomous K2 sweep (complete)

- K2 sweep over `--steps ∈ {20, 28, 29, …, 56}` completed on RM10 via `genesis_chain_v1.sh`: 30 K2_SWEEP cells, all PASS, all `unique_canonical_sha_count = 1`.
- Cycle probe completed: 9 cells at multiples of 6/7/8, all PASS. S6=4.0 and S8=3.5 exposed a low-step pre-convergence transient; S12+ returned 3.0.
- σ″ curve is flat at `best_uplift = 3.000000` across [S20, S56]. K2_S49/K2_S50/K2_S51 all return 3.0, so Genesis does not reproduce dm3's exact-zero s50 cliff.
- Three pre-registered comparisons now have receipt-backed verdicts: cycle-7 attribution = AUGMENTATION-ATTRIBUTED; s50-cliff attribution = CONFIRMED; σ″-curve shape diff = CONFIRMED. D6-vs-C3 symmetry remains PENDING pending a Z2-asymmetric observable.

### Phase 2.5 — Pre-convergence sweep and K2 BITDET extension (complete)

- PRECONV sweep completed for S1..S5 and sparse S9..S25: S1=5.5, S2=6.5 peak, S3=4.0, S4=3.5, S5/S6=4.0, S8/S9=3.5, S10+=3.0.
- BITDET_K2_S6, BITDET_K2_S30, and BITDET_K2_S56 completed with `unique_canonical_sha_count = 1`, extending K2-task determinism at transient and steady-state points.
- `proofs/artifacts/sigma_curve_full.tsv`, `proofs/artifacts/figures/sigma_curve.png`, and `proofs/artifacts/figures/sigma_curve_summary.txt` added for repo-orchestrator inspection.

### Phase 3 prep — Live RM10 chain (in progress)

- Live manifest extends cross-time K2 evidence at S1..S9 plus S30/S56. Receipts will be pulled and appended by the chain-operator agent after completion.
- Final synthesis report remains pending.

---

## Open Workstreams

The following categories of work are active, open, or blocked. This section carries the honest-blocker posture required by the Zer0pa portfolio ethos.

### Infrastructure / unblocked

- Remaining Phase 3 prep receipt: `S56_BIG` pending live RM10 chain completion and pull by the chain-operator agent.
- `genesis_meta.txt` deploy convention: 5-line shell snippet to write `build_hash` + `target_triple` at adb-push time; not yet authored as a script.

### Blocked on external input

- Cross-lane D₆-vs-C₃ symmetry comparison: `dm3_runner` source recovery (separate `Zer0pa/DM3` workstream) must reach substrate characterisation before this comparison can be resolved.

### Open scientific questions

- Genesis K2 flat steady-state: whether uniform |scar| = 1.2 is a property of the D6/D3-orbit pattern choice or a property of the substrate itself. Alternative orbit picks are the next discriminator.
- Z2-asymmetric observable design for the remaining D6-vs-C3 symmetry comparison.

### Deferred

- dm3 task types beyond `exp_k2_scars` (11 task types): deferred per D2. No timeline until Phase 3 synthesis indicates value.
- GPU/multi-device scaling: not in scope for this experiment.
