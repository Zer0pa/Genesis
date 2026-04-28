# Current Authority Packet

**Authority commit:** `c43a402` (head of `main` at branch-cut; `inspection-2026-04-28` branched from here)
**Date:** 2026-04-28
**Status:** provisional — Phase 2 sweep receipts pending RM10 reconnect

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

## Claims

| ID | Claim | Status |
|----|-------|--------|
| BITDET | Every iteration of every instance produces byte-identical `verify.json` (Phase 0) or `k2_summary.json` (Phase 1+) — `unique_canonical_sha_count = 1` per cell | PASS — 1 560 cross-checked hashes (BITDET_01, 02, 03); long-running cells in flight |
| PARITY | Cross-platform (M1 host ↔ RM10 aarch64-android) produces identical canonical output given identical binary and config | PASS — on-device `97bd7d…` matches source-canonical exactly (D1 BENIGN disposition applies to M1 genesis_cli wrapper only, not to `snic_rust` pipeline) |
| CYCLE7 | Genesis K2 dynamics exhibit a period-7 cycle observable (pre-registered cross-lane comparison) | UNTESTED — Phase 2 sweep pending |
| S50-CLIFF | Genesis K2 shows a discontinuity or cliff at step 50 analogous to dm3_runner's s50 observable (pre-registered cross-lane comparison) | UNTESTED — Phase 2 sweep pending |
| SIGMA-CURVE | Genesis σ″ curve differs from dm3_runner's trimodal sawtooth (pre-registered cross-lane comparison) | UNTESTED — Phase 2 sweep pending |
| D6-VS-C3 | Genesis D₆ symmetry produces structurally distinct K2 dynamics from dm3_runner C₃ symmetry (pre-registered cross-lane comparison) | UNTESTED — dm3_runner substrate characterisation also pending |
