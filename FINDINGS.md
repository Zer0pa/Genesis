# Findings — Genesis Comparative Experiment

*Authoritative records: [`.gpd/STATE.md`](.gpd/STATE.md), [`project_contract.json`](project_contract.json), [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md). This file is the narrative reading of those records as of 2026-04-28; it evolves with each phase.*

---

## Current Status (as of 2026-04-28)

Phase 0 is complete on RM10: cross-compiled `snic_rust` deploys produce source-canonical `verify.json` and `solve_h2.json` byte-exact, with cross-iter byte-identity confirmed in cells BITDET_01/02/03 (1 560 cross-checked `verify.json` hashes; long-running BITDET_5K / BITDET_50K / BITDET_500K cells in flight, receipts pending pull). Phase 1 K2 port lands on the M1 host with byte-identical `k2_summary.json` across two consecutive runs and gives `best_uplift = 3.000000` at `--steps 30`. Phase 2 K2_SWEEP (`--steps ∈ {20, 28..56}`, N=3 per step) is running autonomously on RM10; live observation confirms cells K2_S20 and K2_S28 PASS with `best_uplift = 3.000000` and K2-task BITDET. Phase 3 synthesis is pending Phase 2 receipts.

The four pre-registered comparisons (`claim-cycle7-attribution`, `claim-s50cliff-augmentation`, `claim-sigma-curve-diff`, `claim-symmetry-D6vsC3`) carry one EARLY-SIGNAL verdict (σ″-curve-shape diff) and three PENDING (cycle-7, s50-cliff, symmetry). EARLY-SIGNAL is treated as live, not settled.

---

## Phase 0 — Determinism Foundation

The core scientific claim of Phase 0 is byte-identical canonical output across hardware, thermal range, time, and re-execution on commodity Android. Concrete evidence:

### 1. Source-canonical match

The Genesis source workspace hardcodes:

```
CANONICAL_VERIFY_HASH = 97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89
CANONICAL_SOLVE_HASH  = 62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780
```

as the substrate's reproducible reference (in `crates/genesis_cli/src/main.rs`). The cross-compiled `snic_rust` binary on RM10 (Android 14, Snapdragon 8 Elite Gen 4, `FY25013101C8`) reproduces both hashes byte-exact via the 4-step pipeline `build-2d → lift-3d → solve-h2 → verify` reading `configs/CONFIG.json`. No BENIGN-diagnosis disposition is required on the device side; the [D1 BENIGN diagnosis](harness/host/HASH_GATE_DISPOSITION.md) covers only the M1-side `genesis_cli` wrapper's serialization-layer trailing-newline diff, not the `snic_rust` direct pipeline. Source: [`.gpd/STATE.md`](.gpd/STATE.md) plan 00-06.

### 2. Cross-iter byte-identity (cell-internal BITDET)

Per-instance, the `snic_rust` pipeline runs `N` times per cell (`--test-battery N` semantics implemented as a pipeline-loop wrapper in [`harness/phone/run_genesis_cell.sh`](harness/phone/run_genesis_cell.sh)). Every iter produces `verify.json` whose SHA-256 equals `97bd7d…`. No drift across iters.

Cells confirmed PASS (per [`.gpd/STATE.md`](.gpd/STATE.md) plan 00-07):

| Cell | Iters per instance | Instances (cores) | Total runs | Unique canonical SHA | Verdict |
|---|---|---|---|---|---|
| BITDET_01 | 10 | 6 | 60 | 1 (= `97bd7d…`) | PASS |
| BITDET_02 | 50 | 6 | 300 | 1 (= `97bd7d…`) | PASS |
| BITDET_03 | 200 | 6 | 1 200 | 1 (= `97bd7d…`) | PASS |
| **Total settled (in-repo)** | | | **1 560** | **1** | **PASS** |

In flight, receipts pending pull on RM10 reconnect:

| Cell | Iters per instance | Instances (cores) | Total runs (projected) | Status |
|---|---|---|---|---|
| BITDET_5K | 5 000 | 6 | 30 000 | Live PASS in chain log; receipts on phone, pending pull |
| BITDET_50K | 50 000 | 6 | 300 000 | Operator-trimmed (replaced by K2_SWEEP); 14 500 iters/instance partial discarded on chain restart |
| BITDET_500K | 500 000 | 6 | 3 000 000 | Operator-trimmed (replaced by K2_SWEEP) |

**Settled count is 1 560 cross-replicate canonical-hash matches with zero divergence.** BITDET_5K extends to 30 000 once receipts are pulled and verified; BITDET_50K/500K were operator-trimmed mid-session (per CHANGELOG) to advance to Phase 2 K2 cells. Operating envelope across the settled cells: 44–60 °C thermal range, kernel scheduler distributing 6 instances across an active subset of cpu0–6 dynamically (Qualcomm `core_ctl` pauses 1–2 cores at any moment), cell wall-clock spanning minutes.

### 3. Cross-platform parity (claim τ at the canonical-pipeline level)

The M1 host build of `snic_rust` (native `aarch64-apple-darwin`) and the RM10 cross-compiled build (`aarch64-linux-android`) produce the same `solve_h2.json = 62897b…` byte-exact. The M1-side `verify.json` reaches the BENIGN-disposition state `e8941414…` (full-hash captured in [`HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md)) — diagnosed as a serialization-layer trailing-newline diff from `refresh_receipts` post-processing in the `genesis_cli` wrapper; `VERIFY_SUMMARY.json` (the actual computation gate) reproduces identically at `8ddb…`; all 7 internal gates pass; `solve_h2.json` matches the source-hardcoded canonical exactly. This is the [D1 disposition](.gpd/STATE.md), operator-default-approved.

Implication: the substrate's deterministic computation is invariant under platform — what is encoded in the source IS the answer; the binary execution on different CPUs reproduces it byte-identical at the `solve-h2` gate.

### 4. All 7 internal verification gates pass

`verify.json.gate_summary` on every Phase 0 invocation reports:

```
gates_ok            = true
dep_cert_present    = true
gc_invariants_pass  = true
lift_pass           = true
stab_pass           = true
cad_sos_present     = true
egraph_proof_valid  = true
```

These are the substrate's own self-checks (defined in `proof_gates::run_sidecars` and reported by `crates/io_cli/src/main.rs:147–221`).

---

## Phase 1 — K2 Protocol Port (Host)

K2 is implemented as the 5th subcommand of `io_cli` (binary `snic_rust`). The protocol structure mirrors dm3's `exp_k2_scars` algorithmically — 2 lesson levels × 2 noise levels × 2 patterns × 1 invocation per `--steps` value — but is built from scratch on the 285-vertex D₆ Genesis substrate. Implementation details:

- Module: `crates/io_cli/src/k2_scars.rs` (506 lines)
- Dispatch: `crates/io_cli/src/main.rs` K2Scars enum variant + handler (+75 lines)
- Numerics: all math via `num_rational::BigRational` (no f32/f64 in math path; floats only for `printf`); workspace `#![deny(warnings)]` honored. POLICY_CHECK pass.
- Algorithm specification: see [`docs/K2_PROTOCOL.md`](docs/K2_PROTOCOL.md).

### K2 task BITDET (M1 host)

Two consecutive `k2-scars --steps 30` runs on the M1 host produce byte-identical `artifacts/k2_summary.json`:

```
SHA-256: 0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372
```

This establishes K2 task BITDET at the host level. Cross-platform parity at the K2-task level (M1 vs RM10 byte-comparison of `k2_summary.json`) is `Active Engineering` per [README §Upcoming Workstreams](README.md).

### Cross-compile to RM10

Phase 1 `snic_rust` (with K2 dispatch) cross-compiled clean to `aarch64-linux-android`. New host SHA replaces Phase 0 binary on phone redeploy:

| Phase | Binary | Host SHA-256 |
|---|---|---|
| 0 | `snic_rust` (4 subcommands) | `7abbf04a6656ef9f70d713e2fd8df1dafbb392a36ef75e6e8d74ea844922ac57` |
| 1 | `snic_rust` (5 subcommands incl. `k2-scars`) | `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1` |

Source workspace seal prefix: `a83f39e6`.

Pipeline canonical hashes preserved exactly across binary upgrade (host-verified before RM10 swap): both `verify.json = 97bd7d…` and `solve_h2.json = 62897b…` continue to reproduce on the upgraded binary.

---

## Phase 1 Curious-Numbers Finding

Genesis K2 at `--steps 30` with the operator-approved D3 pattern choice (47 size-6 orbits = Bhupura analog, 1 size-3 waist = Lotus analog) produces:

```
KPI_K2_SCAR_WEIGHTS lessons=3 max_abs_delta=1.200000000e0 mean_abs_delta=1.200000000e0 changed_edges=567 total_edges=567
KPI_K2 lesson=3 noise=0.100 avg_recall_err=0.000000 baseline_recall_err=3.000000 uplift=3.000000 scar_max=1.200000
KPI_K2 lesson=3 noise=0.200 avg_recall_err=0.000000 baseline_recall_err=3.000000 uplift=3.000000 scar_max=1.200000
KPI_K2_SUMMARY duration_sec=4.770 max_scar_weight=1.200000 best_uplift=3.000000
```

— uniform `|scar| = 1.2` across all 567 edges, perfect recall (`avg_recall_err = 0.0`), `best_uplift = 3.0`.

The dm3 K2 fixture at `--steps 30` on its 380v C₃ substrate (per [`dm3_parallel/binaries/sample_full_run_s30.log`](../dm3_parallel/binaries/sample_full_run_s30.log) in the parent DM3 tree):

| Metric | Genesis (285v D₆) | dm3 (380v C₃) |
|---|---|---|
| `max_scar_weight` (L=3) | 1.200000 | 0.868061 |
| `mean_abs_delta` (L=3) | 1.200000 (= max; uniform) | 0.082980 (≪ max; varied) |
| `changed_edges` (L=3) | 567 of 567 (100%) | 1 892 of 4 560 (~41%) |
| `baseline_recall_err` (noise=0.1) | 3.000000 | 103.161766 |
| `avg_recall_err` (L=3, noise=0.1) | 0.000000 | 101.517242 |
| `best_uplift` | 3.000000 | 1.644524 |

### Mathematical origin of the uniform scar

The scar accumulation `S[edge_idx] += η · p_centered[i] · p_centered[j]` over both centered patterns + L lessons reduces to summing `±1` contributions per edge, where the sign depends on the joint class of vertices `(i, j)`:

| Edge class (pattern membership) | `p_B[i]·p_B[j]` | `p_L[i]·p_L[j]` | Total contribution per (lesson, both patterns) |
|---|---|---|---|
| BB (both vertices in Bhupura) | +1 | +1 | +2 · η |
| LL (both vertices in Lotus) | +1 | +1 | +2 · η |
| BL (one Bhupura, one Lotus) | −1 | −1 | −2 · η |

After `L = 3` lessons: every edge sees `|S[edge]| = 3 · 2 · η = 6/5 = 1.2`, **independent of class**. The sign of `S[edge]` differs by class (BB and LL get +1.2, BL gets −1.2), but the magnitude is uniform across all 567 edges.

The dynamics with the resulting `P_mod` then has a strong rank-1-style attractor; with α = 164/165 driving the consensus and noise rates < 50%, the recall converges to perfect under threshold rounding at `1/2` for both patterns at both noise levels.

### Two readings, with the discriminator named

**(a) Substrate-real reading.** The D₆ symmetry of the Genesis substrate, combined with the operator-approved D3 pattern map, yields exactly the structural attractor needed for perfect recall on K2 input. Genesis is "easier" for K2 than the dm3 substrate (which has C₃ + a larger graph + a different pattern derivation). This is substrate-attribution evidence.

**(b) Pattern-degenerate reading.** The choice Bhupura ∪ Lotus = full vertex set (disjoint indicator vectors with cardinalities 282 and 3) forces rank-1 dynamics. Alternative pattern choices — for instance, picking two disjoint size-6 orbits as Bhupura and Lotus (both small, both sparse, neither covering the full graph) — would give non-rank-1 scar matrices with class-dependent magnitudes, and likely richer dynamics. The result is degenerate K2 dynamics for the cross-lane comparison purpose.

**Discriminator (Phase 2):** if `best_uplift` is constant at `3.000000` across all 30 step values in K2_SWEEP, the dynamics under D3 is degenerate (no cycle, no cliff, no curve shape — the trivial answer). If `best_uplift` varies with `--steps`, the substrate has real dynamics structure that the comparison can read.

This finding is honestly framed as PRE-PHASE-2 information: a result requiring confirmation, not a settled scientific claim. Both Phase 2 outcomes are publishable and pre-registered.

---

## Phase 2 — Autonomous K2 Sweep (Running on RM10)

Manifest: 30 K2_SWEEP cells (`--steps ∈ {20, 28, 29, …, 56}`) plus 9 cycle-probe cells (multiples of 7, 6, 8 disambiguator). Each cell: 6 instances × 3 iters × 8 inner pipelines = 144 K2 task invocations per cell. 39 cells total in the chain manifest.

Live observations (pre-disconnect, from the chain log):

| Cell | `--steps` | `best_uplift` | K2 task BITDET (per cell) | Verdict |
|---|---|---|---|---|
| K2_S20 | 20 | 3.000000 | 18 byte-identical `k2_summary.json` SHAs (3 iters × 6 instances) | PASS |
| K2_S28 | 28 | 3.000000 | 18 byte-identical `k2_summary.json` SHAs | PASS |

Phase 2 currently running offline (operator unplugged for autonomous execution). On reconnect, receipts pull to `proofs/artifacts/cells/K2_*/`.

**The two live observations are consistent with the degenerate-K2 reading.** They are not yet sufficient to settle Phase 2 — the discriminator is the full curve over all 30 step values, including specifically the s49 / s50 / s51 neighborhood and the cycle-multiple step values.

---

## Phase 3 — Synthesis (Pending)

Phase 3 reads Phase 2 receipts, plots the σ″-curve over `--steps` (`best_uplift` y-axis, `--steps` x-axis), runs the four acceptance tests, and produces a final report at `reports/GENESIS_FINAL_REPORT_<DATE>.md` per [PRD §Deliverables](PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md). The Genesis-side appendix carries the four pre-registered comparison verdicts numerically; cross-lane editorial happens downstream and is not in scope for this lane (per [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md)).

The σ″-curve shape determines all four pre-registered comparison outcomes — see [§What This Means for the Four Pre-Registered Comparisons](#what-this-means-for-the-four-pre-registered-comparisons) below.

---

## What's Settled

- **Substrate identity.** T(3,21) torus link on T², D₆ = S₃ × Z₂ symmetry, 285 vertices, 567 edges, 48 D₆ orbits (47 size-6 + 1 size-3 waist), Q over Pythagorean rationals. Settled by `substrate-reconstruction-2026-04-26` lane (read-only authority for this lane). Source: [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md) and [`README.md`](README.md).
- **Cross-platform parity at canonical-pipeline level.** M1 ↔ RM10 byte-exact at `solve_h2.json = 62897b…`; M1-side `verify.json` BENIGN-diagnosed at `e8941414…` per D1; RM10-side `verify.json = 97bd7d…` byte-exact to source-hardcoded canonical.
- **Hardware/thermal/time invariance at small-to-moderate scale.** 1 560 cross-replicate canonical-hash matches across BITDET_01 (60 runs), BITDET_02 (300 runs), BITDET_03 (1 200 runs); zero divergence; `unique_canonical_sha_count = 1` per cell. Operating envelope: 44–60 °C thermal range; dynamic CPU subset under `core_ctl`.
- **All 7 internal verification gates pass** on every Phase 0 invocation.
- **K2 task BITDET on M1 host.** Two-run identity at `k2_summary.json = 0b5442f9…`.
- **K2 task BITDET on RM10 (per-cell, live observation).** Cells K2_S20 and K2_S28 confirmed (18 byte-identical `k2_summary.json` SHAs each). Full-cell receipts pending pull.
- **Phase 1 K2 implementation source-clean.** All math via BigRational; no f32/f64 in math path; workspace `#![deny(warnings)]`; POLICY_CHECK pass; cross-compile clean to RM10.

## What's EARLY-SIGNAL

- **Genesis K2 produces uniform `|scar| = 1.2` + perfect recall + `best_uplift = 3.0`** on the operator-approved D3 pattern choice at `--steps 30` (M1 host); same `best_uplift = 3.0` confirmed at K2_S20 and K2_S28 on RM10 (live observations from Phase 2). If this constancy holds across the full Phase 2 sweep, it answers all four pre-registered comparisons with one structural signature: Genesis K2 has no cycle, no cliff, flat σ″ at 3.0; differs structurally from dm3's trimodal sawtooth with cliff at s50.
- The two live Phase 2 observations are consistent with this prediction but are not yet sufficient to settle the verdict (the curve's discriminating points — s49, s50, s51, multiples of 7, multiples of 6 — have not yet returned receipts).

## What's Pending

- **Phase 2 K2_SWEEP receipts.** Chain running autonomously on RM10; pull on reconnect to `proofs/artifacts/cells/K2_*/`.
- **Phase 2 CYCLE-probe receipts.** Multiples of 7, 6, 8 disambiguator cells; pull on reconnect.
- **Phase 3 synthesis.** σ″-curve plot, acceptance-test results, four pre-registered comparison verdicts, final report.
- **Phase 4+ alternative-pattern K2.** Conditional on Phase 2 confirming the degeneracy reading: pre-registered alternative orbit pairings (e.g., partitioning the 47 size-6 orbits differently, or using non-disjoint pattern supports) become the second-pass design.
- **Cross-platform parity at K2-task level.** M1 vs RM10 explicit byte-comparison of `k2_summary.json` after RM10 K2 receipts pull.
- **Z₂-asymmetric observable for the SYMMETRY pre-registered comparison.** Not yet designed; required before Phase 2 SYMMETRY cell can run.
- **In-flight long BITDET cell** (BITDET_5K = 30 000 projected). Live PASS in chain log; receipts pending pull; will extend the cross-replicate proof surface once verified in `proofs/artifacts/`.

---

## What This Means for the Four Pre-Registered Comparisons

| # | Comparison | Current verdict | Anchor / discriminator |
|---|---|---|---|
| 1 | **Cycle-7 attribution** (`claim-cycle7-attribution`) | **PENDING** | Phase 2 K2_SWEEP receipts (Lomb-Scargle on 30-point series) + CYCLE-probe receipts (multiples of 7 vs 6 vs 8). If σ″ is flat at 3.0, cycle period is undefined → AUGMENTATION_ATTRIBUTED (no period 7 to be substrate-attributed); if σ″ varies, Lomb-Scargle 95% CI determines the verdict. |
| 2 | **s50-cliff attribution** (`claim-s50cliff-augmentation`) | **PENDING** | Phase 2 K2_SWEEP receipts at s49/s50/s51 (N=3 each); N=10 boundary drill if any sharp drop. If `best_uplift @ s50 > 0.000100` → AUGMENTATION_ATTRIBUTED (operator's positive prediction confirmed); if `best_uplift @ s50 ≤ 0.000100` → SUBSTRATE_CLASS (prediction wrong). Live signal: K2_S20 and K2_S28 both at 3.0 — if pattern holds at s50, prediction confirmed. |
| 3 | **σ″-curve shape diff** (`claim-sigma-curve-diff`) | **EARLY-SIGNAL** | Per-step diff table emitted with all 30 step values; SIGNIFICANT_DIFF flag where Genesis 95% CI does not overlap dm3 fixture. Live signal: Genesis at 3.0 constant on K2_S20/K2_S28; dm3 varies between 1.16 and 1.97 over s30-s56; curves structurally differ. |
| 4 | **D₆-vs-C₃ symmetry** (`claim-symmetry-D6vsC3`) | **PENDING** | Phase 2 SYMMETRY cell — requires explicit Z₂-asymmetric observable design (not yet implemented). Monte Carlo baseline mandatory per `fp-noisefloor`. |

The EARLY-SIGNAL on comparison #3 is a curious-numbers finding, not a settled verdict. Phase 2 K2_SWEEP across `--steps ∈ {20, 28..56}` is the primary discriminator: either `best_uplift` remains constant at 3.0 (degenerate; one structural signature answers all four) or it varies (curve-by-curve analysis required).

---

## What This Means Commercially

The proof-surface-driven wedge: Genesis demonstrates that **pure-rational deterministic computation is feasible for non-trivial systems** — associative memory, scar-weight learning, dynamics on a 285-vertex graph with non-trivial automorphism structure, on commodity Android hardware. The 1 560 cross-replicate canonical-hash matches at BITDET_01..03 prove byte-identity as a structural property of the discipline, not as an aspirational target. The cross-platform parity at `solve_h2.json` proves the result is encoded in the source, not in any platform's IEEE-754 quirks.

For the Zer0pa portfolio: this validates the discipline (rational arithmetic + POLICY_CHECK + canonical-hash gates) as a viable route to deterministic-by-construction computation. Each portfolio lane that adopts the discipline inherits the property. Each lane's mathematical content (whatever the substrate) becomes the IP — the encoding becomes a proof artifact.

This is "always-in-beta" per the Zer0pa Live Project Ethos: Phase 0 alone is shippable as a determinism reference; Phase 2/3 finishes the comparative-experiment narrative; future phases (alternative patterns, K2 task BITDET at scale, K2 cross-platform parity, Z₂-asymmetric SYMMETRY observable) extend the proof surface.

The honest framing: Genesis is **one research artifact in the Zer0pa portfolio**, not a productized service or a unified platform. The four pre-registered comparisons are scoped to the Genesis lane; cross-lane editorializing about portfolio significance is downstream work, out of scope here per [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md).

---

## What Could Falsify the Determinism Claim

Any single receipt with `canonical_sha != 97bd7d…` (Phase 0) breaks the determinism claim — not just for that cell but as a whole. Aggregate across the chain: any cell with `unique_canonical_sha_count > 1` is a substantive finding to interrogate; any cell with `verdict != PASS` halts the chain pending operator-visible disposition (per the chain harness's stop-on-out-of-family-mismatch protocol — see [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md)).

Phase 2 K2 task BITDET: any single iter of any single instance producing `k2_summary.json` SHA different from the others within the same cell breaks K2 task BITDET. Phase 0 has zero such breaches in 1 560 settled hashes. Phase 2 has zero in K2_S20 + K2_S28 live observations (18 byte-identical SHAs per cell).

The in-flight long BITDET cell (BITDET_5K) extends the proof surface; if it returns a divergent hash on receipt pull, the Phase 0 determinism claim is partially falsified at the affected scale and a substantive finding is filed.

---

## What Could Falsify the Substrate-Attribution Reading

If Phase 2 K2_SWEEP shows `best_uplift` VARYING across `--steps` (i.e., the curve is NOT flat at 3.0), then the substrate-attribution reading "Genesis K2 dynamics is structurally trivial under D3 pattern choice" is wrong — there is real dynamics structure on the substrate, and the cycle-7 / s50-cliff / σ″-shape comparisons must be evaluated on the actual curve, not on the constant-3.0 hypothesis.

If Phase 2 K2_SWEEP shows `best_uplift` CONSTANT at 3.0 across all 30 step values, then under the operator-approved D3 pattern choice the Genesis K2 dynamics is degenerate; alternative pattern choices (pre-registered as `Research-Deferred — Investigation Underway` per [README §Upcoming Workstreams](README.md)) become the next investigation surface to find non-trivial dynamics on the same substrate.

Either outcome is publishable. The falsification surface is well-defined per acceptance tests `test-cycle7-lomb-scargle`, `test-cycle7-disambiguator`, `test-s50-cliff-genesis`, `test-s50-cliff-N10`, `test-sigma-curve-diff-table`, `test-symmetry-Z2-probe` ([`project_contract.json`](project_contract.json)).

---

## Next Receipts to Watch

In order of decision-relevance:

1. **K2_SWEEP cells K2_S29..K2_S56** — do they all return `best_uplift = 3.0`? (Discriminates degenerate vs varied.)
2. **K2_SWEEP cell K2_S50 specifically** — does Genesis cliff at s50? (Direct test of `claim-s50cliff-augmentation`.)
3. **CYCLE-probe cells** — do period-7 multiples cluster differently from period-6 or period-8 multiples? (Direct test of `claim-cycle7-attribution`.)
4. **Long BITDET cell BITDET_5K** — receipts pull confirms `unique_canonical_sha_count = 1` over 30 000 invocations? (Extends the determinism proof surface to the 30K-replicate scale beyond the 1 560 settled.)
5. **K2 task cross-platform parity (M1 vs RM10)** — once RM10 K2 receipts are pulled, byte-compare the `k2_summary.json` SHAs at matching `--steps` values. (Extends `claim-parity` to the K2 task level.)

On phone reconnect, this document is updated with the actual receipt numbers and the four pre-registered comparison verdicts move from PENDING / EARLY-SIGNAL toward CONFIRMED / FALSIFIED / INCONCLUSIVE per the acceptance-test outcomes.
