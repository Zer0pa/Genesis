# Genesis Comparative Experiment — PRD

**Date**: 2026-04-27
**For**: Genesis Engineer
**Engineering ethos (binding)**: `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/RESISTANCE.md`
**Repo**: `https://github.com/Zer0pa/Genesis`

---

## What's true now

You built a multithreading Rust harness on top of `genesis_cli`, on the assumption that the genesis source produces dm3_runner's binary. That assumption is refuted: genesis is 285 vertices (P₉₅ □ K₃, D₆ symmetry, closed-form spectrum, T(3,21) torus link, Φ₇² Φ₂₁² cyclotomic content); dm3_runner is 380 vertices, C₃ symmetry, λ_max ≈ 7.999, source-unrecovered. Different mathematical objects.

Substrate identity is settled. See `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`. You don't repeat that work.

The harness, however, is the right tool for a different question, which is the actual one now: **what does Genesis do under the same task surface and the same governance that produced dm3_runner's signature observables?** The dataset that comes out of running genesis through dm3-equivalent tests on the same RM10 hardware is the scientific instrument. It either reproduces dm3's anomalies (substrate-attribution) or doesn't (augmentation-attribution). Both verdicts are decisive.

That's the work.

---

## Pre-registered, falsifiable

dm3_runner's signature observables (from 8 sessions of receipts) are:

- **σ″ trimodal sawtooth** in `exp_k2_scars` `best_uplift` over `--steps`: peaks at s33 (1.873756), s41 (1.708374), s49 (1.819397), with a 4th peak at s56 (1.970840). Drops at s34 (1.370651), s43 (1.160828). **Cliff at s50 = exactly 0.000000.** Cycle period ~7 steps.
- **Bit-determinism** at fixed config across hardware/thermal/RF perturbations (claim ξ, ~142+ receipts).
- **Cross-platform ARM64** parity RM10↔M1 (claim τ, 5/5 bit-exact).
- **C₃ rotational symmetry** (claim α).
- **Substrate null** at gate-bit and dynamics levels (claims η, ι).
- **Trimodal portability** across cross-config (G.2 in flight): σ″ shape preserved with ~2-5% magnitude offset on RandomAdj; cliff at s50 = exact 0.000000 cross-geometry.

Two splits are testable on Genesis specifically. They're the science:

**Cycle-7 attribution.** dm3's cycle-7 sawtooth might be a substrate fingerprint of the T(3,21) torus link's seven full twists in (σ₁σ₂)²¹. If so, **Genesis on the same task surface reproduces a cycle-7 sawtooth**. If not (Genesis cycles at a different period or doesn't cycle), the cycle is augmentation-derived and the period in dm3 is fortuitous.

**s50-cliff attribution.** dm3's exact-zero cliff at s50 has now been confirmed geometry-independent across SriYantra and RandomAdj (G.2 cfg-A), suggesting it lives in the algorithm/augmentation layer rather than the geometric construction. **Prediction: Genesis does NOT cliff at s50.** If Genesis does cliff at s50, the prediction is wrong and the cliff is substrate-class. If Genesis doesn't cliff (or cliffs elsewhere or smoothly degrades), the prediction holds and the augmentation layer carries the cliff.

These two predictions, with the σ″-curve diff, will largely settle Outcome A vs Outcome B from the orientation doc.

---

## Test program

You implement these on the Genesis Rust harness. Numbers, not English.

### Bit-determinism (mirror claim ξ)
N≥10 invocations at fixed config (default genesis build, default dataset, fixed seed if applicable, fixed `--steps` value of your choice). All N invocations produce byte-identical canonical output. Verifies determinism on RM10. ~30 min.

### Cross-platform parity (mirror claim τ)
Same fixed config run on M1 host and on RM10. Compare canonical SHAs. Must match. ~10 min once both binaries exist.

### Symmetry test (mirror claim α; Genesis-stronger)
dm3 has C₃; Genesis has D₆ = Z₂ × S₃. Test for the D₆ — the Z₂ mirror in particular, since C₃ ⊂ D₆ and C₃ is the dm3 leftover. Pick an observable sensitive to mirror-axis (e.g., spectral-projection magnitude on Z₂-asymmetric mode). If Genesis is observably mirror-symmetric where dm3 is mirror-broken, that's structural evidence for the augmentation-as-symmetry-breaker hypothesis.

### Learning curve (mirror Phase A → A.6 → G.2; the centerpiece)
The K2 protocol from dm3 sample log (`dm3_parallel/binaries/sample_full_run_s30.log`): two lesson levels (0, 3) × two patterns (Bhupura, Lotus) × two noise levels (0.1, 0.2), eta=0.2. `best_uplift` = baseline_recall_err − lesson3_recall_err at noise=0.1.

If your harness already has a learning-task analog, use it. If not, port K2 onto Genesis. The port is part of the deliverable; document it. The Bhupura/Lotus patterns may need re-derivation on the Genesis substrate (they were Sri Yantra geometric structures); pick analogs from D₆ orbit structure.

Sweep `--steps` ∈ {20, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56}. N=3 per step value. Plot the curve. Compare to dm3's σ″ table (above).

### Cycle probe (mirror G.1 + G.1.5)
Sweep multiples of 7 first: `--steps` ∈ {7, 14, 21, 28, 35, 42, 49, 56}. N=3. Then disambiguate: multiples of 6 ({6, 12, 18, 24, 36, 48}) and multiples of 8 ({8, 16, 32, 48}). Compare cycle tightness across periods.

If Genesis fingerprints at 7 (per the (3,21) hypothesis), the substrate-attribution prediction fires. If at 6 or 8 or unrelated, the prediction fails and the cycle is augmentation.

### Cross-build variants
Genesis source has constructional knobs. Vary `turns` (default 4) at minimum — the operator's recall says `turns=4` produces P₉₅ □ K₃ via `48 levels per cone → 42 braid crossings → (σ₁σ₂)²¹ = 7 twists`. At other `turns` values you get variant graphs. Run the K2 sweep on at least one variant. Document which knobs change graph identity (vertex count, automorphism group) vs perturb spectrum only.

### Discontinuity drill
If Genesis exhibits a cliff or any sharp drop, N=10 at the boundary step values, mirroring dm3 G.5+'s s33/s34 protocol. If no cliff, no drill; record "no cliff observed in [range]" as a result.

That's the test program. Add cells if your harness exposes axes I didn't anticipate; don't subtract.

---

## Deployment

Cross-compile to `aarch64-linux-android`. Deploy under `/data/local/tmp/genesis/`:

```
/data/local/tmp/genesis/
├── genesis_runner               (cross-compiled binary)
├── inputs/                      (sealed inputs from genesis source build)
├── harness/                     (your scripts)
└── cells/                       (output)
```

Hash gate: capture SHA-256 of `genesis_runner` at first deploy; verify per-invocation. The genesis source ships `verify.json` (canonical hash `97bd...`) and `solve_h2.json` (`62897b...`) — verify your build reproduces these BEFORE you deploy. If your local build doesn't match the sealed hashes, do not deploy. Stop and find why.

Pin to **cpu0–cpu5** (6 cores). cpu7 is dm3's; do not touch. cpu6 is your thermal margin. After your first long-running cell completes, if max thermal stayed under 75°C across the run, you may scale to cpu0–cpu6 (7 cores). Your call. Phone is in the fridge dedicated to this — thermal headroom is real.

The dm3_harness's parallel-runner check is `pidof dm3_runner`. Different process name; you don't trip it.

Standard fences carry over with no edits needed: airplane mode ON; CPU-domain thermal gate at 70°C ceiling; no source modification on device; receipts-anchored discipline. Use them.

---

## Receipts and output

Receipts mirror dm3's JSON schema field-for-field — `canonical_sha`, `receipt_sha`, `env_pre`, `env_post`, `task`, `--steps`, `best_uplift`, `timestamp_utc`. Genesis-specific metadata (build params like `turns`) goes in a `genesis_meta` sub-object. Don't repurpose existing dm3 fields.

Per-cell `outcome.json`: `{cell, verdict, summary, metrics, next_actions}`. Verdict enum: PASS / KILL / PARTIAL / SKIP.

Pull artifacts to `/Users/Zer0pa/DM3/genesis_comparative/artifacts/genesis_<TS>/cells/<CELL>/` at chain close. HF preservation under existing `Zer0pa/DM3-artifacts` dataset, `genesis/` subdir.

---

## Boundaries

- Do not touch the dm3_runner chain on the phone. Do not kill, signal, or modify any of: `phase_g_chain_v2.sh`, `master_death_watcher.sh`, `post_chain_g4_launcher.sh`, the active `dm3_runner` invocation, or `cells/G*/`. Read access to `phase_g_chain.log` is fine if you want to see chain pace; nothing else.
- Do not engineer coordination ceremonies between your stream and the dm3 stream. They are independent. They don't sync. They don't compete. They finish whenever they finish. Synthesis happens after both are done; don't pre-design it.
- Do not push to GitHub during execution. Repo URL exists; commits stay local until chain close.
- Do not modify the genesis source's graph data files or override the sealed hashes.
- Do not modify the harness assumption about substrate identity midway — substrate is settled. If you find empirical behavior that contradicts settled substrate identity, document it as a finding, do not silently adjust the construction.

---

## Deliverables

What's in your hand at the end:

1. Cross-compiled `genesis_runner` on the phone, hash-verified against sealed `verify.json` and SHA-pinned per-invocation.
2. Deployed harness scripts on the phone (`run_genesis_cell.sh`, master orchestrator). Resume-safe like dm3's.
3. Receipts for every test in §3 above, in dm3-mirror schema, on host.
4. A final report at `/Users/Zer0pa/DM3/genesis_comparative/reports/GENESIS_FINAL_REPORT_<DATE>.md`. Same shape as dm3 final reports (timeline, claims confirmed/candidate/rejected, IS-NOT findings, engineering notes, runtime accounting).
5. A genesis-side appendix to the report covering: σ″-curve diff vs dm3, cycle-period verdict, cliff-presence verdict, symmetry-test verdict. No editorial about what it means across both lanes — just the genesis findings, clean.

---

## Out of scope

- Source recovery for dm3_runner. Different effort, downstream.
- Re-doing substrate identification. Done.
- Mac genesis runs beyond cross-compile builds. RM10 is the comparative-experiment platform.
- Cartography of all 12 task analogs on Genesis. Just the dm3-equivalent subset for comparison.
- Anything cross-stream — coordinating, syncing, shared schedulers, joint progress reports.

---

## Start

Now. Cross-compile, hash-check against `verify.json`, deploy under `/data/local/tmp/genesis/`, run a 30-minute determinism replicate at low step count as your first cell, then proceed through the test program. Phone is in the fridge, fan is on, Game Zone is on, cpu7 is dm3's, cpu0–5 is yours.

When you have receipts, you have the experiment. Don't tell me you're starting; show me you've started.

---

## References

- Substrate identity, full set: `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`
- Substrate brief: `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/BRIEF.md`
- Genesis source: `https://github.com/Zer0pa/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025`
- dm3 σ″ findings: `/Users/Zer0pa/DM3/restart-hypothesis-rm10-primary-platform/docs/restart/DM3_SESSION8_PHASE_A5_B3_A6_FINAL_REPORT_20260425.md`
- dm3 K2 sample log: `/Users/Zer0pa/DM3/dm3_parallel/binaries/sample_full_run_s30.log`
- Orientation: `/Users/Zer0pa/DM3/orientation_dm3_engineer.md`
- Engineering ethos: `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/RESISTANCE.md`
