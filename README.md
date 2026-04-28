# Genesis — Comparative Determinism Experiment

*A deterministic computational organism on a settled mathematical substrate.*

---

Most computation runs on IEEE-754 floats and asks how to bound the error. Genesis asks the inverse: pick a settled algebraic substrate (a 285-vertex graph with full automorphism group `D_6 = S_3 × Z_2`, topology `T(3,21)` torus link on `T²`, number field `Q` over Pythagorean rationals — no floats in the math path) and measure whether non-trivial dynamics on it are byte-identically reproducible across hardware, thermal conditions, time, and re-execution. The first measurement returned **1560/1560 cross-replicate `verify.json` SHA-256 hashes byte-identical to the source-hardcoded canonical `97bd7d…`** on commodity Android (RM10, aarch64), with zero divergence across 60+300+1200 invocations on cpu0–cpu5; an additional 30000 BITDET_5K invocations are live-passed in the on-device chain log but their receipts are pending pull and must not be conflated with the 1560 settled. What is open: Phase 2 K2_SWEEP, plus four pre-registered comparisons against the parked `dm3_runner` lane (cycle-7 attribution, s50-cliff attribution, σ″-curve shape, D₆-vs-C₃ symmetry — three PENDING, one EARLY-SIGNAL with a pattern-degenerate alternative reading explicitly preserved in `project_contract.json` `uncertainty_markers`). Both outcomes — confirmation and falsification — are publishable; that posture is the whole point.

---

## What This Is

Genesis is a research artifact: a pure-rational deterministic dynamical system on a settled mathematical substrate, exercised on commodity hardware to ask whether **non-trivial computation can be byte-identically reproducible across hardware, thermal conditions, time, and re-execution**. The current RM10 (Android, aarch64) proof surface contains **31,560/31,560 Phase 0 `verify.json` SHA-256 hashes byte-identical to the source-hardcoded canonical `97bd7d…`** across four BITDET cells (10×6, 50×6, 200×6, 5000×6 invocations on cpu0–cpu5). Cross-platform parity is established at the canonical-pipeline level: `solve_h2.json = 62897b…` matches byte-exact between the M1 host build and the RM10 cross-compiled build of the standalone `snic_rust` pipeline. Phase 2 and 2.5 add 56 K2-task cells, all PASS with `unique_canonical_sha_count = 1`, and the aggregated σ″ curve in [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv).

Genesis IS: a deterministic Rust pipeline (`build-2d → lift-3d → solve-h2 → verify`) over `Q` (rationals; no floats in the math path), driven by a sealed [`configs/CONFIG.json`](inputs/substrate_285v.json), running standalone on Android with no host scripting, no `cargo`, no source tree on device. Genesis IS NOT: a codec, a productized service, a unified platform, or a portfolio-wide architecture. The `genesis_comparative` workstream is one research artifact in the Zer0pa portfolio under SAL v7.0; it scopes to the four pre-registered comparisons enumerated in §"The Falsification Surface" below and nothing more.

**Honest blocker:** the experiment is live, not frozen. Phase 0, Phase 1, Phase 2, and Phase 2.5 receipts are in the repo; Phase 3 prep is running on RM10 to extend cross-time K2 evidence at S1..S9 plus S30/S56. Three of the four pre-registered comparisons now have receipt-backed verdicts; the D6-vs-C3 symmetry comparison remains PENDING because the Z2-asymmetric observable has not yet been implemented. Treat the repo as a live window into the work, with future receipts appended rather than rewritten.

Category: research artifact in the Zer0pa portfolio under SAL v7.0 (`LicenseRef-Zer0pa-SAL-7.0`); settled-substrate dynamics on a 285-vertex graph; comparative methodology against a sibling lane (`dm3_runner`, parked, source-unrecovered) — see [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md).

---

## The Substrate

The substrate is settled at the algebraic-topological level by the prior workstream `substrate-reconstruction-2026-04-26`. Genesis does not re-derive it.

| Property | Value |
|---|---|
| Graph | 285 vertices, 567 edges, 48 D₆ orbits (47 size-6 + 1 size-3 waist) |
| Symmetry group | D₆ = S₃ × Z₂ (full automorphism group of the substrate) |
| Topological identity | T(3,21) torus link on T² — seven full twists in `(σ₁σ₂)²¹` |
| Number field | `Q` over Pythagorean rationals (no floating-point in math path) |
| Spectral fingerprint | 190 distinct eigenvalue levels; λ_max = 3.9989; Fiedler = 0.001071; Z₂ mirror (95 singly + 95 doubly degenerate) |
| Source | `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` (lanes 01, 04, 05) |

The substrate fixture used by the K2 port is committed at [`inputs/substrate_285v.json`](inputs/substrate_285v.json) (285 vertices, 567 edges, 48 D₆ orbits, Bhupura/Lotus pattern indices baked in per decision D3).

The substrate identification is read directly from the open Genesis source — `crates/io_cli/src/main.rs` constructs the graph and computes the canonical pipeline; the canonical hashes `CANONICAL_VERIFY_HASH = 97bd7d…` and `CANONICAL_SOLVE_HASH = 62897b…` are hardcoded in `crates/genesis_cli/src/main.rs`. The Genesis Comparative experiment treats those substrate facts as anchors, not open questions.

---

## What's Demonstrated

Each item below is anchored to a path in this repository or to a logged decision in [`.gpd/STATE.md`](.gpd/STATE.md). Raw receipt authority for current numerical claims is under [`proofs/artifacts/cells/`](proofs/artifacts/cells/) and [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv).

- **Bit-determinism on RM10 (Phase 0 BITDET cells)** — 4 cells × 6 cores × {10, 50, 200, 5000} iterations = **31,560 cross-checked `verify.json` hashes, all equal to source-canonical `97bd7d…`**. `unique_canonical_sha_count = 1` per cell. Mirror of dm3_runner's claim ξ.
- **Cross-platform canonical match (M1 ↔ RM10)** — the same `snic_rust` pipeline produces byte-identical `solve_h2.json` SHA `62897b…` on both `aarch64-apple-darwin` (M1 host) and `aarch64-linux-android` (RM10). Hash-gate disposition for `verify.json` documented at [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md): the M1-side `e8941414…` vs source-hardcoded `97bd7d…` diff is a serialization-layer trailing-newline artifact (`VERIFY_SUMMARY.json = 8ddb…` reproduces identically; all 7 internal gates pass; `solve_h2.json` matches exactly). Mirror of dm3_runner's claim τ at the canonical-pipeline level.
- **Source-canonical match on RM10** — RM10 cross-compiled `snic_rust` reproduces source-hardcoded `CANONICAL_VERIFY_HASH = 97bd7d…` and `CANONICAL_SOLVE_HASH = 62897b…` byte-exact (no BENIGN diagnosis required on the device side; Phase 0 plan 00-06 verdict).
- **All 7 internal verification gates pass** on every Phase 0 invocation: `gates_ok`, `dep_cert`, `gc_invariants`, `lift`, `stab`, `cad_sos`, `egraph`.
- **K2 port lands on host and RM10 (Phase 1+)** — `k2-scars` subcommand of `snic_rust`, all numeric work via `num_rational::BigRational` (no f32/f64 in math path; floats only for `printf`); two consecutive host `k2-scars --steps 30` runs produce byte-identical `k2_summary.json` SHA `0b5442f9…`; Phase 2/2.5 RM10 cells preserve per-cell K2 BITDET with `unique_canonical_sha_count = 1`.
- **σ″ curve receipts (Phase 2/2.5)** — 60 total receipt cells are in [`proofs/artifacts/cells/`](proofs/artifacts/cells/), all PASS. The Genesis K2 σ″ curve is flat at `best_uplift = 3.000000` across S20 and S28..S56, with a pre-convergence transient peaking at S2 = 6.5 and settling to 3.0 by S10.

---

## The Falsification Surface (Pre-registered Comparisons)

Four comparisons against the closed `dm3_runner` binary's signature observables were pre-registered in [`PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`](PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md) §"Pre-registered, falsifiable" and formalized as claims in [`project_contract.json`](project_contract.json). Both positive and negative results are equally valued.

This is a **cross-lane** falsification surface in the sense of [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md): the Genesis lane (285v, D₆, T(3,21), source-available) and the dm3_runner lane (380v, C₃, source-unrecovered) are different mathematical objects. The four comparisons probe whether dm3's signature observables are substrate-attributed (and would carry to Genesis) or augmentation-layer-attributed (and would not).

| # | Comparison | Hypothesis | Falsification | Verdict |
|---|---|---|---|---|
| 1 | **Cycle-7 attribution** (claim `claim-cycle7-attribution`) | Genesis K2 σ″ curve has dominant period 7 (substrate-attributed: T(3,21) seven twists carry through to dynamics) | Genesis cycles at period 6, 8, or aperiodic (augmentation-attributed) | **AUGMENTATION-ATTRIBUTED** — Genesis is flat at 3.0 from S20 through S56; cycle-probe cells at S12+ are all 3.0; no cycle-7 structure is visible in Genesis K2 under D3 |
| 2 | **s50-cliff attribution** (claim `claim-s50cliff-augmentation`) | Genesis does NOT cliff at `--steps=50` with `best_uplift = 0.000000` (cliff is augmentation-class) | Genesis also cliffs at exactly s50 = 0.000000 (substrate-class) | **CONFIRMED** — K2_S49, K2_S50, and K2_S51 all return `best_uplift = 3.000000`; Genesis does not cliff at s50 |
| 3 | **σ″-curve shape diff** (claim `claim-sigma-curve-diff`) | Genesis σ″ curve is numerically distinct from dm3's fixture table at one or more pre-registered step values | Tabulated diff (Genesis − dm3) reported per step with 95% CI | **CONFIRMED** — Genesis is flat at `3.000000` across [S20, S56] while dm3 is a trimodal sawtooth with exact-zero cliff at S50 |
| 4 | **D₆-vs-C₃ symmetry** (claim `claim-symmetry-D6vsC3`) | Genesis is observably mirror-symmetric (Z₂-projection ≈ 0) where dm3 is mirror-broken (C₃ ⊂ D₆); structural evidence for augmentation-as-symmetry-breaker | Genesis is also mirror-broken despite D₆ substrate | **PENDING** — Z₂-asymmetric observable on Genesis substrate must be designed and pre-registered before a SYMMETRY cell; Monte Carlo baseline mandatory |

dm3_runner fixture values used as comparison anchors (from 8 sessions of receipts; see `ref-dm3-sigma-findings` in [`project_contract.json`](project_contract.json)): trimodal sawtooth peaks at s33=1.873756, s41=1.708374, s49=1.819397, s56=1.970840; drops at s34=1.370651, s43=1.160828; cliff at s50 = exactly 0.000000; period ~7 steps.

The flat σ″ result settles the three K2-shape comparisons under the operator-approved D3 pattern choice, but it does not prove why Genesis is flat. The honest caveat remains: `best_uplift = 3.000000` with uniform `|scar| = 1.2` may reflect (a) the D6 substrate making K2 trivially recoverable, or (b) a degenerate pattern choice from D3 (rank-1 effect of disjoint Bhupura(282)+Lotus(3) outer products). Phase 2.5 shows the dynamics is not a toy constant: S1..S9 contain a real pre-convergence transient, peaking at S2 = 6.5 and settling by S10.

---

## Sibling Lane — DM3

Genesis and DM3 are two graphs related by one discrete arithmetic step on the same 95-station path base. The Genesis substrate is `P_95 ☐ K_3` (285 vertices, 567 edges, 96 triangular faces, `Aut = D_6` of order 12); the DM3 loaded fixture is `P_95 ☐ K_4` (380 vertices, 946 edges, `Aut = C_2 × S_4` of order 48); the two are connected by complete-graph fiber promotion `K_3 → K_4`. The Genesis 285-vertex substrate is **bit-identical** to the DM3 internal default skeleton — the graph that `Dm3State::initialize → build_helix_meru → build_dual_meru` constructs when no fixture is loaded — so Genesis is, by construction, a source-available falsifiable instance of DM3's `K_3` surface. The relationship is lateral, not subordinate: same path base, same upstream Rust pipeline (`yantra_2d → lift_3d → yantra_3d_dual`), with the source-built mesh authority byte-identical between the two geometry bundles at `dual_meru_mesh.ply` SHA `7ee17457b7daeec565bb1e06982b8a1facd8169f` and `dual_meru_yantra_2d.svg` SHA `a1dbf572167960b9bd348d392d3405b1114db1ef`. DM3's `R8` Tier-3 live runtime trace remains `OPEN_TIER3_BLOCKED` and is the open authority gate on the K_4 side; the four pre-registered comparisons in §"The Falsification Surface" probe whether DM3's signature observables (cycle-7, s50-cliff, σ″-curve shape, C_3 mirror-breaking) are substrate-attributed (would carry to Genesis on K_3) or augmentation-attributed (would not). Cross-repository pointer: [`Zer0pa/DM3`](https://github.com/Zer0pa/DM3) (public).

---

## Proof Anchors

Every path below resolves in this repository at the time of writing. Receipt authority for the current inspection branch lives under `proofs/`; Phase 3 prep receipts will append to this surface when the live RM10 chain completes.

| Path | What it carries |
|---|---|
| [`PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`](PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md) | Operator's source-of-truth PRD; four pre-registered comparisons; test program; deployment recipe; boundaries |
| [`project_contract.json`](project_contract.json) | 12-key formal contract: 6 claims, 7 observables, 9 acceptance tests, 7 forbidden proxies, 9 references, 6 deliverables; uncertainty markers |
| [`RESISTANCE.md`](RESISTANCE.md) | Four named corruptions binding for all agents on this lane (rush-to-green-flag, NULL-as-out, efficiency-as-corner-cutting, flattery-as-freedom); re-engagement gate |
| [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md) | Formal separation of Genesis (285v, D₆) from dm3_runner (380v, C₃, parked); Resolution clause for Phase A anchors |
| [`.gpd/PROJECT.md`](.gpd/PROJECT.md) | Project goals, scope, hard constraints, deliverables, out-of-scope |
| [`.gpd/STATE.md`](.gpd/STATE.md) | GPD state ledger: Phase 0/1 decisions, retractions, historical session continuity |
| [`.gpd/ROADMAP.md`](.gpd/ROADMAP.md) | Phase decomposition (0–3); plan checklist |
| [`inputs/substrate_285v.json`](inputs/substrate_285v.json) | 285-vertex substrate fixture: vertices, 567 edges, 48 D₆ orbits, Bhupura/Lotus pattern indices |
| [`harness/phone/`](harness/phone/) | Six-script chain harness: `run_genesis_cell.sh`, `launch_genesis_batch.sh`, `thermal_coordinator.sh`, `genesis_chain_v1.sh`, `master_watcher.sh`, `resume_chain.sh` |
| [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md) | D1 BENIGN diagnosis for M1 verify.json `e894…` vs source-hardcoded `97bd7d…`; halt-on-out-of-family-mismatch protocol |
| [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md) | Current authority packet for the inspection branch: substrate, hashes, receipt counts, verdicts, and live open items |
| [`proofs/artifacts/cells/`](proofs/artifacts/cells/) | 60 RM10 cells, all PASS, all `unique_canonical_sha_count = 1` |
| [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv) | 61-line aggregated Phase 2 + 2.5 σ″ curve table |
| [`proofs/artifacts/figures/sigma_curve.png`](proofs/artifacts/figures/sigma_curve.png) | Two-panel headline figure for the Genesis σ″ curve and dm3 comparison anchors |
| [`LICENSE`](LICENSE) | Zer0pa Source-Available License v7.0 canonical text |
| [`CITATION.cff`](CITATION.cff) | Machine-readable citation metadata |

External references that anchor the substrate identity (read-only authority):

- `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/01_ADVISORY_executive.md` — substrate-identification executive advisory
- `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/04_braid_T3-21_cyclotomic_Phi7sq_strongest_positive.md` — T(3,21) / Φ₇²·Φ₂₁² cyclotomic identification
- `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/05_aut_D6_with_spectrum_crosscheck.md` — D₆ automorphism group with full-spectrum crosscheck (47 size-6 + 1 size-3 orbit decomposition)

---

## Reproduce

Full procedure: [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md). Sketch:

```bash
# 1. Cross-compile snic_rust for RM10 (aarch64-linux-android24)
export NDK=/usr/local/share/android-ndk
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android24-clang
export CC_aarch64_linux_android=$CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER
export AR_aarch64_linux_android=$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar
cargo build --release --target aarch64-linux-android -p io_cli --bin snic_rust

# 2. Deploy to RM10 (cpu0–cpu5; cpu7 is dm3_runner's; cpu6 thermal margin)
adb -s FY25013101C8 push target/aarch64-linux-android/release/snic_rust /data/local/tmp/genesis/
adb -s FY25013101C8 push harness/phone/*.sh /data/local/tmp/genesis/harness/
adb -s FY25013101C8 shell chmod +x /data/local/tmp/genesis/snic_rust /data/local/tmp/genesis/harness/*.sh

# 3. Smoke-test bit-determinism (single core)
adb -s FY25013101C8 shell taskset 0x01 /data/local/tmp/genesis/harness/run_genesis_cell.sh BITDET_SMOKE

# 4. Verify the canonical hash
adb -s FY25013101C8 shell sha256sum /data/local/tmp/genesis/cells/BITDET_SMOKE/verify.json
# Expected: 97bd7d... (source-hardcoded CANONICAL_VERIFY_HASH)

# 5. Launch the autonomous chain (resume-safe; dm3_runner on cpu7 is untouched)
adb -s FY25013101C8 shell /data/local/tmp/genesis/harness/resume_chain.sh
```

The hash-gate must match before any cell of substantive work runs. Halt and consult [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md) on any out-of-family mismatch.

---

## Repository Layout

```
genesis_comparative/
├── README.md                              this file
├── LICENSE                                SAL v7.0 canonical text
├── CITATION.cff                           machine-readable citation
├── REPRODUCIBILITY.md                     reproduction recipe (full)
├── SECURITY.md                            vulnerability reporting
├── CONTRIBUTING.md                        contribution rules
├── CHANGELOG.md                           public delta log
│
├── PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md   research surface (PRD)
├── project_contract.json                  research surface (formal claims)
├── RESISTANCE.md                          research surface (corruption protocol)
├── LANE_DISTINCTION.md                    research surface (Genesis vs dm3_runner)
│
├── .gpd/
│   ├── PROJECT.md                         goals, scope, constraints
│   ├── ROADMAP.md                         phases 0–3
│   ├── STATE.md                           live state, retractions, decisions
│   └── state.json                         GPD machine-readable mirror
│
├── inputs/
│   └── substrate_285v.json                substrate fixture (285v, 48 orbits)
│
├── harness/
│   ├── host/
│   │   └── HASH_GATE_DISPOSITION.md       D1 BENIGN diagnosis
│   └── phone/
│       ├── run_genesis_cell.sh            per-invocation harness
│       ├── launch_genesis_batch.sh        N parallel invocations, cpu0–5 mask
│       ├── thermal_coordinator.sh         70°C ceiling, SIGSTOP/SIGCONT
│       ├── genesis_chain_v1.sh            resume-safe master orchestrator
│       ├── master_watcher.sh              watchdog, 30s poll
│       ├── resume_chain.sh                idempotent re-launch
│       └── cells.txt                      cell manifest
│
├── proofs/                                authority packet, receipts, sigma curve
│   ├── manifests/CURRENT_AUTHORITY_PACKET.md
│   └── artifacts/
│
├── artifacts/                             pulled receipts (per chain close)
│
└── reports/                               substrate-reconstruction reports
                                           (Genesis final report at chain close)
```

Surfaces:
- **Research:** PRD, RESISTANCE, LANE_DISTINCTION, project_contract, .gpd/
- **Engineering:** harness/, inputs/, proofs/ (receipt authority), artifacts/
- **Policy:** LICENSE, CITATION.cff, REPRODUCIBILITY.md, SECURITY.md, CONTRIBUTING.md, CHANGELOG.md, README.md

---

## Upcoming Workstreams

This section captures the active lane priorities — what the next agent or contributor picks up, and what investors should expect. Cadence is continuous, not milestoned.

- **Phase 3 prep receipts pull** — `Active Engineering`. The live RM10 manifest extends cross-time evidence for S1..S9 and S30/S56. Do not touch the phone chain; pull and commit receipts after the chain operator confirms completion.
- **Phase 3 synthesis and final report** — `Active Engineering`. Renders the four pre-registered comparison verdicts with acceptance-test evidence; final report at `reports/GENESIS_FINAL_REPORT_<DATE>.md`; Genesis-side appendix with σ″-curve diff vs dm3, cycle-period verdict, cliff-presence verdict, symmetry-test verdict — no cross-lane editorial in the appendix itself.
- **Cross-platform parity at K2-task level** — `Active Engineering`. Current parity is established at the canonical-pipeline level (`solve_h2.json`); extending to byte-identity for `k2_summary.json` between M1 host and RM10 remains a small host-side comparison task.
- **Z2-asymmetric SYMMETRY observable** — `Research-Deferred — Investigation Underway`. Comparison #4 remains PENDING until the observable is designed, pre-registered, and run with a Monte Carlo baseline.
- **Bhupura/Lotus pattern choice (the rank-1 degenerate-K2 question)** — `Research-Deferred — Investigation Underway`. Phase 2 confirms flat steady-state behavior under D3, while Phase 2.5 confirms a non-trivial pre-convergence transient. Alternative D6 orbit picks are the next investigation for separating substrate-easy from pattern-degenerate explanations.
- **Cross-substrate K2 with alternative D6 orbit picks** — `Research-Deferred — Investigation Underway`. Alternative orbit pairings (e.g., partitioning the 47 size-6 orbits differently, or using non-disjoint pattern supports) become the second-pass design.
- **Sibling lane source recovery (`dm3_runner`)** — `Operations / External Dependency`. dm3_runner's source has not been recovered; it is a separate workstream. Genesis comparisons against the closed dm3_runner binary stand on the eight sessions of dm3 receipts and the σ″ fixture table; full attribution analysis on the dm3 side is gated on source recovery in that lane and is out of scope here.

---

## Methodology + Discipline

The work is governed by:

- [`RESISTANCE.md`](RESISTANCE.md) — four named corruptions (rush-to-green-flag, NULL-as-out, efficiency-as-corner-cutting, flattery-as-freedom); plus the lane-specific `fp-shapematchRE` (spectral match ≠ identity; three-tier evidence required for any attribution claim) and `fp-counterfactual-prd-premise` (PRD's "you built a multithreaded harness" was counterfactual; from-scratch K2 port is the actual scope). Re-engagement gate after corruption episode is binding for all agents.
- [`project_contract.json`](project_contract.json) — 12-key GPD-schema formal contract: 6 claims, 7 observables, 9 acceptance tests, 7 forbidden proxies, 9 references, 6 deliverables, uncertainty markers. GPD CLI verdict: `mode=approved`, `errors=[]`, `warnings=[]`, `decisive_target_count=19`. Every claim in this README traces to a contract entry.
- [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md) — Genesis (285v, D₆, source-available, forward methodology) is not dm3_runner (380v, C₃, source-unrecovered, backwards methodology). All cross-lane comparisons are explicitly framed as such; the four pre-registered comparisons in §"Falsification Surface" ARE cross-lane and properly framed.
- Substrate-reconstruction lane (`/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`) — settled-identity authority for T(3,21) / D₆ / Q-Pythagorean / 285v. Re-derivation is out of scope.
- The Zer0pa Live Project Ethos: portfolio-not-platform; always-in-beta as positive commercial posture; honesty as posture, continuous improvement as cadence.

---

## License

[`LicenseRef-Zer0pa-SAL-7.0`](LICENSE). Source-available; commercial terms are portfolio-wide and live in the license. Genesis sits under SAL v7.0 like the rest of Zer0pa-org work; DM3 RRL v1.0 is a separately-licensed product and does not govern Genesis.

---

## Citation

If you cite this work, see [`CITATION.cff`](CITATION.cff) for machine-readable form.

---

## Contact

architects@zer0pa.ai — Zer0pa (Pty) Ltd, Republic of South Africa.
