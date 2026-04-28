# Genesis Substrate

This document is the entry point for a researcher who needs to understand **what Genesis
computes on**. Substrate identity is settled (see [What's Settled](#whats-settled)); this
experiment builds atop that settlement without re-deriving it.

---

## Identity at a Glance

| Property | Value |
|---|---|
| Vertices | 285 |
| Edges | 567 (undirected) |
| Symmetry | D₆ = S₃ × Z₂ (order 12) |
| Topology | T(3,21) torus link on T² |
| Number field | Q over Pythagorean rationals |
| Spectrum | λ_max = 3.999 (substrate spectral data; 190 distinct levels, 95 singly + 95 doubly degenerate) |
| Orbits | 48 (47 size-6 + 1 size-3 waist) |
| Cyclotomic content | Φ₇² Φ₂₁² (in link Alexander polynomial) |

---

## What's Settled

Substrate identity was established by the `substrate-reconstruction-2026-04-26` workstream,
delivered as `SHARE_2026-04-27/`. That workstream ran 5 phases (Phases 0-4) of systematic
algebraic and topological analysis on the genesis source at commit seal `a83f39e6…`.

Key operator pivot (2026-04-26): the substrate is its own mathematical object — distinct from
the dm3_runner 380-vertex graph. The genesis substrate is characterized directly from source,
not fitted from device observables.

**The following are settled anchors, not open questions for this experiment:**

- 285 vertices, 567 undirected edges (verified by edge accounting: 95×3 + 94×3 = 567)
- D₆ = S₃ × Z₂ automorphism group of order 12 (two independent nauty implementations:
  pynauty 2.8.8.1 + dreadnaut from Homebrew nauty 2.9.3)
- 48 vertex orbits: 47 of size 6, 1 of size 3 (the waist `{0, 48, 96}`)
- 95 doubly-degenerate eigenvalues: exact integer match to D₆ representation theory
  (47 size-6 orbits × 2 doublets + 1 size-3 orbit × 1 doublet = 95; §04-08 spectral cross-check)
- T(3,21) torus link topology: 10 independent methods converge (Burau + TL₃ + Hecke
  representations; SnapPy topology; Burde-Zieschang genus; Murasugi crossing formula;
  Schubert bridge index; linking matrix off-diagonal = 7)
- Number field Q over Pythagorean rationals (no f32/f64 in core crates; POLICY_CHECK.sh
  enforces this)
- Cyclotomic content Φ₇² Φ₂₁² at the **link-Alexander level** (not the graph spectrum level;
  layer separation is a confirmed finding, not an open question)

The Genesis Comparative Experiment does **not** redo substrate identification. It receives
the above as fixed anchors and builds the comparative test program on top.

---

## Topology — T(3,21) Torus Link

The genesis substrate carries the **T(3,21) torus link**: a 3-component link derived from the
B₃ braid word `w = (σ₁σ₂)²¹ = Δ¹⁴`.

Key structural facts:

- **gcd(3,21) = 3** → the link has **3 components** (one per helix strand).
- **21 = 3 × 7**: the braid exponent is 3 strands × 7 full twists. Each full twist is
  `Δ² = (σ₁σ₂)³`, so `w = (Δ²)⁷` — exactly **7 full twists** of B₃.
- **42 crossings**: derived analytically from `levels = 48`, `θ = atan2(4/5, 3/5)` —
  14 crossings per strand-pair × 3 pairs.
- **Natural embedding**: T(p,q) torus links embed standardly on the torus T² (genus 1).
  This is consistent with the substrate's topological genus g = 1, confirmed independently
  by three routes in Phase 4 (§04-06).

The **seven-twist invariant** is the direct source of the pre-registered cycle-7 hypothesis:
does Genesis K2 exhibit a dominant oscillation period of 7 steps? This question is the
primary falsification surface for the cycle-7 attribution claim (see `project_contract.json`
`claim-cycle7-attribution`). The structural derivation chain that makes "7" meaningful here is:

```
source parameter turns=4
  → levels = 12 × 4 = 48
  → B₃ crossings = 42
  → braid word w = (σ₁σ₂)²¹ = (Δ²)⁷
  → 7 full twists
  → cyclotomic factor Φ₇² in Alexander polynomial
  → 7 is structurally encoded in the link invariant, not a coincidence
```

This derivation chain is verified in `SHARE_2026-04-27/04_braid_T3-21_cyclotomic_Phi7sq_strongest_positive.md`
(Phase 4 plan 04-05, the strongest single positive finding of the substrate-reconstruction
workstream).

The braid action is written `(σ₁σ₂)²¹` in B₃ notation where σᵢ are Artin generators;
`Δ = σ₁σ₂σ₁ = σ₂σ₁σ₂` is the Garside element (half-twist) of B₃.

---

## Symmetry — D₆ = S₃ × Z₂

D₆ is the **dihedral group of order 12**, the symmetry group of a regular hexagon
(6 rotations + 6 reflections). In its S₃ × Z₂ factored form:

- **S₃** (symmetric group on 3 elements, order 6) permutes the 3 helix strands. It contains
  the C₃ cyclic rotation (`ρ`, order 3) and 3 strand-swap reflections including the generator `μ`
  (order 2).
- **Z₂** is the bindu mirror (`ζ`), the reflection `z ↔ −z` that swaps the two cones.
  It commutes with all elements (central in D₆).

Together: `D₆ = ⟨ρ, μ, ζ | ρ³ = μ² = ζ² = 1, ρμ = μρ⁻¹, ζ central⟩`.

The automorphism group was computed by two independent implementations of nauty (pynauty
CPython binding and dreadnaut standalone) and confirmed by element-order multiset classification
against the 5 order-12 groups. The multiset `{1:1, 2:7, 3:2, 6:2}` uniquely matches D₆;
the other candidates (Z₁₂, Z₆×Z₂, A₄, Dic₃) all predict different element-order multisets.
The identification is corroborated by |Z(G)| = 2 (only D₆ and Dic₃ have center of order 2;
Dic₃ is excluded by the order-4 elements which D₆ lacks).

**H6 verdict from substrate-reconstruction:** `EXTENDED-D6`. The prior STATE.md predicted
Z₂ × C₃ (order 6) from the spectral pattern. The actual group is one index-2 coset larger:
the strand-swap μ ∈ S₃ is an automorphism that acts within the three strands, beyond the
simple cyclic permutation. The predicted group Z₂ × C₃ is an index-2 subgroup of D₆.

**Note on the fixture's `group_structure_name` field:** `inputs/substrate_285v.json` records
`"group_structure_name": "order-12 group (Z_12 / Z_6xZ_2 / D_6 / A_4 / Dic_3) — see generator
structure"`. This reflects the conservative notation used when generating the fixture, listing
all 5 candidates of order 12. The element-order-multiset classification in Phase 4 (§04-08)
uniquely narrows this to D₆; the `group_structure_name` was not updated after that analysis.
The working identity for all computations is D₆ = S₃ × Z₂.

---

## Number Field — Q over Pythagorean Rationals

Every numerical computation in the Genesis source operates over **exact rational arithmetic**
using `num_rational::BigRational`. There are no floating-point numbers in any core computational
path.

**POLICY_CHECK.sh** (`scripts/POLICY_CHECK.sh`) enforces this statically. It greps for
`f32`/`f64` in the crates `yantra_2d`, `lift_3d`, `dynamics_deq`, `geometry_core`,
`invariants`, `proof_gates` and exits 14 if any float types are found. It separately greps
for `rand::`, `thread_rng`, `StdRng`, `ChaCha` across all crates and exits 13 on any match.
Policy check result for the canonical workspace: **PASS**.

**"Pythagorean rationals"** refers to the geometric origin of the specific rational values used.
The canonical rotation parameter `rotation_t = 1/2` (hardcoded in `lift_3d/src/lib.rs:319`)
generates the Pythagorean pair:

```
cos = (1 − t²)/(1 + t²) = (1 − 1/4)/(1 + 1/4) = 3/5
sin = 2t/(1 + t²) = 2·(1/2)/(5/4) = 4/5
```

The CONFIG.json parameters also use Pythagorean rationals: `lift_3d.base_radii = ["1/1","2/1","3/1"]`,
`rotation_t = "1/2"`, `rotor_t_half = "1/3"`, `pitch = "1/1"`. These generate the number
field Q — rationals, without any irrational or transcendental extension. There are no √2, φ,
π, or e anywhere in the canonical computation path.

Example from `dynamics_deq/src/lib.rs:122-123`:

```rust
let alpha = Rat::new(BigInt::from(164), BigInt::from(165));
let one_minus_alpha = Rat::new(BigInt::one(), BigInt::from(165));
```

The spectral bound 164/165 is stored exactly; `0.993939...` is never computed.

The `QsqrtD` type defined in `geometry_core` (a quadratic-extension type for Q[√d]) has
**zero call sites** in the canonical pipeline. Kulaichev's φ-encoding claim does not apply to
this encoding. The substrate lives entirely over Q.

---

## Orbit Decomposition (47 + 1)

Under D₆ action, the 285 vertices partition into **48 orbits**:

- **47 orbits of size 6** — each vertex in these orbits has a point-wise stabilizer of order
  12/6 = 2 (one of the 7 involutions in D₆ fixes that vertex).
- **1 orbit of size 3** (the waist) — the three bindu vertices `{0, 48, 96}` have stabilizer
  of order 12/3 = 4 (the Klein four-subgroup ⟨μ, ζ⟩ containing both the strand-swap and the
  bindu mirror).

Conservation check: 47 × 6 + 1 × 3 = 282 + 3 = **285** ✓

**First 5 size-6 orbits** (from `inputs/substrate_285v.json`):

| Orbit index | Vertices |
|---|---|
| 0 (level L1) | `[1, 49, 97, 144, 191, 238]` |
| 1 (level L2) | `[2, 50, 98, 145, 192, 239]` |
| 2 (level L3) | `[3, 51, 99, 146, 193, 240]` |
| 3 (level L4) | `[4, 52, 100, 147, 194, 241]` |
| 4 (level L5) | `[5, 53, 101, 148, 195, 242]` |

Each size-6 orbit groups 3 vertices from the plus-cone and 3 from the minus-cone at the same
level index — the bindu mirror ζ swaps cones, and S₃ acts transitively on the 3 strands
within each cone.

**The waist orbit** `{0, 48, 96}` is the single size-3 orbit. These are the three z=0 bindu
vertices, mutually adjacent (the waist is a triangle, not a point or path). The bindu mirror ζ
fixes all three (z=0 maps to z=0). The waist's mirror-fixed and singular-center nature makes
it the natural **Lotus** analog (per Decision D3 in `project_contract.json`). The 282 vertices
across the 47 size-6 orbits form the **Bhupura** pattern.

**Spectral cross-check:** D₆ has two 2-D real irreducible representations. Under the permutation
representation on the 285 vertices, each size-6 orbit contributes 2 doubly-degenerate eigenvalue
pairs, and the size-3 waist orbit contributes 1. Total doublets: 47 × 2 + 1 = **95 predicted**.
Observed doubly-degenerate eigenvalues: **95** — exact integer match.

---

## The Fixture — inputs/substrate_285v.json

The substrate is distributed as a self-contained JSON fixture at `inputs/substrate_285v.json`.
Schema:

```json
{
  "schema_version": 1,
  "name": "Genesis_substrate_285v",
  "source": "...path to substrate-reconstruction NPZ + orbit_decomposition...",
  "n_vertices": 285,
  "n_edges": 567,
  "edges": [[i, j], ...],
  "orbits": [[v0, v1, ...], ...],
  "orbit_size_counts": {"6": 47, "3": 1},
  "waist_orbit": [0, 48, 96],
  "bhupura_pattern_indices": [282 vertex indices — union of all 47 size-6 orbits],
  "lotus_pattern_indices": [0, 48, 96],
  "aut_order": 12,
  "group_structure_name": "order-12 group — see §Symmetry note above"
}
```

This fixture is the **load-bearing input for K2**. The subcommand:

```
snic_rust k2-scars --substrate inputs/substrate_285v.json --steps N
```

reads the fixture, runs K2 dynamics on it, and emits `artifacts/k2_summary.json`. Substrate
identity is baked into the fixture; it is not re-derived at runtime.

The fixture was produced from `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/06_substrate_285vert_adjacency.npz`
(the NPZ adjacency matrix) combined with `04-08_orbit_decomposition.json` (the orbit data from
the nauty automorphism computation).

---

## Why This Substrate Matters

The Genesis substrate is **fully specified by source**: a 285-vertex graph constructed from
exact Pythagorean rational coordinates via a deterministic 4-step pipeline (build-2d → lift-3d
→ solve-h2 → verify). Every vertex coordinate, every edge, every eigenvalue is computable to
arbitrary precision from `CONFIG.json` with no floating-point rounding. The number field is Q.

This is **not a measured graph**. It is a **constructed graph**. The consequence is that the
byte-identical canonical output property (determinism across hardware, thermal, and time) is
a **necessary consequence** of the construction discipline — not a target to engineer separately.
If two machines both run exact rational arithmetic on the same input, they produce the same
output; there is no other possible outcome.

This matters for the comparative experiment in two ways:

1. **Falsifiability**: every Genesis K2 observable is exactly reproducible. The 95% CI in
   K2_SWEEP receipts reflects genuine sweep variance (different `--steps` values, different
   noise patterns), not measurement noise. Comparing Genesis observables to dm3_runner's
   fixtures is comparing two well-defined numbers, not two noisy estimates.

2. **Attribution**: the substrate is fully characterized (T(3,21), D₆, Q, 285v). When Genesis
   and dm3_runner produce different observables, the substrate distinction is a candidate
   explanation that can be tested. The cycle-7 attribution claim specifically asks whether the
   T(3,21) seven-twist structure — shared by both substrates at the braid layer — is visible
   in K2 dynamics.

---

## What's NOT Settled (Honest Boundaries)

The following remain open despite the substrate identity being settled:

- **Exact isomorphism class of the order-12 group.** The group is confirmed to be order 12
  with element-order multiset {1:1, 2:7, 3:2, 6:2} and |Z(G)| = 2, non-abelian — all
  consistent uniquely with D₆. However the `group_structure_name` field in the fixture lists
  multiple order-12 candidates as notation; formal group-isomorphism class verification via
  a GAP `IdGroup` computation against the specific generator matrices was not completed in
  Phase 4. The working identity D₆ = S₃ × Z₂ = SmallGroup(12,4) is supported by the
  element-order fingerprint; this classification should be treated as HIGH-confidence but
  not formally certified at the GAP level.

- **Bhupura/Lotus pattern choice validity for K2.** The mapping of 47 size-6 orbits →
  Bhupura, 1 size-3 waist → Lotus is pre-registered (Decision D3) but not yet validated.
  Phase 1 host-side K2 result shows uniform |scar| = 1.2 across all 567 edges and perfect
  recall, which is consistent with a degenerate K2 regime caused by the rank-1 structure of
  the disjoint Bhupura+Lotus outer products. Phase 2 K2_SWEEP will test whether this is a
  genuine uniform-dynamics effect or an artifact of the pattern choice.

- **Anomalous deg-3 vertices.** Six vertices (the helix tips, forming a single size-6 orbit
  at level L47: `{47, 95, 143, 190, 237, 284}`) have degree 3 vs the bulk degree 4. Their
  role in the Sri Yantra geometric interpretation (which physical structure they correspond to)
  is not fully resolved in the substrate-reconstruction literature.

- **Spectral cross-check formal derivation.** The 95+95 doublet structure is established
  empirically (eigenvalue computation) and matched to the D₆ representation theory counting
  argument (§04-08 spectral cross-check). A formal irrep-by-irrep Frobenius reciprocity
  calculation — identifying which specific singlet/doublet pair falls at each eigenvalue level
  for each of the 47+1 orbits — has not been completed.

- **Whether λ_max = 3.999 is exactly 4 in the Galois closure.** The substrate is nearly
  4-regular (279 deg-4 + 6 deg-3 vertices). Spectral perturbation theory would give
  λ_max = 4 − c/N + O(1/N²). Whether c is an exact integer — making λ_max exactly
  4 − integer/285 — is a Phase 5 open question (substrate-reconstruction §5.4).

---

## How Genesis Differs from dm3_runner

These are different mathematical objects on different computational lanes.
Cross-lane comparison is the **falsification surface** of this experiment, not an
attempt to claim equivalence. All numerical comparisons must be explicitly framed
as Genesis-vs-dm3_runner with the lane distinction stated (per `LANE_DISTINCTION.md`).

| Property | Genesis (this lane) | dm3_runner (sibling lane) |
|---|---|---|
| Vertices | 285 | 380 |
| Symmetry | D₆ = S₃ × Z₂ (order 12) | C₃ (order 3) |
| λ_max | 3.999 | 7.999 |
| Source | Open Rust workspace (`snic_workspace_a83f`) | Unrecovered closed binary |
| Substrate identity | Settled (this doc) | NOT YET settled |
| Methodology | Forward: source → binary → observables | Backward: device observables → geometry |
| K2 best_uplift @ s30 | 3.000000 (Phase 1 host) | 1.644524 (dm3 sample log) |
| K2 max_scar @ s30 | 1.200000 (uniform, all 567 edges) | 0.868061 (varied; 1892/4560 edges changed) |
| Torus link | T(3,21) — 3 components, 7 full twists | Not yet determined |
| Build target | aarch64-apple-darwin (M1) + aarch64-linux-android (RM10) | aarch64-linux-android ELF only (RM10) |

The Genesis K2 uniform-scar result at s30 (|scar|=1.2 on every edge, perfect recall) is
mathematically distinct from dm3_runner's varied-scar, partial-recall result. Whether this
difference is substrate-attributable (D₆ vs C₃; 285v vs 380v) or pattern-choice-attributable
(the D3 Bhupura/Lotus orbit selection makes Genesis K2 trivially recoverable) is the open
question Phase 2 K2_SWEEP will discriminate.

---

## References

- [`../inputs/substrate_285v.json`](../inputs/substrate_285v.json) — the fixture (load-bearing input for K2)
- [`../proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md) — substrate authority record
- `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` — settled-identity authority bundle (5-phase workstream)
  - `01_ADVISORY_executive.md` — executive summary
  - `02_phase3_NEAR_MATCH_substrate_identification.md` — catalogue identity (P₉₅ ⋉_α Z₃)
  - `03_phase4_substrate_algebraic_topological_identity.md` — algebraic/topological content
  - `04_braid_T3-21_cyclotomic_Phi7sq_strongest_positive.md` — T(3,21) + Φ₇² derivation
  - `05_aut_D6_with_spectrum_crosscheck.md` — D₆ automorphism + 95-doublet spectral cross-check
- [`../LANE_DISTINCTION.md`](../LANE_DISTINCTION.md) — Genesis vs dm3_runner formal separation
- [`../project_contract.json`](../project_contract.json) — formal contract; substrate identity claims; cycle-7 / s50 / symmetry / σ″ pre-registered comparisons
