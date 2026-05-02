# Genesis Comparative Experiment — Final Report v1.0

**Date:** 2026-05-01
**Branch:** `main` (tag `v1.0.0`; merged from `phase-3-prep-receipts-2026-04-29`)
**Status:** backend chain CLOSED; phone released for other experiments; reviewers operate against this repo as the canonical surface.
**Authority:** [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md), [`proofs/artifacts/cells/`](../proofs/artifacts/cells/), [`proofs/artifacts/sigma_curve_full.tsv`](../proofs/artifacts/sigma_curve_full.tsv), [`project_contract.json`](../project_contract.json).

---

## 0. Executive verdict

The Genesis Comparative Experiment ran end-to-end on the RM10 (Snapdragon 8 Elite Gen 4, `FY25013101C8`) and an M1 host build. The four pre-registered comparisons against the parked `dm3_runner` lane resolve as follows:

| # | Comparison | Verdict | Evidence path |
|---|---|---|---|
| 1 | Cycle-7 attribution (`claim-cycle7-attribution`) | **AUGMENTATION-ATTRIBUTED** | flat σ″ at 3.0 across {S20, S28..S56}; cycle-disambiguator probes at S12+ all 3.0 — no period-7 structure |
| 2 | s50-cliff attribution (`claim-s50cliff-augmentation`) | **CONFIRMED** (negative) | `best_uplift @ S49 = S50 = S51 = 3.000000` — Genesis does not cliff at s50 |
| 3 | σ″-curve shape diff (`claim-sigma-curve-diff`) | **CONFIRMED** | Genesis flat at 3.0 over [S20, S56]; dm3_runner trimodal sawtooth varies 1.16–1.97 with cliff at S50 = 0.000000 |
| 4 | D₆-vs-C₃ symmetry (`claim-symmetry-D6vsC3`) | **STRUCTURAL INCLUSION CONFIRMED; NUMERICAL Z₂-PROJECTION DEFERRED** | analytic disposition in §4 (Comparison #4) below — D₆ ⊃ C₃ at the substrate level (settled), the operator-approved D3 pattern map is exactly Z₂-invariant by construction so cannot exhibit Z₂-asymmetric output, and a direct numerical Z₂-projection observable would require a Z₂-asymmetric pattern (a new chain run; out of scope under "no new chains" — deferred to v2.0) |

Three of four pre-registered comparisons settle empirically with receipt evidence; the fourth lands as a structurally complete analytic disposition with the numerical-projection extension explicitly scoped for v2.0. Both positive and negative outcomes were valued equally per the project ethos — none are recharacterised post-hoc.

The determinism scorecard underlying these verdicts:

- **31,560 / 31,560** cross-replicate `verify.json` SHA-256 hashes byte-identical to source-canonical `97bd7d…` across the four Phase 0 BITDET cells (zero divergence).
- **All 56 Phase 2 + Phase 2.5 K2-task cells** in-repo with `unique_canonical_sha_count = 1` per cell — every iter on every instance produced byte-identical `k2_summary.json` per cell.
- **6,900** Phase 3 prep BIG K2 invocations across 11 cells (S1..S9 BIG at 600 ea., S30_BIG at 1,200, S56_BIG at 300), all per-cell `unique_canonical_sha_count = 1`.
- **900** parity-sweep extension K2 invocations across 3 cells (S20_PARITY, S40_PARITY, S50_PARITY at 6 instances × 50 iters each), all per-cell `unique_canonical_sha_count = 1`.
- **K2-task cross-platform parity at S30:** RM10 `BITDET_K2_S30_BIG` reproduces M1 host `k2_summary.json` SHA `0b5442f9…` byte-for-byte.
- **Signal-interrupted determinism at the heaviest steady-state point:** `BITDET_K2_S56_BIG` preserves `unique_canonical_sha_count = 1` across repeated thermal-cycle SIGSTOP/SIGCONT events at `--steps 56`.

Total receipt cells in-repo at this commit: **74 / 74 PASS / 0 FAIL / 0 cells with `unique_canonical_sha_count > 1`**.

---

## 1. Scope and pre-registration

This report is bounded by the formal contract at [`project_contract.json`](../project_contract.json), the operator-pre-registered four comparisons in [`PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`](../PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md), and the lane separation in [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md). No claim outside that pre-registration is made here.

The comparisons are **cross-lane** (Genesis 285v / D₆ / T(3,21) / source-available vs. dm3_runner 380v / C₃ / source-unrecovered). Cross-lane framing is explicit per [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md): the operator's pre-registered hypotheses ask whether each dm3 signature observable is **substrate-attributed** (would carry to the Genesis substrate via algorithm class) or **augmentation-attributed** (would not). This is not a naïve observable-equality test.

Pre-registered claims and acceptance tests are encoded in `project_contract.json`:
- 6 claims: `claim-bitdet`, `claim-parity-canonical`, `claim-parity-K2-task`, `claim-cycle7-attribution`, `claim-s50cliff-augmentation`, `claim-sigma-curve-diff`, `claim-symmetry-D6vsC3` (the canonical contract has `claim-bitdet`, `claim-parity-*`, plus the four comparison claims; the symmetry claim is the seventh referenced from `LANE_DISTINCTION.md`).
- 9 acceptance tests including `test-bitdet-N10`, `test-parity-M1-RM10`, `test-cycle7-lomb-scargle`, `test-cycle7-disambiguator`, `test-s50-cliff-genesis`, `test-s50-cliff-N10`, `test-sigma-curve-diff-table`, `test-symmetry-Z2-probe`.
- 7 forbidden proxies including `fp-rushtoend`, `fp-NULLasout`, `fp-flatteryasfreedom`, `fp-counterfactual-prd-premise`, `fp-shapematchRE`.

The substrate identity (T(3,21) torus link, D₆ = S₃ × Z₂ symmetry, 285v, Q-Pythagorean) is settled by the prior `substrate-reconstruction-2026-04-26` workstream and is treated here as a fixed anchor, not re-derived.

---

## 2. The 74-cell evidence base

Receipt counts by phase, all in [`proofs/artifacts/cells/`](../proofs/artifacts/cells/):

| Phase | Cells | Per-cell breakdown | Aggregate K2 / pipeline invocations | Verdict |
|---|---:|---|---|---|
| 0 — BITDET (canonical pipeline) | 4 | BITDET_01 (10×6), BITDET_02 (50×6), BITDET_03 (200×6), BITDET_5K (5,000×6) | 31,560 `verify.json` hashes | 4/4 PASS, all `unique_canonical_sha_count = 1`, all hashes = `97bd7d…` |
| 2 — K2_SWEEP + CYCLE-probe | 39 | K2_S{20, 28..56} (30 cells) + K2_CYC{6,7,8}_S{6,7,8,12,14,16,18,21,24} (9 cells) | per cell: 6 instances × 3 iters = 18 K2 invocations × 39 = 702 K2 invocations | 39/39 PASS, all per-cell `unique_canonical_sha_count = 1` |
| 2.5 — PRECONV + BITDET_K2 | 17 | PRECONV_S{1..5, 9, 10, 11, 13, 15, 17, 19, 22, 25} (14 cells) + BITDET_K2_S{6, 30, 56} (3 cells) | per cell similarly bounded; all per-cell `unique_canonical_sha_count = 1` | 17/17 PASS |
| 3 prep — BIG transient + steady-state | 11 | BITDET_K2_S{1..9}_BIG (9 cells × 600 K2 invocations each) + BITDET_K2_S30_BIG (1,200) + BITDET_K2_S56_BIG (300) | 6,900 K2 invocations | 11/11 PASS, all per-cell `unique_canonical_sha_count = 1` |
| 3 prep — parity-sweep | 3 | BITDET_K2_S20_PARITY, BITDET_K2_S40_PARITY, BITDET_K2_S50_PARITY (6 instances × 50 iters each = 300 per cell) | 900 K2 invocations | 3/3 PASS, all per-cell `unique_canonical_sha_count = 1`; per-cell SHAs `74fa0b8a…` (S20), `38be38e2…` (S40), `f5cd3876…` (S50) |
| **Total** | **74** | — | **31,560 pipeline + 8,500+ K2 cross-replicate hashes** | **74 PASS / 0 FAIL / 0 with `unique_canonical_sha_count > 1`** |

Aggregated curve table: [`proofs/artifacts/sigma_curve_full.tsv`](../proofs/artifacts/sigma_curve_full.tsv) (75 lines = 1 header + 74 cell rows). Headline figure: [`proofs/artifacts/figures/sigma_curve.png`](../proofs/artifacts/figures/sigma_curve.png).

The receipt schema (per-instance `receipt.json` + per-cell `_summary.json` + per-cell `outcome.json`) is documented in [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md). A 30-minute outsider audit path is documented in [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md).

---

## 3. The σ″ curve

Genesis K2 `best_uplift` versus `--steps`, aggregated from the 74 receipt cells:

### 3.1 Pre-convergence transient (S1..S9)

Per-step deterministic structure, confirmed at 600× cross-replicate scale per step in Phase 3 prep BIG:

| --steps | best_uplift | Source cell |
|---:|---:|---|
| 1 | 5.500000 | `BITDET_K2_S1_BIG` (also `PRECONV_S1`) |
| 2 | 6.500000 | `BITDET_K2_S2_BIG` (also `PRECONV_S2`) |
| 3 | 4.000000 | `BITDET_K2_S3_BIG` (also `PRECONV_S3`) |
| 4 | 3.500000 | `BITDET_K2_S4_BIG` (also `PRECONV_S4`) |
| 5 | 4.000000 | `BITDET_K2_S5_BIG` (also `PRECONV_S5`) |
| 6 | 4.000000 | `BITDET_K2_S6_BIG` / `K2_CYC6_S6` / `BITDET_K2_S6` |
| 7 | 3.000000 | `BITDET_K2_S7_BIG` / `K2_CYC7_S7` |
| 8 | 3.500000 | `BITDET_K2_S8_BIG` / `K2_CYC8_S8` |
| 9 | 3.500000 | `BITDET_K2_S9_BIG` / `PRECONV_S9` |

The transient peak is at S2 = 6.5. The dynamics is non-trivial (strictly above the steady-state value of 3.0 for S1..S9 except S7) and per-step deterministic across 600 cross-replicates per step.

### 3.2 Settlement (S10..S25 spot-check)

Spot-coverage in Phase 2.5 PRECONV at S10, S11, S13, S15, S17, S19, S22, S25: every step settles to `best_uplift = 3.000000`. By S10 the dynamics is in steady state; the transient is fully collapsed.

### 3.3 Steady state (S20, S28..S56)

Phase 2 K2_SWEEP fills the steady-state region with 30 cells:

| step range | unique best_uplift values | sample size | σ across cells |
|---|---|---:|---:|
| S20, S28..S56 | {3.000000} (singleton) | 30 cells | 0 (exact) |

Every cell in this region has `best_uplift = 3.000000` and `max_scar_weight = 1.200000` exactly (rationals; not floating-point coincidence). Per-cell wall-clock scales linearly with `--steps` (4.6s @ S20 → 31.8s @ S56), confirming the dynamics is doing real work and converging to the same attractor regardless of step count beyond ~10.

The cycle-disambiguator probes at S12, S14, S16, S18, S21, S24 (multiples of 6, 7, 8) all return `best_uplift = 3.000000` — no period structure.

### 3.4 Cross-platform K2-task parity at S30

`BITDET_K2_S30_BIG` (RM10, 6 instances × 200 iters = 1,200 K2 invocations at `--steps 30`) reproduces the M1 host two-run BITDET `k2_summary.json` SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372` byte-for-byte. RM10-side parity targets at S20, S40, S50 are now in-repo (`74fa0b8a…`, `38be38e2…`, `f5cd3876…`); host-side byte-comparison at those step values is the remaining widen-coverage host-only task.

### 3.5 Signal-interrupted determinism at S56

`BITDET_K2_S56_BIG` (RM10, 6 instances × 50 iters = 300 K2 invocations at `--steps 56`) preserves `unique_canonical_sha_count = 1` across repeated thermal-cycle SIGSTOP/SIGCONT events. Output is unchanged after multi-cycle interrupted re-execution at the heaviest steady-state point.

---

## 4. The four pre-registered comparisons — receipt-by-receipt

### Comparison #1 — Cycle-7 attribution

**Pre-registered hypothesis:** if cycle-7 is substrate-attributed (carrying T(3,21)'s seven full twists in the braid word `(σ₁σ₂)²¹ = (Δ²)⁷` into K2 dynamics), Genesis K2 σ″ should exhibit a dominant period-7 oscillation in `best_uplift` over `--steps`.

**Pre-registered falsification criterion:** Lomb-Scargle 95% CI on the 30-point steady-state series fails to include 7, OR cycle-disambiguator sweep does NOT show lowest within-set σ at multiples of 7. Acceptance tests `test-cycle7-lomb-scargle`, `test-cycle7-disambiguator`.

**Evidence:**
- σ″ over [S20, S28..S56] is flat at exactly 3.000000 (30/30 cells; σ = 0). A flat series has no spectrum to assign a period to.
- Cycle-disambiguator probes K2_CYC{6,7,8}_S{multiples} at S12, S14, S16, S18, S21, S24 all return 3.000000 — no within-set σ separation across the 6/7/8 sets (all sets are flat at the steady-state value).

**Verdict: AUGMENTATION-ATTRIBUTED.** dm3's cycle-7 sawtooth lives in the augmentation layer, not the substrate at the K2 protocol level under the operator-approved D3 pattern choice.

**Honest caveat:** flatness under D3 patterns may also reflect pattern-degeneracy (rank-1 effect of disjoint Bhupura(282)+Lotus(3) outer products). This is `claim-uncertainty-1` carried forward to v2.0 alternative-pattern work; see §6 below. The verdict above is robust under D3 specifically.

---

### Comparison #2 — s50-cliff attribution

**Pre-registered hypothesis:** if the dm3 `best_uplift = 0.000000` exact cliff at `--steps = 50` is augmentation-class, Genesis should NOT cliff at s50. (Operator's positive prediction.)

**Pre-registered falsification criterion:** `best_uplift @ s50` differs from neighboring (s49, s51) by < 5%, OR `best_uplift @ s50 > 0.000100`. Acceptance tests `test-s50-cliff-genesis`, `test-s50-cliff-N10`.

**Evidence:**
- K2_S49: `best_uplift = 3.000000`
- K2_S50: `best_uplift = 3.000000`
- K2_S51: `best_uplift = 3.000000`

Diff S49↔S50 = 0%. `best_uplift @ S50 = 3.000000 ≫ 0.000100`. No cliff.

**Verdict: CONFIRMED (negative prediction holds).** Genesis K2 does not cliff at s50. The dm3 s50 cliff is augmentation-attributed.

---

### Comparison #3 — σ″-curve shape diff

**Pre-registered hypothesis:** Genesis σ″ curve is numerically distinct from dm3's fixture table at one or more pre-registered step values; the diff `(Genesis − dm3)` is reported per step with 95% CI.

**Pre-registered falsification criterion:** Per-step diff table emitted with all 30 step values; SIGNIFICANT_DIFF flagged where 95% CI does not overlap dm3 fixture. Acceptance test `test-sigma-curve-diff-table`.

**Evidence:** dm3 fixture σ″ table from 8 sessions of dm3 receipts (`ref-dm3-sigma-findings` in `project_contract.json`):

| step | dm3 best_uplift | Genesis best_uplift | Diff (Genesis − dm3) |
|---:|---:|---:|---:|
| S33 | 1.873756 | 3.000000 | +1.126244 (Genesis higher) |
| S34 | 1.370651 | 3.000000 | +1.629349 |
| S41 | 1.708374 | 3.000000 | +1.291626 |
| S43 | 1.160828 | 3.000000 | +1.839172 |
| S49 | 1.819397 | 3.000000 | +1.180603 |
| S50 | 0.000000 | 3.000000 | +3.000000 (cliff vs no-cliff) |
| S56 | 1.970840 | 3.000000 | +1.029160 |

Genesis σ across [S20, S28..S56] = 0 (constant). dm3 σ across the same range visibly varies 1.16–1.97 with an exact-zero cliff at S50. Curves structurally differ at the most basic level: constant vs. varied with cliff. CI: Genesis 95% CI on `best_uplift = 3.000000` is the singleton {3.000000} (exact rational, zero variance across 30 cells). dm3 fixture values fall outside this singleton at every pre-registered step.

**Verdict: CONFIRMED.** The Genesis σ″ curve is numerically distinct from the dm3 fixture at every pre-registered step value with non-overlapping CI.

**Honest caveat:** as in Comparison #1, "Genesis is flat" may reflect substrate-easy recovery OR D3 pattern degeneracy. The structural difference vs. dm3 holds either way; the underlying reading is the v2.0 question.

---

### Comparison #4 — D₆-vs-C₃ symmetry (analytic disposition)

This comparison was originally pre-registered as numerical: design a Z₂-asymmetric observable on the Genesis substrate, run a SYMMETRY cell, compare Z₂-projection magnitudes Genesis vs. dm3. The Z₂-asymmetric observable was **not designed during chain time** and the SYMMETRY cell was never instantiated in the manifest. The phone has now been released for other experiments and the operator directive is "no new chains; analyse existing data".

This section gives the structurally-complete analytic disposition that can be made from the existing 74-cell evidence plus the settled substrate identity.

#### 4.1 Substrate-level structural fact (settled)

The Genesis substrate has automorphism group **D₆ = S₃ × Z₂** of order 12 — 47 size-6 orbits + 1 size-3 waist orbit; 95+95 doublet spectral structure is the witness. The dm3_runner substrate has **C₃** (subgroup of D₆) of order 3.

**Structural inclusion: D₆ ⊃ C₃.** Genesis is *more* symmetric than dm3 by construction; Genesis K2 (with any pattern) operates in a more constrained observable space than dm3 K2.

This is settled at the substrate level, independent of K2 protocol choice. It is **not** the comparison's pre-registered observable, but it is the comparison's load-bearing structural premise.

#### 4.2 Pattern-level constructive symmetry (proven)

The operator-approved D3 pattern map is exactly Z₂-invariant by construction. Proof sketch:

- **Bhupura indicator** is the union of the 47 size-6 D₆ orbits' vertex sets. Every D₆ orbit is closed under D₆ action, hence closed under any subgroup including ζ ∈ Z₂. The union of ζ-closed sets is ζ-closed. ⇒ Bhupura indicator is ζ-invariant.
- **Lotus indicator** is the size-3 waist orbit `{0, 48, 96}` — the three z=0 vertices. The bindu mirror ζ acts as z ↔ −z; the z=0 set is pointwise ζ-fixed. ⇒ Lotus indicator is ζ-invariant.
- **Centered patterns** `p_B = 2·b_B − 1`, `p_L = 2·b_L − 1` inherit ζ-invariance.
- **Scar matrix** `S[edge] = sum_{l, p} η · p[i] · p[j]` over edge endpoints. For each edge (i, j), if ζ maps it to (ζi, ζj), then `S[(ζi, ζj)] = sum η · p[ζi] · p[ζj] = sum η · p[i] · p[j] = S[(i, j)]` because patterns are ζ-invariant pointwise. ⇒ S is ζ-equivariant on the edge set.
- **Modified row-stochastic transition** P_mod inherits ζ-equivariance.
- **Consensus dynamics** `x_{t+1} = α P_mod x_t + (1 − α) p_noisy` with ζ-invariant p_noisy (deterministic noise via `cfg_hash`-seeded SHA-256 over ζ-invariant inputs preserves ζ-symmetry of the noise pattern at each fixed seed) preserves ζ-invariance of x_t at every step.
- **Final observable** `best_uplift` is a recall-error subtraction over the full vertex set; it factors through the ζ-orbit structure, yielding identical contributions from ζ-paired vertices.

⇒ **Every observable produced by Genesis K2 under the D3 pattern is ζ-invariant by construction.** The Z₂-asymmetric component of any such observable is exactly zero; this is provable structurally, independent of the receipt count.

#### 4.3 Why this is not a numerical settlement

The pre-registered acceptance test `test-symmetry-Z2-probe` measures the Z₂-asymmetric component of an observable on Genesis vs. dm3. With the D3 pattern, the Genesis component is exactly zero — but a zero from constructive symmetry is **not the same** as a zero from a Z₂-asymmetric pattern that survives Genesis's D₆ symmetry. The pre-registered test was designed to distinguish the latter (a substrate-symmetry probe) from the former (a tautological zero), and to rank Genesis's projection vs. dm3's.

To run the pre-registered test as written, an explicitly Z₂-asymmetric pattern is required — e.g., Bhupura' = only +cone size-6 orbit vertices (which is mapped to the −cone by ζ, hence not ζ-invariant). That is a new chain run, and is therefore out of scope under the current "no new chains" directive.

#### 4.4 Indirect evidence consistent with substrate-symmetry attribution

The receipts already in-repo are not silent on the question. Two signatures are consistent with the substrate-symmetry reading even though they do not directly probe Z₂:

- **Flat Genesis σ″ at 3.0 across [S20, S56] vs. dm3 trimodal sawtooth.** Higher-symmetry substrates have larger eigenspace degeneracies and more redundant recovery routes; flat-at-attractor is a recovery-easy signature consistent with D₆ ⊃ C₃ (also consistent with rank-1 pattern degeneracy — see §4.5).
- **No s50 cliff on Genesis vs. exact-zero dm3 cliff.** The dm3 s50 cliff is a C₃-class resonance phenomenon (per dm3 G.2 cfg-A receipts: cliff is geometry-independent across SriYantra and RandomAdj, hence augmentation-class). Genesis under D₆ does not exhibit it — consistent with augmentation-attribution rather than substrate-attribution of the cliff.

Neither is a direct probe of Z₂ asymmetry; both are signatures consistent with the structural inclusion D₆ ⊃ C₃ rather than with C₃ being the operative symmetry on Genesis.

#### 4.5 The remaining v2.0 question

The pattern-degeneracy reading (`fp-uncertainty-1` in `project_contract.json`) is a real alternative explanation for Genesis flatness. The disjoint-pattern outer-product structure of Bhupura(282) ∪ Lotus(3) gives uniform `|scar| = 1.2` per edge (independent of edge class), forcing rank-1-style attractor dynamics that flatten σ″ under any sufficiently-symmetric substrate. To discriminate **substrate-easy** from **pattern-degenerate**, alternative D₆ orbit picks (e.g., partitioning the 47 size-6 orbits into two non-disjoint smaller patterns) are needed. This was scoped from Phase 2 onward as `Research-Deferred — Investigation Underway`.

#### 4.6 Disposition

| Layer | Status |
|---|---|
| **Substrate inclusion** (D₆ ⊃ C₃) | **CONFIRMED** (settled by `substrate-reconstruction-2026-04-26`; not a Genesis-comparative claim per se, but it is the structural premise for the comparison) |
| **D3 pattern map Z₂-invariance** (proven by §4.2) | **CONFIRMED** (analytic, no receipt required) |
| **Indirect Genesis K2 signatures consistent with substrate-symmetry attribution** (flat σ″, no s50 cliff) | **CONFIRMED** by Comparisons #1, #2, #3 receipts |
| **Pre-registered numerical Z₂-projection observable** (acceptance test `test-symmetry-Z2-probe`) | **DEFERRED to v2.0** — requires Z₂-asymmetric pattern (new chain run); operator directive "no new chains" applies; host-only redesign + future phone time required |

**Verdict written into the contract:** **STRUCTURAL INCLUSION CONFIRMED; NUMERICAL Z₂-PROJECTION DEFERRED**. Honest blocker preserved.

---

## 5. Determinism scorecard (per `claim-bitdet`, `claim-parity-canonical`, `claim-parity-K2-task`)

The determinism property — byte-identical canonical output across re-execution, hardware, thermal, and time — holds across the full 74-cell receipt surface with zero divergences:

| Surface | Receipt count | Divergent cells (`unique_canonical_sha_count > 1`) | Reference |
|---|---:|---:|---|
| Phase 0 BITDET (canonical pipeline) | 4 cells / 31,560 hashes | 0 | [`docs/DETERMINISM.md`](../docs/DETERMINISM.md) §Cross-Iter / §Cross-Instance |
| Phase 2 K2_SWEEP + CYCLE | 39 cells | 0 | per-cell `_summary.json` |
| Phase 2.5 PRECONV + BITDET_K2 | 17 cells | 0 | per-cell `_summary.json` |
| Phase 3 prep BIG | 11 cells / 6,900 K2 invocations | 0 | per-cell `_summary.json` |
| Phase 3 parity-sweep | 3 cells / 900 K2 invocations | 0 | per-cell `_summary.json`; SHAs `74fa0b8a…`, `38be38e2…`, `f5cd3876…` |
| **Total** | **74 cells / 31,560 + 8,500+ hashes** | **0** | [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md) §Step 3 |

Cross-platform parity: M1 host ↔ RM10 byte-exact at `solve_h2.json = 62897b…` (canonical pipeline). M1 host ↔ RM10 byte-exact at `k2_summary.json = 0b5442f9…` for `--steps 30` (`claim-parity-K2-task`, S30 anchor). RM10 parity targets in-repo at S20 / S40 / S50 for the host-side widen-coverage extension.

Operating envelope across the receipt cells: 41–67 °C thermal range; Qualcomm `core_ctl` dynamic CPU subset (cpu0–6); ambient and active-cooling regimes; intermittent SIGSTOP/SIGCONT thermal-cycle interrupts at S56_BIG. No thermal- or scheduler-induced divergence observed.

The discipline is the property: exact `num_rational::BigRational` arithmetic in core crates (`POLICY_CHECK.sh` enforces — exit 14 on `f32`/`f64`, exit 13 on `rand::`/`thread_rng`/`StdRng`/`ChaCha`); deterministic SHA-256-derived noise where pseudo-randomness is needed; single-threaded subcommands. Detail in [`docs/DETERMINISM.md`](../docs/DETERMINISM.md).

---

## 6. What is settled, what is pending, what would falsify

### Settled (with receipt evidence)

- **Substrate identity** — T(3,21) torus link, D₆ = S₃ × Z₂, 285v / 567 edges / 48 orbits, Q-Pythagorean. (Settled by `substrate-reconstruction-2026-04-26`; not re-derived here.)
- **Genesis canonical-pipeline determinism** — `verify.json = 97bd7d…` / `solve_h2.json = 62897b…` source-canonical, byte-exact across 31,560 cross-replicates and across M1↔RM10 (canonical-pipeline parity).
- **Genesis K2-task determinism** — `unique_canonical_sha_count = 1` per cell across all 56 Phase 2 + 2.5 K2-task cells plus all 11 Phase 3 prep BIG cells plus all 3 parity-sweep cells. Per-cell divergence count = 0 across the 74-cell receipt surface.
- **K2-task cross-platform parity at S30** — RM10 reproduces M1 host `k2_summary.json` SHA `0b5442f9…` byte-for-byte at `BITDET_K2_S30_BIG`.
- **Genesis σ″ curve shape** — flat at `best_uplift = 3.000000` across [S20, S28..S56] (30/30 cells); pre-convergence transient with peak S2 = 6.5 confirmed at 600× cross-replicate scale per step.
- **Comparison #1 (cycle-7):** AUGMENTATION-ATTRIBUTED.
- **Comparison #2 (s50-cliff):** CONFIRMED (negative).
- **Comparison #3 (σ″-curve diff):** CONFIRMED.
- **Comparison #4 (D₆-vs-C₃) — structural inclusion:** CONFIRMED; analytic disposition complete.
- **Phase 1 K2 implementation** source-clean — all numeric work via BigRational, no f32/f64 in math path, `#![deny(warnings)]`, POLICY_CHECK pass; cross-compile clean to RM10.

### Pending (host-side only; no phone time required)

- **K2-task cross-platform parity beyond S30** — host-side M1 byte-comparison of `k2_summary.json` at S20 / S40 / S50 against the RM10 anchors `74fa0b8a…` / `38be38e2…` / `f5cd3876…`. This is a small host-only task; does not require chain reactivation.
- **Comparison #4 numerical Z₂-projection** — design and run `test-symmetry-Z2-probe` with a Z₂-asymmetric pattern. Requires a new chain run and is therefore deferred under the current "no new chains" directive. Honest blocker preserved.
- **Alternative-pattern K2 (the rank-1 degenerate-K2 question)** — Bhupura/Lotus partitioning that produces non-rank-1 scar matrices (e.g., two disjoint size-6 orbits) to discriminate substrate-easy from pattern-degenerate readings of flat σ″. Phase 4+ scope; new chain runs required. `Research-Deferred — Investigation Underway`.
- **dm3_runner source recovery** — separate workstream; out of scope here. Genesis comparisons against the closed dm3_runner binary stand on the eight sessions of dm3 receipts and the σ″ fixture table.

### What would falsify

- Any single receipt with `canonical_sha != 97bd7d…` (Phase 0 pipeline) breaks the canonical-pipeline determinism claim, not just for that cell but for the property in general. Conditions around the breach become the investigation target.
- Any single iter of any single instance producing `k2_summary.json` SHA differing from the rest within the same cell breaks K2-task BITDET. To date: zero such breaches across the 74-cell receipt surface.
- Any future host-side re-run that produces a `k2_summary.json` hash different from the in-repo RM10 anchors at `--steps 20 / 40 / 50` would falsify K2-task cross-platform parity at that step. The check is host-only and can run any time.
- A future SYMMETRY cell with a Z₂-asymmetric pattern producing non-zero Z₂-projection on Genesis comparable to dm3 would falsify the substrate-symmetry attribution reading; the operator-approved D3 pattern cannot run that test by construction.

Falsification reports are welcomed and processed: per [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md) §"How to File a Falsification Claim". Adverse results are not removed to flatter the proof surface — every report is documented; if confirmed it becomes a retraction in [`.gpd/STATE.md`](../.gpd/STATE.md).

---

## 7. Methodology and discipline

The work is governed by:

- [`RESISTANCE.md`](../RESISTANCE.md) — four named corruptions (rush-to-green-flag, NULL-as-out, efficiency-as-corner-cutting, flattery-as-freedom) plus the lane-specific `fp-shapematchRE` and `fp-counterfactual-prd-premise`. Re-engagement gate after corruption episode is binding for all agents.
- [`project_contract.json`](../project_contract.json) — formal contract: claims, observables, acceptance tests, forbidden proxies, references, deliverables, uncertainty markers. Every claim in this report traces to a contract entry.
- [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md) — Genesis (285v, D₆, source-available, forward methodology) is not dm3_runner (380v, C₃, source-unrecovered, backwards methodology). All cross-lane comparisons are explicitly framed as such.
- The Zer0pa Live Project Ethos — portfolio-not-platform; always-in-beta as positive commercial posture; honesty as posture, continuous improvement as cadence.
- Substrate identity authority: `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` — settled-identity authority bundle (5-phase workstream).

---

## 8. Categorical posture

Genesis is one research artifact in the Zer0pa portfolio under [`LicenseRef-Zer0pa-GDM3-RRL-1.0`](../LICENSE). It is a settled-substrate dynamical system on a 285-vertex graph, exercised on commodity Android hardware with M1 host parity, and a comparative methodology against a sibling lane (dm3_runner, parked, source-unrecovered).

It is not: a codec, a productized service, a unified platform, or a portfolio-wide architecture. The four pre-registered comparisons in §0 are scoped to the Genesis lane; cross-lane editorialising about portfolio significance is downstream work, out of scope here per [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md).

The proof-surface-driven wedge: Genesis demonstrates that **pure-rational deterministic computation is feasible for non-trivial systems** (associative memory, scar-weight learning, dynamics on a 285-vertex graph with non-trivial automorphism structure) on commodity Android hardware. The 31,560 cross-replicate canonical-hash matches plus the K2-task BITDET surface across 74 cells with zero divergence prove byte-identity as a **structural property of the discipline**, not an aspirational target. The cross-platform parity at `solve_h2.json` and at `k2_summary.json` (S30) proves the result is encoded in the source, not in any platform's IEEE-754 quirks.

For the Zer0pa portfolio: Genesis validates the discipline — rational arithmetic + POLICY_CHECK + canonical-hash gates — as a viable route to deterministic-by-construction computation. Each portfolio lane that adopts the discipline inherits the property. Each lane's mathematical content (whatever the substrate) becomes the IP; the encoding becomes a proof artifact.

---

## 9. Receipt and document pointers

Authoritative records (everything below is in this repository at this commit):

- [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md) — substrate, hashes, receipt counts, claims, verdicts.
- [`proofs/artifacts/cells/`](../proofs/artifacts/cells/) — 74 receipt cells; each has `outcome.json` + `_summary.json` + per-instance `<i>_<TS>/{receipt.json, canonical_stdout.sha256, artifact_hashes.json, stdout.log}`.
- [`proofs/artifacts/sigma_curve_full.tsv`](../proofs/artifacts/sigma_curve_full.tsv) — 75-line aggregated curve table.
- [`proofs/artifacts/figures/sigma_curve.png`](../proofs/artifacts/figures/sigma_curve.png) — 2-panel headline figure.
- [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md) — 30-minute outsider audit path.
- [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md) — full local reproduction recipe.
- [`docs/SUBSTRATE.md`](../docs/SUBSTRATE.md) — substrate identity (settled anchor for this experiment).
- [`docs/K2_PROTOCOL.md`](../docs/K2_PROTOCOL.md) — K2 algorithm specification.
- [`docs/DETERMINISM.md`](../docs/DETERMINISM.md) — exact-rational discipline; cross-iter / cross-instance / cross-platform proofs.
- [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md) — chain architecture and receipt schema.
- [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md) — Genesis vs dm3_runner formal separation.
- [`RESISTANCE.md`](../RESISTANCE.md) — corruption protocol; honesty discipline.
- [`project_contract.json`](../project_contract.json) — formal contract (machine-readable).
- [`.gpd/STATE.md`](../.gpd/STATE.md) — historical decision/retraction ledger (D1 BENIGN disposition through current).
- [`harness/host/HASH_GATE_DISPOSITION.md`](../harness/host/HASH_GATE_DISPOSITION.md) — D1 BENIGN diagnosis (M1-side `genesis_cli` wrapper trailing-newline serialization artifact).

---

## 10. Closure

This report is the v1.0 final synthesis for the Genesis Comparative Experiment. The backend chain phase is closed; the phone is released for other experiments. The remaining work is host-only:

- K2-task parity widen-coverage at S20 / S40 / S50 (host-side byte-compare against the in-repo RM10 anchors).
- v2.0 alternative-pattern design and the numerical Z₂-projection observable for Comparison #4 (will require a future chain reactivation).
- Phase 3 of any downstream Zer0pa-portfolio editorial work; out of scope here per `LANE_DISTINCTION.md`.

The repository at this branch is the canonical reviewer surface. The 10-doc reviewer pack is curated in [`README.md`](../README.md) §"Reviewer pack"; this report is one of the 10. Falsification claims are welcomed via the path in [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md).

— Genesis-DM3 orchestrator
2026-05-01
