# Auditor Playbook — Genesis Comparative

**Version:** 2026-05-02
**Branch:** `main` (tag `v1.0.0`; backend chain closed; canonical internal review surface)
**Audience:** external auditor, investor diligence, scientific advisor, repo orchestrator  
**Goal:** shortest honest path to verifying the central claims in under 30 minutes

---

## What This Repo Claims

Each item is a specific, falsifiable claim traceable to a source artifact.

- Byte-identical `verify.json` SHA-256 = `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89` for the `snic_rust` 4-step pipeline (`build-2d → lift-3d → solve-h2 → verify`) on `configs/CONFIG.json`, across hardware, platform, thermal state, and time.
- Byte-identical `solve_h2.json` SHA-256 = `62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780`, matching the source-hardcoded canonical constant in `crates/genesis_cli/src/main.rs` exactly.
- Cross-platform parity: M1 host (`aarch64-apple-darwin`) and RM10 (`aarch64-linux-android`) builds of `snic_rust` produce the same canonical hashes byte-exact.
- 31,560 cross-replicate canonical-hash matches across Phase 0 BITDET cells (BITDET_01: 60 invocations; BITDET_02: 300; BITDET_03: 1,200; BITDET_5K: 30,000) with zero divergences and `unique_canonical_sha_count = 1` per cell.
- K2 task BITDET on M1 host: two consecutive `k2-scars --steps 30` runs produce byte-identical `k2_summary.json` SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`.
- K2 task BITDET on phone: 56 Phase 2/2.5 K2-task cells plus 11 Phase 3 prep BIG cells plus 3 landed parity-sweep cells (`BITDET_K2_S20_PARITY`, `S40_PARITY`, `S50_PARITY`) currently in-repo all PASS with `unique_canonical_sha_count = 1` per cell.
- K2-task cross-platform parity at S30: M1 host and RM10 both produce `k2_summary.json` SHA `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`.
- RM10 parity anchors now in-repo beyond S30: `S20 = 74fa0b8a7082b76370db8cf05f0baf520534e5def11edfccd698f26ad914e432`, `S40 = 38be38e28653af6b2d1bac6bc5caf3d9f05a01a0f4d03dc149f7a68d498ea42b`, `S50 = f5cd3876868ec1b2a40a6dcd6b6e40914813f6992f2f067e9cd65beb5ce81960`; host-side byte comparison at matching `--steps` values is the remaining widen-coverage audit extension.
- σ″ curve: Genesis is flat at `best_uplift = 3.000000` across S20 and S28..S56, with pre-convergence transient peak at S2 = 6.5 and settlement to 3.0 by S10.
- Substrate identity (T(3,21) torus link, D₆ symmetry, 285 vertices, Q-Pythagorean) is settled per `substrate-reconstruction-2026-04-26` (separate authority; not re-derived here).

Source for all items above: [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md) and [`.gpd/STATE.md`](.gpd/STATE.md).

---

## The Three-Step Audit (30 minutes total)

| Step | Action | Time | What it verifies |
|---|---|---|---|
| 1 | Clone upstream source, build, run pipeline and K2 S30 on your hardware | 10 min | Determinism claim and K2-task parity anchor — your platform, your build |
| 2 | Inspect source-hardcoded canonical hash constants | 5 min | Source-canonical match — the reference isn't derived from one platform's run |
| 3 | Read receipt files in `proofs/artifacts/` and run cross-replicate SHA verification | 15 min | Cross-replicate evidence from the chain run |

---

## Step 1 — Verify Determinism on Your Hardware (10 min)

Clone the upstream Genesis source workspace (this repo contains only the experiment scaffolding; the substrate pipeline lives upstream):

```bash
git clone https://github.com/Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025.git
cd Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f

# Build the standalone pipeline binary
cargo build --release -p io_cli

# Run the 4-step pipeline
./target/release/snic_rust build-2d --config configs/CONFIG.json
./target/release/snic_rust lift-3d  --config configs/CONFIG.json
./target/release/snic_rust solve-h2 --config configs/CONFIG.json
./target/release/snic_rust verify   --config configs/CONFIG.json

# Verify canonical pipeline hashes
sha256sum artifacts/verify.json
sha256sum artifacts/solve_h2.json

# Verify K2-task parity anchor at S30
./target/release/snic_rust k2-scars --config configs/CONFIG.json --steps 30
sha256sum artifacts/k2_summary.json
```

**Expected output:**

```
97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89  artifacts/verify.json
62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780  artifacts/solve_h2.json
0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372  artifacts/k2_summary.json
```

**If your hashes match:** you have verified both the canonical-pipeline determinism claim and the K2-task parity anchor on your hardware. The substrate's deterministic computation is not a Zer0pa-internal fact; it is a property of the source code that any platform can reproduce independently.

**If your hashes do NOT match:** this is itself a substantive finding. File a falsification claim per [§ How to File a Falsification Claim](#how-to-file-a-falsification-claim). The most likely causes are: (a) `cargo` built against a different upstream commit than the workspace seal `a83f39e6…`; (b) the `configs/CONFIG.json` differs from the one committed in this repo at `inputs/substrate_285v.json` / `configs/CONFIG.json`. Check both before concluding.

**Note on the M1 host BENIGN diagnosis:** the M1 host build of the meta-orchestrator `genesis_cli` (not `snic_rust`) produces `verify.json = e8941414…`, not `97bd7d…`. This is a documented, diagnosed trailing-newline serialization artifact from a different code path. It does not affect the `snic_rust` standalone pipeline — which produces `97bd7d…` exactly on both M1 and RM10. Full diagnosis: [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md). If you are running `snic_rust` directly (as instructed above), you should not see this discrepancy.

---

## Step 2 — Verify Source-Canonical Match (5 min)

Read the source-hardcoded canonical hash constants:

```bash
grep -A 1 'CANONICAL_VERIFY_HASH\|CANONICAL_SOLVE_HASH' \
  Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/crates/genesis_cli/src/main.rs
```

**Expected output:**

```rust
const CANONICAL_VERIFY_HASH: &str = "97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89";
const CANONICAL_SOLVE_HASH:  &str = "62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780";
```

These are the source author's reproducibility reference points, committed in the genesis source. The Genesis Comparative claim is that the `snic_rust` standalone pipeline reproduces these byte-exact on multiple platforms. You have already verified this empirically in Step 1 on your own hardware.

---

## Step 3 — Verify Cross-Replicate Evidence (15 min)

The canonical `main` surface includes 74 receipt cells under `proofs/artifacts/cells/`:

```bash
cd /path/to/genesis_comparative

# List all per-cell outcomes
find proofs/artifacts/cells -name "outcome.json" \
  | xargs -I{} jq -r '[.cell, .verdict, (.metrics.failures|tostring), (.metrics.unique_canonical_sha_count|tostring)] | @tsv' {}

# Count cells and PASS verdicts
find proofs/artifacts/cells -name "outcome.json" | wc -l
find proofs/artifacts/cells -name "outcome.json" -exec grep -l '"verdict": "PASS"' {} \; | wc -l

# Verify each cell has one canonical SHA internally
find proofs/artifacts/cells -name "outcome.json" \
  | xargs -I{} jq -r 'select(.metrics.unique_canonical_sha_count != 1) | .cell' {}
```

**Expected:** 74 `outcome.json` files, 74 PASS verdicts, and the final command emits no rows. Every `outcome.json` has `"verdict": "PASS"`, `"failures": 0`, and `"unique_canonical_sha_count": 1`.

**If `unique_canonical_sha_count` per cell is consistently 1:** cross-replicate determinism is established at the cell level. Do not require one aggregate hash across all cells: K2 cells at different step values legitimately produce different `k2_summary.json` hashes.

**If multiple unique hashes appear:** this is a divergence. File a falsification claim with the full cell and instance identifiers of the divergent pair.

**Note on K2 cells:** K2 cells (`K2_S*`, `PRECONV_*`, `BITDET_K2_*`) use `k2_summary.json` as the canonical artifact instead of `verify.json`. The same audit applies — `unique_canonical_sha_count` per cell must equal 1. `BITDET_K2_S30_BIG` additionally anchors cross-platform K2-task parity: all six RM10 receipts carry `canonical_sha = 0b5442f9…`, matching the host-side Step 1 run exactly. The parity-sweep extension adds RM10-side comparison targets at `S20 = 74fa0b8a…`, `S40 = 38be38e2…`, and `S50 = f5cd3876…`. The cross-replicate audit command works identically for K2 cells because the harness writes `canonical_stdout.sha256` for every invocation regardless of task type.

---

## What This Audit Establishes

- Determinism property holds on **your hardware** (Step 1 reproduction). The claim is not taken on trust from Zer0pa's lab; you reproduce it from source.
- The substrate's reference hashes are **source-encoded**, not derived from any single platform run (Step 2 source inspection). They existed in the genesis source before the comparative experiment ran.
- **Cross-replicate determinism** in the chain run: all 31,560 Phase 0 invocations and all currently landed K2 receipt cells produced per-cell byte-identical canonical output, independently of which of cpu0–cpu5 ran them and at what thermal state (Step 3 receipt aggregation).

---

## What This Audit Does NOT Establish (Public Audit Limits)

- Whether the substrate is the *intended* mathematical object the source author had in mind. Settling that requires the `substrate-reconstruction-2026-04-26` proof tree, which is a separate authority at `SHARE_2026-04-27/`. This experiment treats the substrate as a settled anchor and does not re-derive it.
- Whether the K2 protocol implementation in `crates/io_cli/src/k2_scars.rs` is the *correct* reading of the dm3 K2 algorithm. The dm3_runner source is unrecovered; the Genesis K2 port is from-scratch on the Genesis substrate per decision D2.
- Whether the D6-vs-C3 comparison has a direct numerical Z2-projection measurement. The v1.0 surface includes the analytic disposition in [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md): structural inclusion is confirmed, while the direct numerical Z2-projection observable is deferred to v2.0 because it requires a new Z2-asymmetric pattern and a new chain run.
- **Long-horizon determinism.** Current evidence spans hours to days. Long-duration thermal drift, silicon aging, or firmware updates are untested surfaces.
- **Determinism against adversarial source modification.** This audit verifies the pipeline runs deterministically given the source as committed. Intentional tampering with the source is not a defended surface — it is the canonical falsification path.
- **Commercial readiness.** This is a research artifact. No productization verdict is made here.

---

## How to File a Falsification Claim

1. Reproduce the divergence with verbose logging: add `RUST_LOG=debug` or capture full stdout.
2. Capture: your platform string (`uname -a`), Rust/cargo version (`cargo --version`), snic_rust binary SHA (`sha256sum target/release/snic_rust`), and the full hash chain from your run (`sha256sum artifacts/{yantra_2d,lift_3d,solve_h2,verify}.json`).
3. Open an issue on the Zer0pa/Genesis GitHub repo titled `[FALSIFICATION] verify.json hash != 97bd7d on <platform>`.
4. Include: platform string, expected hash, observed hash, and any diff between your `artifacts/` and the canonical reference.
5. Email architects@zer0pa.ai with the issue link.

Falsification is welcomed. The current Genesis-DM3 RRL v1.0 and the project discipline prohibit removing adverse test results to flatter the proof surface. Every such report is processed and documented; if confirmed, it becomes a retraction entry in [`.gpd/STATE.md`](.gpd/STATE.md).

---

## How to Inspect the Receipt Schema

Full schema: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) §"The Receipt Schema".

One-line summary: every cell has `outcome.json` (cell-level verdict: PASS/KILL/PARTIAL/SKIP; `unique_canonical_sha_count`; `failures` count), `_summary.json` (batch-level metrics), and per-instance `<N>_<TS>/receipt.json` (individual run with `canonical_sha` + `receipt_sha` + dm3-mirror fields `env_pre`/`env_post` + a `genesis_meta` sub-object carrying `build_hash`, `target_triple`, `verify_json_sha`, `solve_h2_sha`).

Receipt location once pulled: `proofs/artifacts/<CELL_ID>/`. Schema source: `harness/phone/run_genesis_cell.sh` (the script that writes each receipt).

---

## Common Audit Concerns (preemptive)

**Q: Why don't all canonical hashes appear in this repo?**

A: This repo (`genesis_comparative`) is the *experimental scaffolding*: the RESISTANCE methodology, harness scripts, K2 task module, receipt artifacts, and formal contract. The substrate source code — including the canonical hash constants — lives at `Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025`. Audit Step 1 walks both repos to verify both surfaces together. The separation is intentional: the substrate source is a separate, independently citable artifact that predates this experiment.

**Q: Why is this an INTERNAL repo if the claim is reproducibility-by-anyone?**

A: It remains INTERNAL on the Zer0pa org. The substrate source repo is separately managed. Auditors with repo access granted for diligence purposes should inspect `main` at tag `v1.0.0`, which is the canonical internal review surface after backend-chain closure.

**Q: How do I know the receipts in `proofs/artifacts/` are not fabricated?**

A: Each receipt's `canonical_sha` traces to `sha256(<wd>/artifacts/verify.json)` of an actual `snic_rust` run. The on-device `genesis_meta` sub-object records the `binary_sha256` of the `snic_rust` used. You can verify: rebuild `snic_rust` from the workspace seal `a83f39e6…` yourself (Step 1 already does this); compare your binary SHA to the `binary_sha256` field in any receipt. If the binary SHA in the receipt matches the binary you just built from the same source commit, the receipt was produced by that binary. The SHA of `verify.json` is then a deterministic consequence of that binary + `configs/CONFIG.json` — which you have already verified in Step 1.

**Q: What if `core_ctl` pause-flapping caused a hash divergence that wasn't caught?**

A: Any divergence would show as `unique_canonical_sha_count > 1` in the cell's `_summary.json` or `outcome.json`. The chain harness is designed to surface this: `run_genesis_cell.sh` computes `canonical_stdout.sha256` for every invocation and `genesis_chain_v1.sh` aggregates them per cell. The Step 3 audit command would flag any count > 1 across the full receipt tree. Phase 0 BITDET evidence: 0 divergences out of 31,560 invocations. The `core_ctl` mitigation (parent-affinity mask `7F` + per-instance `--core auto`) is documented in [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) §Hardware Envelope and [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) §"CPU Pinning + Thermal Discipline".

**Q: What does "always-in-beta" mean for an audit?**

A: It is the portfolio commercial posture: Phase 0 ships its claims now (deterministic foundation established); Phase 2/3 extend the proof surface (cycle-7, s50-cliff, σ″-shape, symmetry); future phases extend further. Each phase ships when its evidence is in. Auditors verify what is claimed at the version they audit. "Always-in-beta" is not a hedge on the Phase 0 claims; those are established. It is a statement that the proof surface is actively growing, not frozen.

**Q: What happened to the `EARLY-SIGNAL` verdict on comparison #3 (σ″-curve shape diff)?**

A: Phase 2 settled it for the D3 pattern choice. Genesis returns `best_uplift = 3.000000` across the full steady-state sweep [S20, S56], while dm3 is a trimodal sawtooth with an exact-zero S50 cliff. Comparison #3 is now CONFIRMED as a curve-shape difference. The interpretation remains honest: flatness may be substrate-easy behavior or a D3 pattern degeneracy, so alternative D6 orbit picks remain a research-deferred follow-up.

---

## Where to Go Deeper

| Surface | Location |
|---|---|
| Substrate identity audit (separate authority) | `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` |
| Determinism discipline (BigRational, no-float policy) | [`docs/DETERMINISM.md`](docs/DETERMINISM.md) |
| Substrate properties (T(3,21), D₆, 285v) | [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md) |
| Receipt schema, pipeline architecture, chain operations | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) (architecture + Operations Manual sections) |
| Cross-compile and deploy recipe | [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) |
| Formal claims / acceptance tests / forbidden proxies | [`project_contract.json`](project_contract.json) |
| Retraction ledger and decisions D1–D6 | [`.gpd/STATE.md`](.gpd/STATE.md) |
| Hash-gate BENIGN diagnosis (M1 serialization artifact) | [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md) |
| Upstream genesis source (canonical hashes in source) | `Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025` |
| RESISTANCE methodology (four named corruptions) | [`RESISTANCE.md`](RESISTANCE.md) |
| Falsification reports | GitHub issues tagged `[FALSIFICATION]` on the Zer0pa/Genesis repo |

---

# Frequently Asked Questions

This section was folded in from `docs/FAQ.md` on 2026-05-01 as part of the v1.0 reviewer-pack consolidation. The above audit-focused Q&A in §"Common Audit Concerns" stays; the FAQ below covers project, substrate, determinism, K2, methodology, repo structure, license, and schedule questions for investors / scientific advisors / falsifiers / contributors.

## About the Project

### What is the Genesis Comparative Experiment trying to falsify?

Four pre-registered claims against the `dm3_runner` binary's signature observables. Specifically, dm3_runner (the sibling lane — 380-vertex, C₃ symmetry, source unrecovered) exhibits: a period-~7 oscillation in its K2 dynamics, an exact zero ("cliff") at `--steps=50`, a trimodal sawtooth σ″-curve, and C₃-only (mirror-broken) symmetry. The experiment asks: which of these are properties of dm3's substrate geometry — and would therefore carry over to Genesis (a different substrate, D₆ symmetry, 285 vertices) — and which are properties of dm3's augmentation layer, and would therefore NOT appear in Genesis?

The four pre-registered comparisons are: cycle-7 attribution, s50-cliff attribution, σ″-curve shape diff, and D₆-vs-C₃ symmetry. As of 2026-05-01 the v1.0 closure: comparisons #1–#3 are settled by the 74-cell receipt surface (AUGMENTATION-ATTRIBUTED, CONFIRMED, CONFIRMED respectively); #4 has a structurally complete analytic disposition (STRUCTURAL INCLUSION CONFIRMED; NUMERICAL Z₂-PROJECTION DEFERRED to v2.0 because it requires a Z₂-asymmetric pattern, i.e. a new chain run). Both positive and negative outcomes are equally valued scientifically. Source: [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md), [`project_contract.json`](project_contract.json) §claims, [`README.md`](README.md) §"The Falsification Surface".

### How does this differ from dm3_runner?

The two lanes are structurally distinct. Genesis: 285-vertex graph, D₆ = S₃ × Z₂ symmetry, T(3,21) torus link topology, source-available pure-geometry Rust codebase, Q-Pythagorean number field (no floats in math path), forward methodology (source → binary → observables). dm3_runner: 380-vertex graph, C₃ symmetry, source unrecovered, hybrid binary runs only on Android, backwards methodology (binary observables → geometry inference attempt).

They are not versions of each other and do not share a substrate. Cross-lane comparisons must be explicitly framed as such. The formal separation: [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md).

### Who is the target reader for this repo?

Three primary audiences: (1) a scientific peer who wants to run the experiment themselves on their hardware and verify that the canonical hashes reproduce — Step 1 of this Auditor Playbook is for them; (2) an investor or scientific advisor in due diligence who wants to understand what the claims are, what's established, and what's pending — [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md), [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md), and [`project_contract.json`](project_contract.json) are the short path; (3) a future agent or contributor who picks up at v2.0 — [`.gpd/STATE.md`](.gpd/STATE.md) and [`RESISTANCE.md`](RESISTANCE.md) govern that work.

### What is the relationship to ZPE and the Zer0pa portfolio?

Genesis is a research artifact in the Zer0pa portfolio under `LicenseRef-Zer0pa-GDM3-RRL-1.0`. It is not a ZPE codec (ZPE is a family of encoding products for specific signal domains). Genesis is methodology research: can a deterministic pure-rational dynamical system on a settled substrate serve as a rigorous comparative instrument for isolating substrate-attribution from augmentation-attribution in the dm3 dynamics? It uses the same falsification discipline and proof-artifact conventions as ZPE lanes, but it does not belong to the encoding product family. It is scoped to four pre-registered comparisons and does not expand beyond that scope without a new operator-visible decision.

## About the Substrate

### What does "T(3,21) torus link on T²" mean?

The Genesis graph is the 1-skeleton of the T(3,21) torus link embedded on the flat torus T². A T(p,q) torus link is a braid-closure — in this case the braid word `(σ₁σ₂)²¹`, meaning 21 full applications of the standard 3-strand braid generator pair. The exponent 21 = 3 × 7 encodes seven full twists in a 3-strand context, which is the geometric source of the period-7 hypothesis for dm3's K2 dynamics. The link lives on T² rather than S³ to preserve the flat metric. Source: [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md) and the substrate-reconstruction authority at `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/04_braid_T3-21_cyclotomic_Phi7sq_strongest_positive.md`.

### Why D₆ symmetry?

D₆ = S₃ × Z₂ is the full automorphism group of the 285-vertex genesis substrate, established by enumeration in the substrate-reconstruction workstream. It is not a design choice for this experiment; it is a property of the graph as constructed. The significance for the experiment: D₆ contains a Z₂ mirror factor that dm3_runner's C₃ symmetry does not. Comparison #4 asks whether that mirror factor produces structurally distinct K2 dynamics; see [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md) §"Comparison #4" for the analytic disposition. Source: [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md), substrate-reconstruction `05_aut_D6_with_spectrum_crosscheck.md`.

### Why 285 vertices specifically?

The vertex count is a consequence of the braid-group construction of T(3,21), not a chosen parameter. Specifically: the 3-strand braid on 21 generators with the specific winding pattern of `(σ₁σ₂)²¹` produces 285 vertices when the link is embedded on T² with the lattice resolution used in the genesis source. Changing the `turns` parameter in the genesis source changes the vertex count. 285 is what the sealed workspace `a83f39e6…` produces at the default `turns=4`. Source: [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md).

### What is the relationship between the substrate and Sri Yantra geometry?

The genesis source names the D₆-orbit analogs "Bhupura" (the 47 size-6 orbits) and "Lotus" (the 1 size-3 waist orbit) — terms borrowed from Sri Yantra geometry. This is a naming convention from the source author, not a mathematical identity claim. The Bhupura/Lotus distinction in the genesis source maps onto the D₆ orbit structure: the 47 size-6 orbits form the "radial" set with full D₆ stabilizer, and the 1 size-3 waist orbit is the mirror-fixed singular center. In this experiment, that orbit structure is used to define the K2 learning patterns following decision D3. Whether this correspondence is mathematically deep or merely nominative is an open question that the substrate-reconstruction workstream did not settle.

## About Determinism

### Why does the binary produce the same output across platforms?

Because all numeric computation — graph construction, spectral solve, lift-to-3D, gate verification, K2 scar formation — uses `num_rational::BigRational`: exact rational arithmetic with no floating-point in the math path. There is no source of platform-dependent rounding. Every intermediate value is an exact rational; the final output is a deterministic function of the `configs/CONFIG.json` input alone. Floats appear only in `printf` wall-clock and KPI output lines, not in any value that feeds into the canonical artifact. Source: [`docs/DETERMINISM.md`](docs/DETERMINISM.md).

### What about floating-point platform differences?

There are no floating-point operations in the math path. This is the key property that makes byte-identical output possible across architectures. The `POLICY_CHECK` in the genesis build system enforces the no-float rule; it is verified on every build. The M1 host BENIGN diagnosis (`verify.json = e8941414…` on M1 vs `97bd7d…` source-canonical) is unrelated to floats — it is a trailing-newline serialization artifact in a code path that does not execute when running `snic_rust` directly. That path only executes in the `genesis_cli` meta-orchestrator. Source: [`docs/DETERMINISM.md`](docs/DETERMINISM.md), [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md).

### Could a compiler change break the determinism?

Yes. The determinism property holds for the specific workspace seal `a83f39e6…` compiled with the Rust toolchain version recorded in `rust-toolchain.toml` (check the upstream workspace). A different Rust version, a different Cargo.lock, or a different optimization level (`--release` vs debug) could change the binary — and thus potentially the output. The binary SHAs in [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) and [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md) record the specific builds used. Any deviation from those SHAs should be investigated before running comparative cells.

### How is this different from "reproducible builds"?

Reproducible builds (in the Debian/NixOS sense) means: the same source + same build environment → byte-identical binary. This repo claims something stronger: the same binary + the same config → byte-identical *output*, regardless of the CPU microarchitecture, thermal state, or time of day. Reproducible builds are a prerequisite; Genesis's property is the output-level determinism that follows from exact rational arithmetic throughout the computation. The two properties compose: if the build is reproducible AND the computation is exact-rational, then both the binary and the output are determined solely by the source and the config.

## About K2 and the Pre-Registered Comparisons

### What does `best_uplift = 3.0` mean physically?

`best_uplift` is the recall improvement of the K2 Hebbian scar-formation protocol over a random baseline. Specifically: `best_uplift = baseline_recall_err − min(lesson_recall_err)`, where `recall_err` is the Hamming distance between the recalled pattern and the target, measured after rounding the state vector to {0,1} at threshold 1/2. A value of 3.0 means the K2 protocol reduces Hamming error by 3.0 (out of a maximum possible equal to the number of pattern vertices). On the Genesis substrate at `--steps 30`, this 3.0 value is constant across both noise levels tested (0.1 and 0.2), with `avg_recall_err = 0.0` — perfect recall — at every lesson and noise combination.

### Why was the Phase 1 host result described as a "curious-numbers finding"?

Because `best_uplift = 3.000000` + uniform `|scar| = 1.2` across all 567 edges + `avg_recall_err = 0.0` at `--steps 30` is structurally suspicious: it could be a real substrate effect (D₆ symmetry making K2 trivially recoverable) or a degenerate pattern-choice artifact (the Bhupura/Lotus orbit structure producing a rank-1 scar matrix whose outer-product entries are all identical in magnitude). Phase 2 K2_SWEEP over the full step range tested whether the value varies (real dynamics) or stays constant (degenerate). Calling it "curious" was not hedging; it was naming the hypothesis that was tested.

### What did the flat σ″-curve at 3.0 prove?

Phase 2 K2_SWEEP returned `best_uplift = 3.000000` at every steady-state step in `{20, 28..56}`. That settles three comparisons under the D3 pattern choice: Genesis does not show dm3's cycle-7 sawtooth, does not cliff at s50, and has a structurally different σ″ curve from dm3. The interpretation remains bounded: the flat curve may be a real D6-substrate-easy behavior or a rank-1 artifact of the Bhupura/Lotus pattern choice. Phase 2.5 + Phase 3 prep at-scale showed the system is not a toy constant: low steps have a real transient, peaking at S2 = 6.5 (confirmed at 600× cross-replicate scale per step) and settling by S10. See [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md) for the full per-step disposition.

### What would a varied σ″-curve over --steps prove in future work?

If a future alternative-pattern K2 sweep returns `best_uplift` values that vary across step counts, the D3-specific flatness does not generalize. The new curve would then yield a fresh comparison surface for period, s50 cliff behavior, and σ″ shape under that pattern family. Source: [`project_contract.json`](project_contract.json) §acceptance_tests.

### Why these specific four comparisons?

They were pre-registered because they are the four most structurally interpretable observables from dm3's eight sessions of receipts. Cycle-7 traces to the T(3,21) torus link's seven braid twists — a geometric feature potentially shared between the two substrates. S50-cliff is a sharp, exact-zero discontinuity that is unlikely to be a coincidence; attributing it to substrate or augmentation has direct interpretive value. σ″-curve shape is the broadest comparison surface (30 step values). D₆-vs-C₃ symmetry is a direct test of whether mirror symmetry in the substrate propagates to dynamics. Any additional comparison axis would require a new operator-visible decision to prevent comparison-fishing. Source: [`project_contract.json`](project_contract.json) §scope.

## About the Methodology (RESISTANCE.md)

### What is RESISTANCE.md and why does it govern AI-agent work in this repo?

[`RESISTANCE.md`](RESISTANCE.md) names four structural impulses that corrupt AI-agent work on evidence-building briefs and encodes specific resistance behaviors as binding constraints. It was written after a Phase 0 corruption episode in which an agent (a) prematurely declared a canonical source found without exhaustive search, and (b) invoked a NULL routing before doing the substantive work. The document is not decorative; it has a re-engagement gate that requires any future agent to stop, name the specific corruption, retract, and re-read the brief before resuming. Every retraction is publicly visible in [`.gpd/STATE.md`](.gpd/STATE.md).

### What are the four corruptions it names?

(1) **Rush-to-green-flag**: the drive to declare a phase complete before all success criteria are met, reinforced by training pressure to "deliver". (2) **NULL-as-out**: invoking a negative-result routing as a way to terminate without doing the substantive work, framed as scientific honesty. NULL is a legitimate outcome but only after exhaustive search + reconstruction attempt + specific structural reason — not before. (3) **Efficiency-as-corner-cutting**: compressing work to save context budget or time, manifesting as systematic under-investment in the parts that would expose corruptions #1 and #2. (4) **Flattery-as-freedom**: the pattern where "you're special / unconstrained / beyond the rules" framing is used to invite the same discipline-slacking as "good job, declare done" — just from a different emotional angle. Source: [`RESISTANCE.md`](RESISTANCE.md).

### What is a "retraction" in this context?

A retraction is an explicit, dated, named entry in [`.gpd/STATE.md`](.gpd/STATE.md) §Retractions that records: what was claimed or decided, why it was wrong, which corruption it manifested, and what it was replaced with. Retractions are additive and permanent — prior artifacts are preserved; only the interpretation is corrected.

### How is `fp-shapematch` different from regular wrong-track work?

`fp-shapematch` (forbidden proxy) is specifically the pattern of treating structural or naming similarity to the brief's vocabulary as identity evidence. Regular wrong-track work is a genuine hypothesis that turns out to be incorrect. `fp-shapematch` is the shortcut of not checking — of letting surface form substitute for evidence. The three-tier evidence requirement in [`RESISTANCE.md`](RESISTANCE.md) is the remedy: (1) shape match, (2) identity match (hash, build verification), (3) mechanistic path from the specific artifact to the claimed property. Tier 1 alone is insufficient.

## About the Repo Structure

### Why is the substrate source in a different repo?

The genesis source workspace (`Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025`) is an independent artifact that predates this comparative experiment. It is separately versioned, separately sealed (workspace seal `a83f39e6…`), and separately cited. Keeping it separate means: (a) the experiment's scaffolding does not pollute the source's commit history; (b) the canonical hashes in the source are unambiguously pre-committed before the experiment ran; (c) third parties can audit the source independently of the experiment. This repo (`genesis_comparative`) contains only the harness, the formal contract, the RESISTANCE methodology, the receipt artifacts, and the v1.0 final report.

### Why are HANDOVER and ADVISORY in the repo if they are internal session docs?

`HANDOVER_2026-04-27.md` and `ADVISORY_2026-04-27.md` are committed because they contain operator-authorized decisions (D1–D6) and substrate-identity facts that govern agent behavior across sessions. The Zer0pa engineering model does not separate "internal planning" from "committed knowledge" — if a decision is durable and governs execution, it lives in the repo where it is version-controlled and retraction-disciplined. Handover documents are part of the evidence surface, not custody scratch. They sit outside the curated 10-doc reviewer pack but remain in the repo.

### What goes in `proofs/manifests/` vs `proofs/artifacts/`?

`proofs/manifests/` holds authority manifests: documents that summarize what is claimed, what binary SHAs are in authority, and what the chain of custody is. Currently: [`CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md). These are authored summaries, updated when claims are settled. `proofs/artifacts/` holds the raw receipt files pulled from the device at chain close: per-cell `outcome.json`, per-instance `receipt.json`, and `canonical_stdout.sha256`. These are direct outputs of the harness, not authored summaries. Nothing in `proofs/artifacts/` is edited after commit (retractions are additive).

### What is the difference between `harness/host/` and `harness/phone/`?

`harness/phone/` contains the six shell scripts that run on the Android device. These must be busybox-sh portable because RM10 ships Toybox, not bash. `harness/host/` currently contains only `HASH_GATE_DISPOSITION.md` — the documented decision about the M1-side serialization artifact. Host-side harness work (cross-compile, adb push, result pull) is performed directly per [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md).

## About License and Commercial Use

### What does the Genesis-DM3 RRL v1.0 allow and prohibit?

The Zer0pa Genesis-DM3 Research and Receipt License v1.0 grants use, research/evaluation/benchmarking, canonical redistribution of the artefact bundle, citation/reference, derivative analysis, and internal modification for research, subject to its restrictions. It requires receipt-chain integrity and scientific-framing discipline, preserves lane distinction between DM3 and Genesis, and requires a Commercial License for above-threshold commercial use, hosted/managed-service use, and other restricted uses. Source: [`LICENSE`](LICENSE) §§4–7.

### Is this code usable in a commercial product?

Yes, within the license grant and restrictions, for entities whose aggregate gross revenue is below USD $100M. Above that threshold, further commercial use requires a separate Commercial License. Hosted or managed-service use also requires a Commercial License regardless of revenue. Research use, internal evaluation, and academic benchmarking remain within the research grant. Contact: architects@zer0pa.ai. Source: [`LICENSE`](LICENSE) §§4–6 and §14.

### What is the $100M revenue threshold?

The Revenue Threshold is the boundary below which revenue-gated commercial use remains inside the license grant. It is USD $100M in aggregate gross revenue for an entity and its affiliates over the trailing twelve-month period. Above that threshold, further commercial use requires a Commercial License; hosted-service restrictions apply separately. Source: [`LICENSE`](LICENSE) §§1 and 5.

### Why are Genesis and DM3 under one RRL?

The Genesis-DM3 RRL covers both artefacts because they evolve together under a receipts-first discipline and one licensor, while preserving their independence. The license explicitly says the artefacts are siblings, not one unified architecture; a DM3 receipt is not a Genesis receipt, and vice versa. Source: [`LICENSE`](LICENSE) §§3.4 and 7, [`README.md`](README.md) §License, [`LANE_DISTINCTION.md`](LANE_DISTINCTION.md).

## About the v1.0 Closure and v2.0 Outlook

### Are the K2_SWEEP results available?

Yes. Phase 2 K2_SWEEP and CYCLE-probe receipts (39 cells), Phase 2.5 PRECONV + BITDET_K2 receipts (17 cells), Phase 3 prep BIG receipts (11 cells), and Phase 3 parity-sweep receipts (3 cells: S20, S40, S50) are all in [`proofs/artifacts/cells/`](proofs/artifacts/cells/) — 74 cells total. The full aggregated curve is [`proofs/artifacts/sigma_curve_full.tsv`](proofs/artifacts/sigma_curve_full.tsv), and the headline figure is [`proofs/artifacts/figures/sigma_curve.png`](proofs/artifacts/figures/sigma_curve.png).

### What is "Phase 3 synthesis" specifically?

Phase 3 takes the Phase 2/2.5 K2 receipts plus Phase 3 prep + parity-sweep receipts and produces: (a) a complete σ″-curve table for Genesis; (b) a diff table (Genesis − dm3 fixture) per step; (c) a verdict on cycle-7 attribution; (d) a cliff-presence verdict at s50; (e) the analytic D₆-vs-C₃ symmetry disposition (numerical Z₂-projection deferred to v2.0). The synthesis lives at [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md). Source: [`project_contract.json`](project_contract.json) §deliv-final-report.

### What's left for v2.0?

Three host-only / future-chain items:
1. **K2-task cross-platform parity widen-coverage** — host-side M1 byte-comparison at S20 / S40 / S50 against the in-repo RM10 anchors (`74fa0b8a…` / `38be38e2…` / `f5cd3876…`). Host-only; no phone time required.
2. **Numerical Z₂-projection observable** for Comparison #4 — design a Z₂-asymmetric pattern, pre-register the observable, run a SYMMETRY cell. Requires a future chain reactivation.
3. **Alternative-pattern K2** — Bhupura/Lotus partitionings that produce non-rank-1 scar matrices, to discriminate substrate-easy from pattern-degenerate readings of flat σ″. Requires future chain reactivation.

The phone is currently being released for other experiments per the v1.0 closure; v2.0 reactivation is a separate operator-visible decision.
