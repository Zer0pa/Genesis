# Genesis - Comparative Determinism Experiment

> Live window into the Zer0pa lab. Genesis is a computation experiment, not a codec or productized service.

## What This Is

Genesis is a pure-rational deterministic computation experiment: 74 receipt cells pass, cross-platform parity holds, v2.0 symmetry tests remain open.

Genesis is a research artifact: a pure-rational deterministic dynamical system on a settled mathematical substrate, exercised on commodity hardware to ask whether **non-trivial computation can be byte-identically reproducible across hardware, thermal conditions, time, and re-execution**. The v1.0 RM10 (Android, aarch64) proof surface contains **31,560 / 31,560 Phase 0 `verify.json` SHA-256 hashes byte-identical to the source-hardcoded canonical `97bd7d…`** across four BITDET cells (10×6, 50×6, 200×6, 5000×6 invocations on cpu0–cpu5). Cross-platform parity is established at the canonical-pipeline level: `solve_h2.json = 62897b…` matches byte-exact between the M1 host build and the RM10 cross-compiled build of the standalone `snic_rust` pipeline. K2-task cross-platform parity is confirmed at `--steps 30`: RM10 `BITDET_K2_S30_BIG` reproduces the same `k2_summary.json` SHA `0b5442f9…` as the M1 host Phase 1 BITDET run. Phase 2 and 2.5 add 56 K2-task cells, all PASS with `unique_canonical_sha_count = 1`, and the aggregated σ″ curve in [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv). Phase 3 prep contributes 11 BIG cells in-repo (`BITDET_K2_S1_BIG`..`S9_BIG`, `S30_BIG`, `S56_BIG`) plus the complete parity-sweep extension at `BITDET_K2_S20_PARITY`, `BITDET_K2_S40_PARITY`, `BITDET_K2_S50_PARITY`. **74 cells total in-repo / 74 PASS / 0 divergences.** The v1.0 closure is summarised in [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md).

Genesis IS: a deterministic Rust pipeline (`build-2d → lift-3d → solve-h2 → verify`) over `Q` (rationals; no floats in the math path), driven by a sealed [`configs/CONFIG.json`](inputs/substrate_285v.json), running standalone on Android with no host scripting, no `cargo`, no source tree on device. Genesis IS NOT: a codec, a productized service, a unified platform, or a portfolio-wide architecture. The `genesis_comparative` workstream is one research artifact in the Zer0pa portfolio under `LicenseRef-Zer0pa-GDM3-RRL-1.0`; it scopes to the four pre-registered comparisons enumerated in §"The Falsification Surface" below and nothing more.

**Honest blocker (v1.0 closure):** the v1.0 backend chain is closed and the phone has been released for other experiments. Phase 0, Phase 1, Phase 2, Phase 2.5, Phase 3 prep BIG, and Phase 3 parity-sweep are all in repo (74 cells, all PASS). Three of the four pre-registered comparisons settle empirically with receipt evidence; the fourth (D₆-vs-C₃ symmetry) lands as a structurally-complete analytic disposition (substrate inclusion D₆ ⊃ C₃ confirmed; the operator-approved D3 pattern is exactly Z₂-invariant by construction; numerical Z₂-projection observable would require a Z₂-asymmetric pattern, i.e. a new chain run, which is **deferred to v2.0**). The pattern-degeneracy alternative reading for flat σ″ is also v2.0 work. K2-task host-side byte-comparison at S20 / S40 / S50 against the in-repo RM10 anchors is host-only and remains a small open task; not phone-blocking. The repo at this commit is the canonical v1.0 surface for remote review; future receipts will append to a v2.0 branch when reactivated.

Category: research artifact in the Zer0pa portfolio under `LicenseRef-Zer0pa-GDM3-RRL-1.0`; settled-substrate dynamics on a 285-vertex graph; comparative methodology against a sibling lane (`dm3_runner`, parked, source-unrecovered) — see [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md).

---

## System Mechanics

| Field | Value |
| --- | --- |
| Architecture | DETERMINISTIC_COMPUTATION_SUBSTRATE |
| Substrate | `P_95 x K_3`; 285 vertices; D6 symmetry; Q/Pythagorean rational math path |
| Execution | Rust pipeline: build-2d -> lift-3d -> solve-h2 -> verify |
| Hardware Surface | RM10 Android ARM64 plus M1 host comparisons |
| Mechanics | receipt cells, SHA-256 hash gates, K2 scar dynamics, thermal-cycle replay |
| Open Gate | Z2-asymmetric observable and alternative-pattern v2.0 work |

## Key Metrics

| Metric | Value | Baseline |
| --- | --- | --- |
| Phase 0 verify hashes | 31,560 / 31,560 byte-identical | RM10 Android aarch64 |
| Receipt cells | 74 / 74 PASS | in-repo proof surface |
| K2 cross-platform parity | S30 byte-identical | RM10 vs M1 host |
| Pre-registered comparisons | 3 settled empirically; 1 analytic/deferred | v1.0 comparison surface |

> Source: `reports/GENESIS_FINAL_REPORT_2026-05-01.md`, `proofs/manifests/CURRENT_AUTHORITY_PACKET.md`, `proofs/artifacts/sigma_curve_full.tsv`, and `project_contract.json`.

## Repo Identity

| Field | Value |
| --- | --- |
| Identifier | Genesis |
| Repository | https://github.com/Zer0pa/Genesis |
| Portfolio | Computation |
| Visibility | INTERNAL |
| Default Branch | main |
| Authority Source | `reports/GENESIS_FINAL_REPORT_2026-05-01.md`; `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` |
| License | LicenseRef-Zer0pa-GDM3-RRL-1.0 |

## Readiness

| Field | Value |
| --- | --- |
| Evidence posture | v1.0 backend chain closed; internal visibility |
| Receipt cells | 74 PASS / 0 divergence |
| Phone state | released for other experiments |
| Authority | `reports/GENESIS_FINAL_REPORT_2026-05-01.md` |

### Honest Blocker

The direct numerical Z2-projection observable and alternative-pattern tests are deferred to v2.0; host-side S20/S40/S50 parity widening remains small host-only work; dm3_runner source recovery is external.

## What We Prove

- **Bit-determinism on RM10 (Phase 0 BITDET cells)** — 4 cells × 6 cores × {10, 50, 200, 5000} iterations = **31,560 cross-checked `verify.json` hashes, all equal to source-canonical `97bd7d…`**. `unique_canonical_sha_count = 1` per cell. Mirror of dm3_runner's claim ξ.
- **Cross-platform canonical match (M1 ↔ RM10)** — the same `snic_rust` pipeline produces byte-identical `solve_h2.json` SHA `62897b…` on both `aarch64-apple-darwin` (M1 host) and `aarch64-linux-android` (RM10). Hash-gate disposition for `verify.json` documented at [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md): the M1-side `e8941414…` vs source-hardcoded `97bd7d…` diff is a serialization-layer trailing-newline artifact (`VERIFY_SUMMARY.json = 8ddb…` reproduces identically; all 7 internal gates pass; `solve_h2.json` matches exactly). Mirror of dm3_runner's claim τ at the canonical-pipeline level.
- **Source-canonical match on RM10** — RM10 cross-compiled `snic_rust` reproduces source-hardcoded `CANONICAL_VERIFY_HASH = 97bd7d…` and `CANONICAL_SOLVE_HASH = 62897b…` byte-exact (no BENIGN diagnosis required on the device side; Phase 0 plan 00-06 verdict).
- **All 7 internal verification gates pass** on every Phase 0 invocation: `gates_ok`, `dep_cert`, `gc_invariants`, `lift`, `stab`, `cad_sos`, `egraph`.
- **K2 port lands on host and RM10 (Phase 1+)** — `k2-scars` subcommand of `snic_rust`, all numeric work via `num_rational::BigRational` (no f32/f64 in math path; floats only for `printf`); two consecutive host `k2-scars --steps 30` runs produce byte-identical `k2_summary.json` SHA `0b5442f9…`; `BITDET_K2_S30_BIG` on RM10 reproduces the same SHA byte-for-byte; Phase 2/2.5 and Phase 3 prep RM10 cells preserve per-cell K2 BITDET with `unique_canonical_sha_count = 1`.
- **σ″ curve receipts (Phase 2/2.5 + Phase 3 prep complete + parity-sweep complete)** — 74 total receipt cells are in [`proofs/artifacts/cells/`](proofs/artifacts/cells/), all PASS. The Genesis K2 σ″ curve is flat at `best_uplift = 3.000000` across S20 and S28..S56, with a pre-convergence transient peaking at S2 = 6.5 and settling to 3.0 by S10; Phase 3 prep confirms the S1..S9 transient structure at 600× replicate scale per step, S30 steady-state at 1,200×, S56 far-end steady-state at 300× under thermal cycling, and the parity-sweep extension at S20 / S40 / S50 (300× per step, all PASS, RM10 anchor SHAs `74fa0b8a…` / `38be38e2…` / `f5cd3876…`).

## What We Don't Claim

- Genesis is not a codec, productized service, unified platform, or portfolio-wide architecture.
- Genesis does not prove a general computation substrate beyond the pre-registered v1.0 comparison surface.
- The D6-vs-C3 comparison is not numerically closed; it has a structurally complete analytic disposition and v2.0 numerical work remains.
- The flat sigma curve does not by itself decide substrate-easy versus pattern-degenerate explanations.
- Genesis does not recover or identify dm3_runner source; that remains a sibling-lane external dependency.

## Verification Status

| Code | Check | Verdict |
| --- | --- | --- |
| V_01 | Phase 0 RM10 verify hashes: 31,560/31,560 byte-identical | PASS |
| V_02 | In-repo receipt cells: 74/74 pass, unique SHA count stable | PASS |
| V_03 | K2 S30 RM10/M1 cross-platform parity | PASS |
| V_04 | v1.0 final report and authority packet present | PASS |
| V_05 | Z2-asymmetric numerical observable | DEFERRED |

## Proof Anchors

| Path | State |
| --- | --- |
| `reports/GENESIS_FINAL_REPORT_2026-05-01.md` | VERIFIED |
| `PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md` | VERIFIED |
| `project_contract.json` | VERIFIED |
| `LANE_DISTINCTION.md` | VERIFIED |
| `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` | VERIFIED |
| `proofs/artifacts/sigma_curve_full.tsv` | VERIFIED |

## Repo Shape

| Field | Value |
| --- | --- |
| Proof Anchors | 6 display anchors |
| Portfolio | Computation |
| Authority Source | `reports/GENESIS_FINAL_REPORT_2026-05-01.md` |
| Substrate | `inputs/substrate_285v.json` |
| Harness | `harness/phone/`; `harness/host/` |
| Proofs | `proofs/`; `reports/` |
| Support Sections | Reviewer Pack; Substrate; Falsification Surface; Sibling Lane; Reproduce; Methodology |

## Reviewer Pack

This is the curated v1.0 review surface. Read these ten in order for the full path from headline to substrate to receipts to verdicts:

1. [`README.md`](README.md) (this file) — entry, scope, headline numbers, posture
2. [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md) — v1.0 final synthesis: four comparison verdicts, determinism scorecard, analytic Z₂ disposition, settled / pending / falsification path
3. [`AUDITOR_PLAYBOOK.md`](AUDITOR_PLAYBOOK.md) — 30-minute outsider audit + FAQ (project, substrate, determinism, K2, methodology, license, v2.0)
4. [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) — full local reproduction recipe (cross-compile, deploy, smoke-test)
5. [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md) — settled substrate identity (T(3,21), D₆, 285v, Q-Pythagorean)
6. [`docs/K2_PROTOCOL.md`](docs/K2_PROTOCOL.md) — K2 algorithm specification (Bhupura/Lotus, scar weights, dynamics, KPI schema)
7. [`docs/DETERMINISM.md`](docs/DETERMINISM.md) — exact-rational discipline (BigRational, no-float policy, cross-iter / cross-instance / cross-platform proofs)
8. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — chain architecture, receipt schema, **and** Operations Manual (manifest format, launch / stop / pull / recovery; for v2.0 reactivation)
9. [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md) — Genesis (285v, D₆) vs dm3_runner (380v, C₃) formal separation; cross-lane framing
10. [`RESISTANCE.md`](RESISTANCE.md) — four named corruptions (`fp-rushtoend`, `fp-NULLasout`, `fp-flatteryasfreedom`, `fp-counterfactual-prd-premise`, `fp-shapematchRE`); methodology / honesty discipline

Outside the pack but in the repo (legal / admin / contract / historical, not part of the curated science surface): `LICENSE`, `CITATION.cff`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `project_contract.json` (machine-readable formal contract referenced from the pack), `PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md` (operator's source-of-truth pre-registration), `HANDOVER_2026-04-27.md` and `ADVISORY_2026-04-27.md` (historical session decisions D1–D6), `harness/host/HASH_GATE_DISPOSITION.md` (D1 BENIGN diagnosis), `.gpd/` (state and decision ledger), `proofs/` (manifests, receipts, figures), `harness/`, `inputs/`.

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

## The Falsification Surface

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

## Sibling Lane - DM3

Genesis and DM3 are two graphs related by one discrete arithmetic step on the same 95-station path base. The Genesis substrate is `P_95 ☐ K_3` (285 vertices, 567 edges, 96 triangular faces, `Aut = D_6` of order 12); the DM3 loaded fixture is `P_95 ☐ K_4` (380 vertices, 946 edges, `Aut = C_2 × S_4` of order 48); the two are connected by complete-graph fiber promotion `K_3 → K_4`. The Genesis 285-vertex substrate is **bit-identical** to the DM3 internal default skeleton — the graph that `Dm3State::initialize → build_helix_meru → build_dual_meru` constructs when no fixture is loaded — so Genesis is, by construction, a source-available falsifiable instance of DM3's `K_3` surface. The relationship is lateral, not subordinate: same path base, same upstream Rust pipeline (`yantra_2d → lift_3d → yantra_3d_dual`), with the source-built mesh authority byte-identical between the two geometry bundles at `dual_meru_mesh.ply` SHA `7ee17457b7daeec565bb1e06982b8a1facd8169f` and `dual_meru_yantra_2d.svg` SHA `a1dbf572167960b9bd348d392d3405b1114db1ef`. The visual receipt is at [`proofs/artifacts/figures/dm3_vs_genesis_fiber_promotion.png`](proofs/artifacts/figures/dm3_vs_genesis_fiber_promotion.png) — six panels showing the full helical columns, single-station insets (K_3 triangle versus K_4 tetrahedron), and the V/E/spectrum/Aut arithmetic of the promotion; caption + falsification path documented at [`proofs/artifacts/figures/dm3_vs_genesis_fiber_promotion.txt`](proofs/artifacts/figures/dm3_vs_genesis_fiber_promotion.txt). DM3's `R8` Tier-3 live runtime trace remains `OPEN_TIER3_BLOCKED` and is the open authority gate on the K_4 side; the four pre-registered comparisons in §"The Falsification Surface" probe whether DM3's signature observables (cycle-7, s50-cliff, σ″-curve shape, C_3 mirror-breaking) are substrate-attributed (would carry to Genesis on K_3) or augmentation-attributed (would not). Cross-repository pointer: [`Zer0pa/DM3`](https://github.com/Zer0pa/DM3) (public).

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
├── LICENSE                                Genesis-DM3 RRL v1.0 canonical text
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
│       ├── thermal_coordinator.sh         80°C Genesis-zone ceiling, debounce, SIGSTOP/SIGCONT
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

## v1.0 Closure & v2.0 Outlook

The v1.0 backend chain is closed (2026-05-01). The phone has been released for other experiments. The Phase 3 final synthesis is at [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md).

What remains as host-only or v2.0 work:

- **K2-task cross-platform parity widen-coverage at S20 / S40 / S50** — `Host-Only`. RM10 anchors are now in-repo (`74fa0b8a…` / `38be38e2…` / `f5cd3876…`). Host-side M1 byte comparison at those step values is a small task; does not require chain reactivation.
- **Numerical Z₂-projection observable for Comparison #4** — `Deferred to v2.0`. The analytic disposition lands the structural inclusion D₆ ⊃ C₃ and proves the operator-approved D3 pattern is exactly Z₂-invariant by construction (see [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md) §"Comparison #4"). A direct numerical Z₂-projection requires a Z₂-asymmetric pattern (a new chain run); operator-visible decision required to reactivate.
- **Bhupura/Lotus pattern choice (the rank-1 degenerate-K2 question)** — `Deferred to v2.0`. Phase 2 + 2.5 confirm flat steady-state behavior under D3 with a non-trivial pre-convergence transient. Alternative D₆ orbit picks remain the discriminator for substrate-easy vs pattern-degenerate explanations of flat σ″.
- **Cross-substrate K2 with alternative D₆ orbit picks** — `Deferred to v2.0`. Alternative orbit pairings (partitioning the 47 size-6 orbits differently, or using non-disjoint pattern supports) become the second-pass design.
- **Sibling lane source recovery (`dm3_runner`)** — `Operations / External Dependency`. dm3_runner's source has not been recovered; separate workstream. Genesis comparisons stand on the eight sessions of dm3 receipts and the σ″ fixture table; full attribution analysis on the dm3 side is gated on source recovery in that lane.

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

[`LicenseRef-Zer0pa-GDM3-RRL-1.0`](LICENSE). Genesis is covered by the Zer0pa Genesis-DM3 Research and Receipt License v1.0 together with the sibling DM3 artefact. The license preserves lane distinction and receipts-first discipline; it does not assert a unified platform or generalised cross-artefact computation.

---

## Citation

If you cite this work, see [`CITATION.cff`](CITATION.cff) for machine-readable form.

---

## Contact

architects@zer0pa.ai — Zer0pa (Pty) Ltd, Republic of South Africa.
