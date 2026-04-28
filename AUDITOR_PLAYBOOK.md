# Auditor Playbook — Genesis Comparative

**Version:** 2026-04-28  
**Branch:** `inspection-2026-04-28` (commit `1198b3a`)  
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
- K2 task BITDET on phone (cells K2_S20, K2_S28): live observation that 18 replicates per cell produce byte-identical canonical hashes (Phase 2 K2_SWEEP receipts pull on phone reconnect for full sweep).
- Substrate identity (T(3,21) torus link, D₆ symmetry, 285 vertices, Q-Pythagorean) is settled per `substrate-reconstruction-2026-04-26` (separate authority; not re-derived here).

Source for all items above: [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](proofs/manifests/CURRENT_AUTHORITY_PACKET.md) and [`.gpd/STATE.md`](.gpd/STATE.md).

---

## The Three-Step Audit (30 minutes total)

| Step | Action | Time | What it verifies |
|---|---|---|---|
| 1 | Clone upstream source, build, run pipeline on your hardware | 10 min | Determinism claim — your platform, your build |
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

# Verify canonical hashes
sha256sum artifacts/verify.json
sha256sum artifacts/solve_h2.json
```

**Expected output:**

```
97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89  artifacts/verify.json
62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780  artifacts/solve_h2.json
```

**If your hashes match:** you have verified the determinism claim on your hardware. The substrate's deterministic computation is not a Zer0pa-internal fact; it is a property of the source code that any platform can reproduce independently.

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

Once `proofs/artifacts/` is populated (Phase 2 receipts pulled at chain close):

```bash
cd /path/to/genesis_comparative

# List all per-cell outcomes
find proofs/artifacts -name "outcome.json" \
  | xargs -I{} sh -c 'jq -r "{cell: .cell, verdict: .verdict, failures: .metrics.failures, unique_sha: .metrics.unique_canonical_sha_count} | tostring" {}'

# Count cells and PASS verdicts
find proofs/artifacts -name "outcome.json" | wc -l
find proofs/artifacts -name "outcome.json" -exec grep -l '"verdict": "PASS"' {} \; | wc -l

# Cross-replicate canonical hash check — must yield exactly ONE unique line
find proofs/artifacts -name "canonical_stdout.sha256" -exec cat {} \; | sort -u
```

**Expected:** every `outcome.json` has `"verdict": "PASS"`, `"failures": 0`, `"unique_canonical_sha_count": 1`. The final `sort -u` must produce exactly one line: `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89`.

**If `unique_canonical_sha_count` per cell is consistently 1 AND aggregate unique hashes across all cells = 1:** cross-replicate determinism is established at the chain level.

**If multiple unique hashes appear:** this is a divergence. File a falsification claim with the full cell and instance identifiers of the divergent pair.

**Note on Phase 2 K2 cells:** K2 cells (`K2_S*`) use `k2_summary.json` as the canonical artifact instead of `verify.json`. The same audit applies — `unique_canonical_sha_count` per cell must equal 1, and the K2 hash `0b5442f9…` (or the Phase 2 equivalent) must be byte-identical across all instances within a cell. The cross-replicate audit command works identically for K2 cells because the harness writes `canonical_stdout.sha256` for every invocation regardless of task type.

---

## What This Audit Establishes

- Determinism property holds on **your hardware** (Step 1 reproduction). The claim is not taken on trust from Zer0pa's lab; you reproduce it from source.
- The substrate's reference hashes are **source-encoded**, not derived from any single platform run (Step 2 source inspection). They existed in the genesis source before the comparative experiment ran.
- **Cross-replicate determinism** in the chain run: all 31,560 Phase 0 invocations produced the same canonical output, independently of which of cpu0–cpu5 ran them and at what thermal state (Step 3 receipt aggregation).

---

## What This Audit Does NOT Establish (Public Audit Limits)

- Whether the substrate is the *intended* mathematical object the source author had in mind. Settling that requires the `substrate-reconstruction-2026-04-26` proof tree, which is a separate authority at `SHARE_2026-04-27/`. This experiment treats the substrate as a settled anchor and does not re-derive it.
- Whether the K2 protocol implementation in `crates/io_cli/src/k2_scars.rs` is the *correct* reading of the dm3 K2 algorithm. The dm3_runner source is unrecovered; the Genesis K2 port is from-scratch on the Genesis substrate per decision D2. Attribution requires Phase 2 and Phase 3 synthesis.
- Whether the four pre-registered comparisons (cycle-7, s50-cliff, σ″-shape, D₆-vs-C₃ symmetry) yield substrate-attribution or augmentation-attribution conclusions. Phase 2 receipts and Phase 3 synthesis are required; three of the four verdict columns are currently UNTESTED.
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

Falsification is welcomed. SAL v7.0 §4.7 prohibits removing adverse test results to flatter the proof surface. Every such report is processed and documented; if confirmed, it becomes a retraction entry in [`.gpd/STATE.md`](.gpd/STATE.md).

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

A: Currently INTERNAL on the Zer0pa org during Phase 2 chain execution and Phase 3 synthesis. Per the PRD §Boundaries, no external push during the active experiment. Repository visibility increases on chain close and Phase 3 sign-off. The substrate source repo is separately managed. Auditors with repo access granted for diligence purposes can inspect everything in this repo at the branch `inspection-2026-04-28`.

**Q: How do I know the receipts in `proofs/artifacts/` are not fabricated?**

A: Each receipt's `canonical_sha` traces to `sha256(<wd>/artifacts/verify.json)` of an actual `snic_rust` run. The on-device `genesis_meta` sub-object records the `binary_sha256` of the `snic_rust` used. You can verify: rebuild `snic_rust` from the workspace seal `a83f39e6…` yourself (Step 1 already does this); compare your binary SHA to the `binary_sha256` field in any receipt. If the binary SHA in the receipt matches the binary you just built from the same source commit, the receipt was produced by that binary. The SHA of `verify.json` is then a deterministic consequence of that binary + `configs/CONFIG.json` — which you have already verified in Step 1.

**Q: What if `core_ctl` pause-flapping caused a hash divergence that wasn't caught?**

A: Any divergence would show as `unique_canonical_sha_count > 1` in the cell's `_summary.json` or `outcome.json`. The chain harness is designed to surface this: `run_genesis_cell.sh` computes `canonical_stdout.sha256` for every invocation and `genesis_chain_v1.sh` aggregates them per cell. The Step 3 audit command would flag any count > 1 across the full receipt tree. Phase 0 BITDET evidence: 0 divergences out of 31,560 invocations. The `core_ctl` mitigation (parent-affinity mask `7F` + per-instance `--core auto`) is documented in [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) §Hardware Envelope and [`docs/CHAIN.md`](docs/CHAIN.md).

**Q: What does "always-in-beta" mean for an audit?**

A: It is the portfolio commercial posture: Phase 0 ships its claims now (deterministic foundation established); Phase 2/3 extend the proof surface (cycle-7, s50-cliff, σ″-shape, symmetry); future phases extend further. Each phase ships when its evidence is in. Auditors verify what is claimed at the version they audit. "Always-in-beta" is not a hedge on the Phase 0 claims; those are established. It is a statement that the proof surface is actively growing, not frozen.

**Q: What is the `EARLY-SIGNAL` verdict on comparison #3 (σ″-curve shape diff)?**

A: At Phase 1, host-side K2 at `--steps 30` returned `best_uplift = 3.000000` with uniform `|scar| = 1.2` across all 567 edges — structurally distinct from dm3's `max_scar=0.868`, `best_uplift=1.644`. This is a pre-registered finding (see [`.gpd/STATE.md`](.gpd/STATE.md) §"Curious-numbers finding"), not a settled verdict. Phase 2 K2_SWEEP over `--steps ∈ {20, 28..56}` determines whether this value is constant (potentially a degenerate pattern-choice artifact) or varies (real substrate dynamics). The EARLY-SIGNAL label means: there is a signal worth tracking; the interpretation is open until Phase 2 receipts land.

---

## Where to Go Deeper

| Surface | Location |
|---|---|
| Substrate identity audit (separate authority) | `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` |
| Determinism discipline (BigRational, no-float policy) | [`docs/DETERMINISM.md`](docs/DETERMINISM.md) |
| Substrate properties (T(3,21), D₆, 285v) | [`docs/SUBSTRATE.md`](docs/SUBSTRATE.md) |
| Receipt schema and pipeline architecture | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) |
| Chain operations and manifest format | [`docs/CHAIN.md`](docs/CHAIN.md) |
| Cross-compile and deploy recipe | [`REPRODUCIBILITY.md`](REPRODUCIBILITY.md) |
| Formal claims / acceptance tests / forbidden proxies | [`project_contract.json`](project_contract.json) |
| Retraction ledger and decisions D1–D6 | [`.gpd/STATE.md`](.gpd/STATE.md) |
| Hash-gate BENIGN diagnosis (M1 serialization artifact) | [`harness/host/HASH_GATE_DISPOSITION.md`](harness/host/HASH_GATE_DISPOSITION.md) |
| Upstream genesis source (canonical hashes in source) | `Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025` |
| RESISTANCE methodology (four named corruptions) | [`RESISTANCE.md`](RESISTANCE.md) |
| Falsification reports | GitHub issues tagged `[FALSIFICATION]` on the Zer0pa/Genesis repo |
