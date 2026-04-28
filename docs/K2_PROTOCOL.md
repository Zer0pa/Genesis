# K2 — Scar-Formation + Recall Protocol

**Status:** Phase 1 host-side implementation landed (commit `c43a402`); Phase 2 RM10 sweep in flight; Phase 3 synthesis pending.
**Source of truth:** [`crates/io_cli/src/k2_scars.rs`](../../recovery/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/crates/io_cli/src/k2_scars.rs) (506 lines) + [`main.rs`](../../recovery/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/crates/io_cli/src/main.rs) K2Scars dispatch (lines 37–63, 222–268). Cross-lane comparison anchor: [`dm3_parallel/binaries/sample_full_run_s30.log`](../../dm3_parallel/binaries/sample_full_run_s30.log).
**Lane:** Genesis (285v, D₆) — see [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md). Comparisons against `dm3_runner` (380v, C₃, source-unrecovered) are explicitly cross-lane.

---

## The Question K2 Asks

K2 is a Hebbian-style associative-memory protocol: given two patterns (Bhupura, Lotus) defined over the 285-vertex Genesis substrate, do scar-weight modifications on the substrate's edges enable recovery of the original pattern from a deterministically-noised version, when consensus dynamics is run for `--steps N` iterations?

The protocol mirrors `dm3_runner`'s `exp_k2_scars` task algorithmically but operates on a different substrate. The dm3 task on its 380-vertex C₃ graph produces a non-trivial σ″ trimodal sawtooth in `best_uplift` over `--steps` (see [§The Pre-Registered Comparisons](#the-pre-registered-comparisons-where-k2-results-will-land) below for fixture values). The Genesis K2 protocol re-runs the same algorithmic shape on the 285v D₆ substrate. The shape of `best_uplift` versus `--steps` on Genesis — flat or varied, periodic or aperiodic, cliff-bearing or smooth — is the falsification surface for the four pre-registered cross-lane comparisons enumerated in [`project_contract.json`](../project_contract.json).

This document is a self-contained algorithm specification. An algorithm reviewer can audit K2 from this document alone; the source pointer is for cross-checking.

---

## Inputs

| Input | Path / value | Role |
|---|---|---|
| Substrate fixture | [`inputs/substrate_285v.json`](../inputs/substrate_285v.json) | 285 vertices, 567 undirected edges, 48 D₆ orbits (47 size-6 + 1 size-3 waist), Bhupura indices (cardinality 282), Lotus indices (cardinality 3 = waist orbit `[0, 48, 96]`) |
| Config | `configs/CONFIG.json` (in cross-compiled binary deploy tree) | Drives `cfg_hash` via SHA-256 of the JSON-canonical form; cfg_hash seeds the noise RNG |
| `--steps N` | CLI argument; the swept dimension | Dynamics iteration count |
| `--substrate PATH` | CLI argument (default `inputs/substrate_285v.json`) | Substrate JSON |
| `--config PATH` | CLI argument (default `configs/CONFIG.json`) | Config file (drives `cfg_hash`) |
| `--eta-num` / `--eta-den` | CLI arguments (defaults 1 and 5; η = 1/5 = 0.2) | Hebbian learning rate as exact rational |
| `--lesson-counts-tsv` | CLI argument (default `"0,3"`) | Lesson levels for the inner loop |
| `--noise-levels-tsv` | CLI argument (default `"1/10,2/10"`) | Noise rates as `a/b` rationals |
| `--output-dir` | CLI argument (default `artifacts`) | Where `k2_summary.json` is written |
| Implicit constants | α = 164/165 (consensus weight); 1−α = 1/165; threshold = 1/2 | All BigRational; α = spectral bound from `dynamics_deq::solve_h2` |

All numeric work is `num_rational::BigRational` (`Rat`). Floating-point is used **only** for `printf` formatting in stdout KPI lines; no arithmetic in the math path uses f32 or f64. Workspace is `#![deny(warnings)]`.

---

## Patterns (Bhupura, Lotus)

Operator-approved pre-registration ([decision D3](../.gpd/STATE.md#decisions)) maps the two K2 patterns onto the substrate's D₆ orbit decomposition:

- **Bhupura analog:** the union of the 47 size-6 D₆ orbits — the 282 vertices with full D₆ stabilizer (the "radial" set). Binary indicator `b_B[v] = 1` for `v ∈ Bhupura_indices`, else 0.
- **Lotus analog:** the single size-3 waist orbit — vertices `[0, 48, 96]` (mirror-fixed singular center). Binary indicator `b_L[v] = 1` for `v ∈ Lotus_indices`, else 0.

The two binary indicators are then *centered* into bipolar form ∈ `{-1, +1}^285`:

```
p_B_centered[v] = 2 · b_B[v] − 1     ∈ {-1, +1}
p_L_centered[v] = 2 · b_L[v] − 1     ∈ {-1, +1}
```

Bhupura support has cardinality 282; Lotus support has cardinality 3; the two supports are disjoint and union to the full vertex set.

The justification — Sri-Yantra geometric intuition mapped to Genesis's D₆ orbit structure — was pre-registered before implementation: 47 size-6 orbits = full D₆ stabilizer (the radial bulk), 1 size-3 waist = mirror-fixed singular center. The choice satisfies D₆-symmetry-aware design.

**Honest consequence of the choice (mathematical, not aspirational):** because the two patterns are disjoint indicator vectors with very unequal cardinalities, every Hebbian outer product `p_centered ⊗ p_centered` factored onto edge weights yields the same magnitude per edge — i.e., for every edge `(i, j)`, `p_centered[i] · p_centered[j] = ±1`, with sign determined by the two-vertex class membership (BB / LL / BL). After accumulating over `L` lessons and both patterns, every edge sees `|scar| = L · 2 · η` independent of class, making the scar matrix uniform in magnitude (rank-1 in the sense of contributing the same weight magnitude to every edge). Alternative pattern choices — e.g., picking two disjoint size-6 orbits as Bhupura and Lotus, both small and sparse, neither covering the full graph — would produce a non-rank-1 scar matrix with class-dependent magnitudes. This is `Research-Deferred — Investigation Underway` per the [README §Upcoming Workstreams](../README.md#upcoming-workstreams).

---

## Step 1 — Hebbian Scar Weights

For each lesson `l ∈ {1, …, L}`, for each pattern `p ∈ {p_B_centered, p_L_centered}`, for each edge `(i, j) ∈ E`:

```
S[edge_idx] += η · p[i] · p[j]
```

where `η = eta_num / eta_den` (default 1/5) is held exactly as `Rat`, and the addition is exact rational. After `L` lessons, `S: Vec<Rat>` has length `n_edges = 567`.

Aggregate metrics emitted:

```
max_abs_delta  = max_{e ∈ E} |S[e]|
mean_abs_delta = (1 / |E|) · sum_{e ∈ E} |S[e]|
changed_edges  = |{ e ∈ E : |S[e]| ≠ 0 }|
total_edges    = |E| = 567
```

KPI line:

```
KPI_K2_SCAR_WEIGHTS lessons=<L> max_abs_delta=<%.9e> mean_abs_delta=<%.9e> changed_edges=<int> total_edges=567
```

For the operator-approved D3 pattern choice on Genesis at `L = 3`:

- `max_abs_delta = 1.200000000e0` (exact: 3 lessons × 2 patterns × η = 3 × 2 × 1/5 = 6/5)
- `mean_abs_delta = 1.200000000e0` (uniform — every edge sees the same magnitude due to the rank-1 effect described above)
- `changed_edges = 567` (every edge)
- `total_edges = 567`

For comparison, the dm3 fixture at `L = 3` on the 380v C₃ substrate ([dm3 sample log line 18](../../dm3_parallel/binaries/sample_full_run_s30.log)):

- `max_abs_delta = 1.999999881e-1` (peak)
- `mean_abs_delta = 8.297970146e-2` (varied; peak ≫ mean)
- `changed_edges = 1892 of 4560` (~41%, not all)

The two substrates produce structurally different scar matrices on the same algorithm with the operator-approved pattern map. This is a structural fact about the inputs; the dynamical consequences are what Phase 2 measures.

---

## Step 2 — Modified Row-Stochastic Transition Matrix

From the substrate's undirected adjacency `E`, build the modified row-stochastic transition matrix `P_mod` with scar weights:

For each undirected edge `(i, j) ∈ E` (edge index `eidx`):

```
w_raw  = 1 + S[eidx]
w_ij   = max(w_raw, 1/100)         # clip to keep row-stochastic; rationals
P_mod  accumulates w_ij in both directions (i→j and j→i)
```

For each vertex `i`:

```
row_weight[i] = sum_{j : (i,j) ∈ E} w_ij
P_mod[i][j]   = w_ij / row_weight[i]    for j ∈ neighbors(i)
P_mod[i][j]   = 0                       otherwise
```

Isolated-vertex guard: if `row_weight[i] = 0`, set `P_mod[i][i] = 1` (self-loop).

All math is BigRational. The clip at `1/100` ensures positivity even when scar weights are strongly negative (as on BL-class edges in the Bhupura/Lotus disjoint-pattern case). Bigger positive scar weights pull dynamics along those edges; negative scar weights weaken pull (clipped to 1/100 minimum).

---

## Step 3 — Deterministic Noisy Pattern Generation

Noise is deterministic, hash-derived, and content-addressable on the inputs. For a pattern `p` (binary 0/1 form, *not* centered) with rate `noise = a/b`:

```
flip_threshold = floor(256 · a / b)        # u8

for v in 0..285:
    seed = SHA256( cfg_hash || "|" || lesson_count
                            || "|" || noise_idx
                            || "|" || pattern_idx
                            || "|" || v )
    if seed[0] < flip_threshold:
        p_noisy[v] = 1 − p[v]              # flip
    else:
        p_noisy[v] = p[v]
```

The first byte of the SHA-256 digest decides the flip. Same `cfg_hash` + same lesson/noise/pattern/vertex tuple → same byte → same flip decision. Reproducible across runs, instances, processes, and platforms.

For default noise levels `1/10` and `2/10`, `flip_threshold = 25` and `51` respectively (out of 256), giving expected flip rates 25/256 ≈ 9.77% and 51/256 ≈ 19.92%.

---

## Step 4 — Consensus Dynamics for Recall

Initialize `x_0 = p_noisy` (the noised pattern, in binary 0/1 form held as `Rat`). For `t = 0, 1, …, N − 1`:

```
x_{t+1} = α · (P_mod · x_t) + (1 − α) · p_noisy
```

with `α = 164/165` and `1 − α = 1/165`, both exact `Rat`. After `N` iterations (`N = --steps`), threshold `x_N` to `{0, 1}`:

```
x_N_rounded[v] = 1   if x_N[v] ≥ 1/2
                 0   otherwise
```

Mathematical interpretation: damped consensus on the modified graph. The fixed point is `x_∞ = (1 − α) · (I − α · P_mod)^{-1} · p_noisy`; iterating `N` steps gives an `α^N`-rate approximation. Rounding at threshold `1/2` discretizes the result for Hamming comparison.

---

## Step 5 — Recall Error and Uplift Aggregation

For each lesson level `L ∈ {0, 3}` (default), for each noise level `noise ∈ {1/10, 2/10}` (default), for each pattern `p ∈ {Bhupura, Lotus}`:

```
generate p_noisy (Step 3)
run dynamics for N steps (Step 4)
threshold to {0,1} → x_N_rounded
recall_err = sum_{v=0..284} |x_N_rounded[v] − p_target[v]|       # exact Hamming, in Q
```

Per-pattern recall is emitted as informational output:

```
    Pattern Bhupura: Recall Error = <%.6f>
    Pattern Lotus: Recall Error = <%.6f>
```

Then:

```
avg_recall_err(L, noise) = (recall_err_Bhupura + recall_err_Lotus) / 2
baseline_recall_err(noise) = avg_recall_err(0, noise)            # captured at L=0
uplift(L, noise) = baseline_recall_err(noise) − avg_recall_err(L, noise)
```

For the summary line:

```
best_uplift     = max_{noise} uplift(L_max, noise)
max_scar_weight = max_abs_delta(L_max)
```

For the operator-approved D3 pattern choice on Genesis at `--steps 30` (M1 host, Phase 1):

- `baseline_recall_err = 3.000000` (the substrate's L=0 dynamics with no scars and noise rates < 50% rounds to exactly 3 mismatches; the Lotus support is exactly 3 vertices and the unmodified consensus equilibrium under the chosen α drives the recall back to a uniform state across the radial bulk plus the 3 waist vertices — see [§Open Questions](#open-questions-from-the-host-side-n1-result))
- `avg_recall_err(L=3, noise=1/10) = 0.000000` (perfect recall after 3 lessons)
- `avg_recall_err(L=3, noise=2/10) = 0.000000` (perfect recall after 3 lessons)
- `best_uplift = 3.000000` (= 3 − 0)

These are exact rationals, formatted via `%.6f`. The integer-valued result is mathematically exact, not floating-point coincidence.

For comparison, the dm3 fixture at `--steps 30` on its 380v C₃ substrate ([sample log lines 9, 13, 22, 26, 28](../../dm3_parallel/binaries/sample_full_run_s30.log)):

- `baseline_recall_err(noise=1/10) = 103.161766`
- `baseline_recall_err(noise=2/10) = 103.263672`
- `avg_recall_err(L=3, noise=1/10) = 101.517242`
- `uplift(L=3, noise=1/10) = 1.644524`
- `best_uplift = 1.644524`

The two substrates produce structurally different baselines and uplifts at the same step count under the operator-approved pattern map. This difference is the substantive observable; its origin (substrate-attributed vs pattern-degeneracy-attributed) is the open scientific question Phase 2 discriminates.

---

## The KPI Line Schema (dm3-Mirror)

Every K2 invocation emits the following stdout KPI lines, in order:

```
Lessons: <L>, Max Scar Weight: <%.9e>
KPI_K2_SCAR_WEIGHTS lessons=<L> max_abs_delta=<%.9e> mean_abs_delta=<%.9e> changed_edges=<int> total_edges=<int>
    Pattern Bhupura: Recall Error = <%.6f>
    Pattern Lotus: Recall Error = <%.6f>
KPI_K2 lesson=<L> noise=<%.3f> avg_recall_err=<%.6f> baseline_recall_err=<%.6f> uplift=<%.6f> scar_max=<%.6f>
KPI_K2_LESSON lessons=<L> eta=<%.4f> duration_sec=<%.3f> evals_per_sec=<%.3f>
KPI_K2_SUMMARY duration_sec=<%.3f> max_scar_weight=<%.6f> best_uplift=<%.6f>
```

with the four `KPI_K2` lines (2 lessons × 2 noise) emitted within their respective lesson blocks, and a final `KPI_K2_SUMMARY` line at end of run. Format specifiers exactly mirror dm3's. The `duration_sec` and `evals_per_sec` fields are timing telemetry, **not** included in `k2_summary.json` (BITDET preservation).

In addition to KPI stdout, the run writes `<output_dir>/k2_summary.json`. JSON schema (`schema = "genesis_k2_v1"`):

```json
{
  "schema": "genesis_k2_v1",
  "genesis_meta": {
    "substrate": "Genesis_substrate_285v",
    "n_vertices": 285,
    "n_edges": 567,
    "bhupura_count": 282,
    "lotus_count": 3,
    "alpha_num": 164,
    "alpha_den": 165
  },
  "cfg_hash": "<sha256 of CONFIG.json>",
  "steps": <N>,
  "eta_num": 1,
  "eta_den": 5,
  "lessons": [ <LessonResult>, ... ],
  "max_scar_weight": "<%.6f>",
  "best_uplift": "<%.6f>"
}
```

`lessons` is an ordered list of `LessonResult` records, each carrying `lessons`, `max_abs_delta` (rational scientific-format string), `mean_abs_delta`, `changed_edges`, `total_edges`, and a `noise_results` list of `NoiseResult` records (`noise_num`, `noise_den`, `avg_recall_err`, `baseline_recall_err`, `uplift`, `scar_max`, `pattern_recall`).

**Determinism note:** `duration_sec` is intentionally omitted from `k2_summary.json` to preserve byte-identical output across runs. Wall-clock telemetry lives only in stdout KPI lines.

---

## What `--steps` Sweeps

`--steps N` controls the consensus-dynamics iteration count in [§Step 4](#step-4--consensus-dynamics-for-recall). Different `N` values give different `x_N` and therefore different `recall_err` values, which propagate through to `avg_recall_err`, `uplift`, and `best_uplift`. The σ″-curve is the plot of `best_uplift` versus `--steps`.

dm3 fixture σ″ table at `--steps ∈ {33, 34, 41, 42, 43, 49, 50, 56}` (from 8 sessions of receipts; see `ref-dm3-sigma-findings` in [`project_contract.json`](../project_contract.json)):

| step | dm3 best_uplift |
|---|---|
| s33 | 1.873756 (peak) |
| s34 | 1.370651 (drop) |
| s41 | 1.708374 (peak) |
| s42 | — |
| s43 | 1.160828 (drop) |
| s49 | 1.819397 (peak) |
| s50 | 0.000000 (cliff — exact zero) |
| s56 | 1.970840 (peak) |

The dm3 σ″ shape is a trimodal sawtooth with an apparent cycle period of ~7 steps and a discontinuity (cliff) at exactly s50.

The Genesis K2_SWEEP cell sweeps `--steps ∈ {20, 28, 29, …, 56}` (30 step values: 20 + 28..56). The plot of Genesis `best_uplift` over these step values is the Genesis σ″-curve. The shape of that curve — flat at 3.0, structurally varied, periodic, cliff-bearing — is the falsification surface for the four pre-registered comparisons. See [§The Pre-Registered Comparisons](#the-pre-registered-comparisons-where-k2-results-will-land).

---

## What `--test-battery` Sweeps

The `--test-battery N` flag (inherited from `genesis_cli`'s outer harness wrapping; for `snic_rust` the equivalent is the harness-driven pipeline-loop semantics in [`harness/phone/run_genesis_cell.sh`](../harness/phone/run_genesis_cell.sh)) runs the full K2 protocol `N` times. Each iter emits the same stdout KPI lines and produces the same `k2_summary.json`. Cross-iter byte-identity check: all `N` iters, on the same instance with the same `cfg_hash`, must produce identical `k2_summary.json` SHA-256.

This is **K2 task BITDET**: bit-determinism at the K2 task level, distinct from the canonical-pipeline BITDET tested in Phase 0 on `verify.json` / `solve_h2.json`. M1 host two-run BITDET confirmed at `k2_summary.json` SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`. RM10-side K2 BITDET is being confirmed live in Phase 2 cells K2_S20 and K2_S28 (per [`.gpd/STATE.md`](../.gpd/STATE.md) live observations).

---

## What `--noise` Sweeps (lesson levels)

Within a single K2 invocation, the inner loops sweep:

- **Lesson levels:** default `{0, 3}` (2 values). `L = 0` produces the baseline (no scars, `S ≡ 0`); `L = 3` produces the scarred state.
- **Noise levels:** default `{1/10, 2/10}` (2 values).
- **Patterns:** always `{Bhupura, Lotus}` (2 patterns).

This yields `2 × 2 × 2 = 8` recall computations per invocation. The dm3 sample log shows exactly 4 `KPI_K2` lines per K2 run (2 lessons × 2 noise; both patterns are folded into a single `avg_recall_err`). Genesis K2 emits the same 4 `KPI_K2` lines.

---

## Determinism Properties

The protocol is deterministic at every step:

| Stage | Determinism source |
|---|---|
| Noise pattern (Step 3) | SHA-256 of `cfg_hash ‖ lesson ‖ noise_idx ‖ pattern ‖ vertex` — same input, same byte, same flip |
| Scar arithmetic (Step 1) | BigRational addition; exact, no rounding |
| Transition matrix (Step 2) | BigRational division; exact |
| Dynamics (Step 4) | BigRational matrix-vector multiply + scalar mix; exact |
| Threshold + Hamming (Step 5) | exact `Rat` comparison and integer-valued sum |
| Aggregation | BigRational subtraction and max |
| Output formatting | f64 only for stdout `printf`; not for any value entering JSON math fields (those are formatted from `Rat`) |

Verified property: M1 host two-run check produces byte-identical `k2_summary.json` (SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`). RM10 K2 task BITDET confirmed for cells K2_S20 and K2_S28 (live observation, full-cell receipts pending pull on phone reconnect).

---

## The Pre-Registered Comparisons (where K2 results will land)

The four pre-registered comparisons are formal claims in [`project_contract.json`](../project_contract.json) and are the falsification surface for the experiment. Each comparison is anchored to the dm3 fixture observable and discriminates substrate-attributed vs augmentation-attributed origin.

| # | Comparison | dm3 anchor | Genesis hypothesis | Falsification criterion | Current verdict |
|---|---|---|---|---|---|
| 1 | **Cycle-7 attribution** (`claim-cycle7-attribution`) | dm3 σ″ peaks every ~7 steps (s33, s41, s49, s56; Δ = 8) | Genesis K2 σ″ has dominant period 7 if substrate-attributed (T(3,21) seven full twists in `(σ₁σ₂)²¹` carry into K2 dynamics) | Lomb-Scargle 95% CI on 30-point series includes 7 AND excludes 6 and 8; OR cycle-disambiguator sweep shows lowest within-set σ at multiples of 7 | **PENDING** — Phase 2 K2_SWEEP receipts pending; cycle-disambiguator load-bearing if Lomb-Scargle CI is wide |
| 2 | **s50-cliff attribution** (`claim-s50cliff-augmentation`) | dm3 `best_uplift = 0.000000` at exactly s50 (geometry-independent across SriYantra and RandomAdj per dm3 G.2 cfg-A) | Genesis does NOT cliff at s50 if augmentation-attributed (operator's positive prediction) | `best_uplift @ s50` differs from neighboring (s49, s51) by < 5%; OR `best_uplift @ s50 > 0.000100` | **EARLY-SIGNAL** — Genesis K2 host @ `--steps 30` returns `best_uplift = 3.0`; if constant across the full sweep, no cliff at s50 (degenerate-K2 scenario); confirmation pending Phase 2 |
| 3 | **σ″-curve shape diff** (`claim-sigma-curve-diff`) | dm3 trimodal sawtooth with peaks/drops as listed above | Genesis σ″ curve is numerically distinct from dm3's per-step values; the diff `(Genesis − dm3)` is reported per step with 95% CI | Per-step diff table emitted with all 30 step values; SIGNIFICANT_DIFF flag where 95% CI does not overlap dm3 fixture | **EARLY-SIGNAL** — Genesis K2 host produces flat `best_uplift = 3.0` if Phase 1 finding holds across sweep; dm3 is varied; structurally differs |
| 4 | **D₆-vs-C₃ symmetry** (`claim-symmetry-D6vsC3`) | dm3 has C₃ rotational symmetry (no Z₂ mirror); Genesis substrate has D₆ = S₃ × Z₂ | Genesis observable sensitive to a Z₂-asymmetric mode preserves symmetry where dm3 breaks it (structural evidence for augmentation-as-symmetry-breaker) | Z₂-projection magnitude on Genesis < ε vs > ε on dm3; ε pre-registered before SYMMETRY cell | **PENDING** — Phase 2 SYMMETRY cell requires explicit Z₂-asymmetric observable design; not yet implemented |

Cross-lane framing reminder ([`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md)): comparisons #1–#4 are explicit cross-lane comparisons, justified because the operator-pre-registered hypotheses are about whether dm3's signature observables travel from a 380v C₃ substrate to a 285v D₆ substrate via algorithm class (substrate-attributed) or stay home (augmentation-attributed). They are not naïve observable equality tests.

---

## Open Questions (from the host-side N=1 result)

The Phase 1 host-side K2 run at `--steps 30` with the operator-approved D3 pattern choice yielded `best_uplift = 3.000000` and `max_scar_weight = 1.200000` (uniform across all 567 edges). These are mathematically exact under the rank-1 outer-product structure of disjoint indicator patterns; the dynamics with strong attractor recovers the patterns perfectly.

The open question this raises: **is the Genesis substrate "trivially recoverable" under K2 invocation with the D3 pattern choice (degenerate dynamics → flat σ″ curve at 3.0 across all `--steps`), or does the recovery degrade at certain step counts (richer σ″ curve)?** Phase 2 K2_SWEEP discriminates. Live Phase 2 observations as of session-end:

- K2_S20: PASS, `best_uplift = 3.000000`, K2 task BITDET (18 byte-identical `k2_summary.json` hashes per cell) confirmed.
- K2_S28: PASS, `best_uplift = 3.000000`, K2 task BITDET confirmed.

If `best_uplift` remains constant at 3.0 across the full 30-cell sweep, the Genesis K2 dynamics under the D3 pattern choice is degenerate in the sense that it has no cycle, no cliff, and no curve shape — and answers all four pre-registered comparisons with one structural signature (Genesis K2 has flat σ″ at 3.0; dm3 is trimodal at peaks 1.7–2.0; structurally differs). The substrate-attribution reading would then be: dm3's σ″ phenomena live in the augmentation layer, not the substrate.

If `best_uplift` varies with `--steps`, the Genesis K2 dynamics under D3 has real structure and the cycle-7 / s50-cliff / σ″-shape verdicts depend on the specifics. Either outcome is publishable.

Alternative pattern choices (e.g., picking two distinct size-6 orbits as Bhupura/Lotus, both small and sparse, with non-rank-1 outer products) would produce richer scar matrices and likely richer dynamics. These alternative choices are pre-registered as `Research-Deferred — Investigation Underway` in [README §Upcoming Workstreams](../README.md#upcoming-workstreams) and are conditional on the Phase 2 outcome above.

---

## Where the Algorithm is Implemented

The K2 protocol is implemented in the upstream Genesis source workspace, **not** in this `genesis_comparative` repo:

| Source | Path | Lines |
|---|---|---|
| K2 protocol | `crates/io_cli/src/k2_scars.rs` | 506 |
| Dispatch | `crates/io_cli/src/main.rs` (K2Scars enum variant + handler) | +75 (lines 37–63 CLI; 222–268 handler) |
| Workspace deps | `crates/io_cli/Cargo.toml` (`num`, `num_rational`, `num_traits`, `sha2`) | (workspace-level) |

Source workspace location: `/Users/Zer0pa/DM3/recovery/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/` (sealed seal hash prefix `a83f39e6`; READ-ONLY for this lane per [`project_contract.json`](../project_contract.json) `forbidden_estimator_families`).

Cross-compiled binary (Phase 1, with K2 dispatch):

- Binary name: `snic_rust`
- Target: `aarch64-linux-android`
- Host SHA-256: `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1`
- M1 host build SHA: same source workspace; native `aarch64-apple-darwin`

Cross-platform parity at the canonical-pipeline level (`solve_h2.json = 62897b…`) is established (Phase 0). Cross-platform parity at the K2-task level (`k2_summary.json` byte-identity between M1 and RM10) is `Active Engineering` per [README §Upcoming Workstreams](../README.md#upcoming-workstreams).
