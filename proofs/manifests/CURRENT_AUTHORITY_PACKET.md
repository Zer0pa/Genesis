# Current Authority Packet

**Authority commit:** `da7890e` (tag `v1.0.0`) — v1.0 closure merge to `main`
**Date:** 2026-05-01
**Status:** backend chain CLOSED — Phase 0, Phase 2, Phase 2.5, Phase 3 prep BIG, and Phase 3 parity-sweep extension all complete and in-repo. 74 cells / 74 PASS / `unique_canonical_sha_count = 1` per cell. RM10 chain master exited cleanly (`genesis_chain_v1 finished all manifest cells`); phone is being released to other experiments. Phase 3 synthesis and the analytic D6-vs-C3 disposition are landed in `reports/GENESIS_FINAL_REPORT_2026-05-01.md`.

---

## Substrate identity

| Property | Value |
|----------|-------|
| Topological type | T(3,21) torus link embedded on T² |
| Symmetry group | D₆ (= S₃ × Z₂) |
| Vertex count | 285 |
| Edge count | 567 |
| D₆ orbit count | 48 |
| Orbit sizes | 47 size-6 orbits (Bhupura analog: full D₆ stabilizer) + 1 size-3 waist orbit (Lotus analog: mirror-fixed singular) |
| Number field | Q-Pythagorean (edge weights rational; all coordinates over Q; closed under Pythagorean extensions) |
| Substrate file | `inputs/substrate_285v.json` |
| Settled by | `substrate-reconstruction-2026-04-26` lane (separate workstream; identity confirmed 2026-04-26) |

This substrate is distinct from the `dm3_runner` substrate (380 vertices, C₃ symmetry, source unrecovered). Cross-lane comparisons must be explicitly framed per `LANE_DISTINCTION.md`.

---

## Binary SHAs

| Phase | Binary | SHA-256 |
|-------|--------|---------|
| 0 | `snic_rust` (aarch64-linux-android; 4 subcommands: build-2d, lift-3d, solve-h2, verify) | `7abbf04a6656ef9f70d713e2fd8df1dafbb392a36ef75e6e8d74ea844922ac57` |
| 1 | `snic_rust` (aarch64-linux-android; 5 subcommands incl. k2-scars) | `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1` |

Source workspace hash prefix: `a83f39e6` (`snic_workspace_a83f/`).

---

## Canonical output hashes

| Output | SHA-256 | Subcommand |
|--------|---------|------------|
| `artifacts/verify.json` | `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89` | `verify` |
| `artifacts/solve_h2.json` | `62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780` | `solve-h2` |
| `artifacts/k2_summary.json` (Phase 1, --steps 30, M1 host) | `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372` | `k2-scars` |

These are source-hardcoded (`CANONICAL_VERIFY_HASH`, `CANONICAL_SOLVE_HASH` in `genesis_cli/src/main.rs`) and cross-verified against on-device pipeline output. Any deviation from `verify.json` or `solve_h2.json` above must halt the chain; see `REPRODUCIBILITY.md` for the BENIGN-diagnosis scope and stop conditions.

---

## Receipt surface

| Surface | Count / path | Verdict |
|---------|--------------|---------|
| Phase 0 BITDET | BITDET_01, BITDET_02, BITDET_03, BITDET_5K = 31,560 `verify.json` hashes | PASS, `unique_canonical_sha_count = 1` per cell |
| Phase 2 K2_SWEEP | 30 cells: S20 and S28..S56 | PASS, `best_uplift = 3.000000` at every step |
| Phase 2 CYCLE-probe | 9 cells at multiples of 6/7/8 | PASS; S6=4.0, S8=3.5, S12+ = 3.0 |
| Phase 2.5 PRECONV | 14 cells: S1..S5, S9, S10, S11, S13, S15, S17, S19, S22, S25 | PASS; transient peak S2 = 6.5; settled by S10 |
| Phase 2.5 BITDET_K2 | S6, S30, S56 | PASS, `unique_canonical_sha_count = 1` per cell |
| Phase 3 prep transient-at-scale | `BITDET_K2_S1_BIG`..`S9_BIG`: 9 cells × 600 K2 invocations | PASS, `unique_canonical_sha_count = 1`; deterministic transient = `5.5, 6.5, 4.0, 3.5, 4.0, 4.0, 3.0, 3.5, 3.5` |
| Phase 3 prep steady-state-at-scale | `BITDET_K2_S30_BIG`: 6 instances × 200 iters = 1,200 K2 invocations at S30 | PASS, `unique_canonical_sha_count = 1`; `best_uplift = 3.000000`; SHA = `0b5442f9…` |
| Phase 3 prep far-end steady-state-at-scale | `BITDET_K2_S56_BIG`: 6 instances × 50 iters = 300 K2 invocations at S56 | PASS, `unique_canonical_sha_count = 1`; `best_uplift = 3.000000`; SHA = `fccbdf3d…` |
| Phase 3 parity-sweep | `BITDET_K2_S20_PARITY` (S20, 300 K2 invocations) + `BITDET_K2_S40_PARITY` (S40, 300 K2 invocations) + `BITDET_K2_S50_PARITY` (S50, 300 K2 invocations) | PASS, `unique_canonical_sha_count = 1` per cell; `best_uplift = 3.000000` per cell; SHAs `74fa0b8a…` (S20), `38be38e2…` (S40), `f5cd3876…` (S50) — three RM10-side host-comparison anchors |
| Total in-repo cells | `proofs/artifacts/cells/` = 74 cells | 74 PASS / 0 FAIL |
| Aggregated curve | `proofs/artifacts/sigma_curve_full.tsv` | 75-line table including header |
| Figure | `proofs/artifacts/figures/sigma_curve.png` | 2-panel headline figure |

Backend chain is closed; no further phone-side scope is queued. The three RM10 parity anchors at S20/S40/S50 are now committed targets for any future host-side M1 byte-comparison (host-only work; does not require phone time).

---

## Claims

| ID | Claim | Status |
|----|-------|--------|
| BITDET | Every iteration of every instance produces byte-identical `verify.json` (Phase 0) or `k2_summary.json` (Phase 1+) within each cell — `unique_canonical_sha_count = 1` per cell | PASS — 31,560 Phase 0 hashes plus 56 Phase 2/2.5 K2-task cells plus 6,900 Phase 3 prep BIG K2 invocations plus 900 parity-sweep K2 invocations (S20+S40+S50) now in-repo, all per-cell unique count = 1 |
| PARITY | Cross-platform (M1 host ↔ RM10 aarch64-android) produces identical canonical output given identical binary and config | PASS at canonical-pipeline level — `solve_h2.json = 62897b…`; on-device `verify.json = 97bd7d…` matches source-canonical exactly. K2-task parity CONFIRMED at S30 via `k2_summary.json = 0b5442f9…`. RM10 parity targets now in-repo at S20 (`74fa0b8a…`), S40 (`38be38e2…`), S50 (`f5cd3876…`); host-side byte comparison at these step values is the remaining widen-coverage work — host-only, no phone time required |
| CYCLE7 | Genesis K2 dynamics exhibit a period-7 cycle observable (pre-registered cross-lane comparison) | AUGMENTATION-ATTRIBUTED — no period-7 structure in Genesis steady-state K2; S20/S28..S56 all 3.0 and cycle probes S12+ all 3.0 |
| S50-CLIFF | Genesis K2 shows a discontinuity or cliff at step 50 analogous to dm3_runner's s50 observable (pre-registered cross-lane comparison) | CONFIRMED negative — Genesis does NOT cliff at S50; S49/S50/S51 all 3.0 |
| SIGMA-CURVE | Genesis σ″ curve differs from dm3_runner's trimodal sawtooth (pre-registered cross-lane comparison) | CONFIRMED — Genesis flat at 3.0 across [S20,S56]; dm3 sawtooth/cliff fixture differs |
| D6-VS-C3 | Genesis D6 symmetry produces structurally distinct K2 dynamics from dm3_runner C3 symmetry (pre-registered cross-lane comparison) | PENDING — analytic disposition landed in `reports/GENESIS_FINAL_REPORT_2026-05-01.md` §"Comparison #4". Direct numerical Z₂-projection observable would require a Z₂-asymmetric pattern (a new chain run); the operator-approved D3 pattern map is exactly Z₂-invariant by construction so cannot break Z₂ symmetry. Disposition: STRUCTURAL INCLUSION CONFIRMED (D₆ ⊃ C₃ by construction; flat σ″ + no s50 cliff are numerical signatures consistent with higher symmetry); NUMERICAL Z₂-PROJECTION DEFERRED to v2.0 alternative-pattern work, no phone-side scope queued |

---

## Operational note

The Phase 3 prep branch includes the thermal-coordinator root-cause fix for the 2026-04-28 chain hang. Genesis now filters only Genesis-relevant `cpu-0-*`, `cpuss-0-*`, and `gpuss-*` thermal zones, excluding dm3's hot `cpu-1-*` / `cpuss-1-*` prime cluster; uses an 80 C ceiling; requires 3 consecutive over-threshold polls; waits through a 15 s startup grace period; and issues SIGCONT before thermal-kill exit so workers do not remain in T state.
