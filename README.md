# Genesis — Comparative Determinism Experiment

*A deterministic computational organism on a settled mathematical substrate.*

---

## What This Is

Genesis is a research artifact: a pure-rational deterministic dynamical system on a settled mathematical substrate, exercised on commodity hardware to ask whether **non-trivial computation can be byte-identically reproducible across hardware, thermal conditions, time, and re-execution**. The first measurement on RM10 (Android, aarch64) returned **1560/1560 cross-checked `verify.json` SHA-256 hashes byte-identical to the source-hardcoded canonical `97bd7d…`** across three Phase 0 BITDET cells (10×6, 50×6, 200×6 invocations on cpu0–cpu5). Cross-platform parity is established at the canonical-pipeline level: `solve_h2.json = 62897b…` matches byte-exact between the M1 host build and the RM10 cross-compiled build of the standalone `snic_rust` pipeline. Source for these numbers: [`.gpd/STATE.md`](.gpd/STATE.md) §"Phase 0 host-side build" and §"Phase 0 plan checklist" (plans 00-06, 00-07).

Genesis IS: a deterministic Rust pipeline (`build-2d → lift-3d → solve-h2 → verify`) over `Q` (rationals; no floats in the math path), driven by a sealed [`configs/CONFIG.json`](inputs/substrate_285v.json), running standalone on Android with no host scripting, no `cargo`, no source tree on device. Genesis IS NOT: a codec, a productized service, a unified platform, or a portfolio-wide architecture. The `genesis_comparative` workstream is one research artifact in the Zer0pa portfolio under SAL v7.0; it scopes to the four pre-registered comparisons enumerated in §"The Falsification Surface" below and nothing more.

**Honest blocker:** the experiment is mid-flight. Phase 0 is complete (BITDET, parity, hash-gate disposition). Phase 1 K2 port has landed on the M1 host with a `best_uplift=3.000000` result on the 285-vertex substrate at `--steps 30`, awaiting RM10 deployment. Phase 2 K2_SWEEP (`--steps ∈ {20, 28..56}`, N=3 per step) is the chain that produces the Genesis σ″ curve; it has not yet run end-to-end. Phase 3 synthesis is pending Phase 2 receipts. The four pre-registered comparisons in §"The Falsification Surface" have one EARLY-SIGNAL verdict and three PENDING. Treat those verdicts as live, not settled.

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

Each item below is anchored to a path in this repository or to a logged decision in [`.gpd/STATE.md`](.gpd/STATE.md). Phase 2 receipts are not yet pulled; items dependent on those are marked PENDING in §"The Falsification Surface".

- **Bit-determinism on RM10 (Phase 0 BITDET cells)** — 3 cells × 6 cores × {10, 50, 200} iterations = **1560 cross-checked `verify.json` hashes, all equal to source-canonical `97bd7d…`**. `unique_canonical_sha_count = 1` per cell. State: [`.gpd/STATE.md`](.gpd/STATE.md) §"Phase 0 plan checklist" plan 00-07. Mirror of dm3_runner's claim ξ.
- **Cross-platform canonical match (M1 ↔ RM10)** — the same `snic_rust` pipeline produces byte-identical `solve_h2.json` SHA `62897b…` on both `aarch64-apple-darwin` (M1 host) and `aarch64-linux-android` (RM10). Hash-gate disposition for `verify.json` documented at [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md): the M1-side `e8941414…` vs source-hardcoded `97bd7d…` diff is a serialization-layer trailing-newline artifact (`VERIFY_SUMMARY.json = 8ddb…` reproduces identically; all 7 internal gates pass; `solve_h2.json` matches exactly). Mirror of dm3_runner's claim τ at the canonical-pipeline level.
- **Source-canonical match on RM10** — RM10 cross-compiled `snic_rust` reproduces source-hardcoded `CANONICAL_VERIFY_HASH = 97bd7d…` and `CANONICAL_SOLVE_HASH = 62897b…` byte-exact (no BENIGN diagnosis required on the device side; Phase 0 plan 00-06 verdict).
- **All 7 internal verification gates pass** on every Phase 0 invocation: `gates_ok`, `dep_cert`, `gc_invariants`, `lift`, `stab`, `cad_sos`, `egraph`.
- **K2 port lands on host (Phase 1, M1)** — `k2-scars` subcommand of `snic_rust`, all numeric work via `num_rational::BigRational` (no f32/f64 in math path; floats only for `printf`); two consecutive `k2-scars --steps 30` runs produce byte-identical `k2_summary.json` SHA `0b5442f9…`. Cross-compiled `snic_rust` SHA `e21208a6…` for RM10 deployment. Source: [`.gpd/STATE.md`](.gpd/STATE.md) §"Phase 1 K2 port".

---

## The Falsification Surface (Pre-registered Comparisons)

Four comparisons against the closed `dm3_runner` binary's signature observables were pre-registered in [`PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`](PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md) §"Pre-registered, falsifiable" and formalized as claims in [`project_contract.json`](project_contract.json). Both positive and negative results are equally valued.

This is a **cross-lane** falsification surface in the sense of [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md): the Genesis lane (285v, D₆, T(3,21), source-available) and the dm3_runner lane (380v, C₃, source-unrecovered) are different mathematical objects. The four comparisons probe whether dm3's signature observables are substrate-attributed (and would carry to Genesis) or augmentation-layer-attributed (and would not).

| # | Comparison | Hypothesis | Falsification | Verdict |
|---|---|---|---|---|
| 1 | **Cycle-7 attribution** (claim `claim-cycle7-attribution`) | Genesis K2 σ″ curve has dominant period 7 (substrate-attributed: T(3,21) seven twists carry through to dynamics) | Genesis cycles at period 6, 8, or aperiodic (augmentation-attributed) | **PENDING** — requires Phase 2 K2_SWEEP receipts; cycle-disambiguator sweep at multiples of 7/6/8 is the load-bearing test if Lomb-Scargle CI is wide |
| 2 | **s50-cliff attribution** (claim `claim-s50cliff-augmentation`) | Genesis does NOT cliff at `--steps=50` with `best_uplift = 0.000000` (cliff is augmentation-class) | Genesis also cliffs at exactly s50 = 0.000000 (substrate-class) | **PENDING** — requires Phase 2 K2_SWEEP receipts at s49/s50/s51, N=3 each; N=10 boundary drill if any sharp drop observed |
| 3 | **σ″-curve shape diff** (claim `claim-sigma-curve-diff`) | Genesis σ″ curve is numerically distinct from dm3's fixture table at one or more pre-registered step values | Tabulated diff (Genesis − dm3) reported per step with 95% CI | **EARLY-SIGNAL** — host-side K2_S20 and K2_S28 returned `best_uplift = 3.000000` constant (from N=1 each); if this `best_uplift = 3.0` constancy holds across the full Phase 2 sweep, the Genesis σ″ curve is flat at 3.0, structurally distinct from dm3's trimodal sawtooth, and answers all four comparisons with one signature. See [`.gpd/STATE.md`](.gpd/STATE.md) §"Curious-numbers finding to interrogate in Phase 2 sweep". |
| 4 | **D₆-vs-C₃ symmetry** (claim `claim-symmetry-D6vsC3`) | Genesis is observably mirror-symmetric (Z₂-projection ≈ 0) where dm3 is mirror-broken (C₃ ⊂ D₆); structural evidence for augmentation-as-symmetry-breaker | Genesis is also mirror-broken despite D₆ substrate | **PENDING** — Z₂-asymmetric observable on Genesis substrate must be pre-registered before Phase 2 SYMMETRY cell; N=10 invocations; Monte Carlo baseline mandatory |

dm3_runner fixture values used as comparison anchors (from 8 sessions of receipts; see `ref-dm3-sigma-findings` in [`project_contract.json`](project_contract.json)): trimodal sawtooth peaks at s33=1.873756, s41=1.708374, s49=1.819397, s56=1.970840; drops at s34=1.370651, s43=1.160828; cliff at s50 = exactly 0.000000; period ~7 steps.

The EARLY-SIGNAL on comparison #3 is a curious-numbers finding, not a settled verdict. The Phase 1 host result of `best_uplift = 3.000000` with **uniform `|scar| = 1.2` across all 567 edges** and **perfect recall (`avg_recall_err = 0.0`)** at `--steps 30` may reflect (a) a real substrate effect (D₆ orbit decomposition makes K2 trivially recoverable on Genesis; structurally distinct from dm3's 380v C₃ substrate where dm3 returns `max_scar=0.868`, `best_uplift=1.644`), or (b) a degenerate pattern choice from D3 (rank-1 effect of disjoint Bhupura(282)+Lotus(3) outer products). Phase 2 K2_SWEEP over `--steps ∈ {20, 28..56}` distinguishes constancy (degenerate) from variation (substantive), and is the test that promotes EARLY-SIGNAL to SETTLED or retracts it.

---

## Proof Anchors

Every path below resolves in this repository at the time of writing. Receipts under `artifacts/` are pulled at chain close; the `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` and `proofs/artifacts/` paths are reserved by the in-progress packaging step (see Upcoming Workstreams) and will hold the canonical signed manifest once Phase 2 lands.

| Path | What it carries |
|---|---|
| [`PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`](PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md) | Operator's source-of-truth PRD; four pre-registered comparisons; test program; deployment recipe; boundaries |
| [`project_contract.json`](project_contract.json) | 12-key formal contract: 6 claims, 7 observables, 9 acceptance tests, 7 forbidden proxies, 9 references, 6 deliverables; uncertainty markers |
| [`RESISTANCE.md`](RESISTANCE.md) | Four named corruptions binding for all agents on this lane (rush-to-green-flag, NULL-as-out, efficiency-as-corner-cutting, flattery-as-freedom); re-engagement gate |
| [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md) | Formal separation of Genesis (285v, D₆) from dm3_runner (380v, C₃, parked); Resolution clause for Phase A anchors |
| [`.gpd/PROJECT.md`](.gpd/PROJECT.md) | Project goals, scope, hard constraints, deliverables, out-of-scope |
| [`.gpd/STATE.md`](.gpd/STATE.md) | Live state: Phase 0 evidence, Phase 1 K2 result, retractions ledger, decisions D1–D6, blockers, session continuity |
| [`.gpd/ROADMAP.md`](.gpd/ROADMAP.md) | Phase decomposition (0–3); plan checklist |
| [`inputs/substrate_285v.json`](inputs/substrate_285v.json) | 285-vertex substrate fixture: vertices, 567 edges, 48 D₆ orbits, Bhupura/Lotus pattern indices |
| [`harness/phone/`](harness/phone/) | Six-script chain harness: `run_genesis_cell.sh`, `launch_genesis_batch.sh`, `thermal_coordinator.sh`, `genesis_chain_v1.sh`, `master_watcher.sh`, `resume_chain.sh` |
| [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md) | D1 BENIGN diagnosis for M1 verify.json `e894…` vs source-hardcoded `97bd7d…`; halt-on-out-of-family-mismatch protocol |
| `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` | PENDING — authority manifest authored at chain close |
| `proofs/artifacts/` | PENDING — Phase 0/1/2 receipts pulled from device at chain close |
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
├── proofs/                                PENDING — receipts at chain close
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
- **Engineering:** harness/, inputs/, proofs/ (pending), artifacts/ (pending)
- **Policy:** LICENSE, CITATION.cff, REPRODUCIBILITY.md, SECURITY.md, CONTRIBUTING.md, CHANGELOG.md, README.md

---

## Upcoming Workstreams

This section captures the active lane priorities — what the next agent or contributor picks up, and what investors should expect. Cadence is continuous, not milestoned.

- **Phase 2 K2_SWEEP completion** — `Active Engineering`. Chain manifest covers `--steps ∈ {20, 28..56}`, N=3 per step, 90 invocations on cpu0–cpu5; receipts pulled to `artifacts/genesis_<TS>/cells/K2_SWEEP/` at chain close. This is the test that promotes the §"Falsification Surface" comparison-3 verdict from EARLY-SIGNAL to SETTLED or retracts it.
- **Phase 3 synthesis and final report** — `Active Engineering`. After Phase 2 receipts land. Renders the four pre-registered comparison verdicts with acceptance-test evidence; final report at `reports/GENESIS_FINAL_REPORT_<DATE>.md`; Genesis-side appendix with σ″-curve diff vs dm3, cycle-period verdict, cliff-presence verdict, symmetry-test verdict — no cross-lane editorial in the appendix itself.
- **Cross-platform parity at K2-task level** — `Active Engineering`. Current parity is established at the canonical-pipeline level (`solve_h2.json`); extending to byte-identity for `k2_summary.json` between M1 host and RM10 is a small Phase 1.5 cell once the K2 cross-compile lands on device.
- **Bhupura/Lotus pattern choice (the rank-1 degenerate-K2 question)** — `Research-Deferred — Investigation Underway`. The host-side `best_uplift = 3.0` constant + uniform `|scar| = 1.2` finding may be a real substrate effect or a degenerate D3 pattern choice. Phase 2 K2_SWEEP across step values is the discriminator. If degenerate, alternative D₆ orbit picks are pre-registered as the next investigation.
- **Cross-substrate K2 with alternative D₆ orbit picks** — `Research-Deferred — Investigation Underway`. Conditional on the Bhupura/Lotus pattern outcome above. If the D3 picks are degenerate, alternative orbit pairings (e.g., partitioning the 47 size-6 orbits differently, or using non-disjoint pattern supports) become the second-pass design.
- **Cycle-7 disambiguator at higher precision** — `Research-Deferred — Investigation Underway`. The Phase 2 cycle-disambiguator (`--steps` ∈ multiples of 7 vs 6 vs 8) is the load-bearing test for the cycle-7 attribution claim if Lomb-Scargle CI is too wide on the 30-point K2_SWEEP series. Higher-precision per-step internal-state checksum (`--receipt-format=json-bigrat`) is a Phase 1.5 engineering deliverable that may sharpen the verdict.
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
