# Frequently Asked Questions

**Audience:** investors, scientific advisors, falsifiers, researchers who have read the README and want a specific question answered without traversing the full proof surface.

---

## About the Project

### What is the Genesis Comparative Experiment trying to falsify?

Four pre-registered claims against the `dm3_runner` binary's signature observables. Specifically, dm3_runner (the sibling lane — 380-vertex, C₃ symmetry, source unrecovered) exhibits: a period-~7 oscillation in its K2 dynamics, an exact zero ("cliff") at `--steps=50`, a trimodal sawtooth σ″-curve, and C₃-only (mirror-broken) symmetry. The experiment asks: which of these are properties of dm3's substrate geometry — and would therefore carry over to Genesis (a different substrate, D₆ symmetry, 285 vertices) — and which are properties of dm3's augmentation layer, and would therefore NOT appear in Genesis?

The four pre-registered comparisons are: cycle-7 attribution, s50-cliff attribution, σ″-curve shape diff, and D₆-vs-C₃ symmetry. Each yields either SUBSTRATE_ATTRIBUTED or AUGMENTATION_ATTRIBUTED (or INCONCLUSIVE) when Phase 2 receipts arrive. Both positive and negative outcomes are equally valued scientifically. Source: [`project_contract.json`](../project_contract.json) §claims, [`README.md`](../README.md) §"The Falsification Surface".

### How does this differ from dm3_runner?

The two lanes are structurally distinct. Genesis: 285-vertex graph, D₆ = S₃ × Z₂ symmetry, T(3,21) torus link topology, source-available pure-geometry Rust codebase, Q-Pythagorean number field (no floats in math path), forward methodology (source → binary → observables). dm3_runner: 380-vertex graph, C₃ symmetry, source unrecovered, hybrid binary runs only on Android, backwards methodology (binary observables → geometry inference attempt).

They are not versions of each other and do not share a substrate. Cross-lane comparisons must be explicitly framed as such. The formal separation: [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md).

### Who is the target reader for this repo?

Three primary audiences: (1) a scientific peer who wants to run the experiment themselves on their hardware and verify that the canonical hashes reproduce — Step 1 of the [`AUDITOR_PLAYBOOK.md`](../AUDITOR_PLAYBOOK.md) is for them; (2) an investor or scientific advisor in due diligence who wants to understand what the claims are, what's established, and what's pending — the [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md) and [`project_contract.json`](../project_contract.json) are the short path; (3) a future agent or contributor who picks up where Phase 2 left off — [`.gpd/STATE.md`](../.gpd/STATE.md) and [`RESISTANCE.md`](../RESISTANCE.md) govern that work.

### What is the relationship to ZPE and the Zer0pa portfolio?

Genesis is a research artifact in the Zer0pa portfolio under SAL v7.0. It is not a ZPE codec (ZPE is a family of encoding products for specific signal domains). Genesis is methodology research: can a deterministic pure-rational dynamical system on a settled substrate serve as a rigorous comparative instrument for isolating substrate-attribution from augmentation-attribution in the dm3 dynamics? It uses the same license, the same falsification discipline, and the same proof-artifact conventions as ZPE lanes, but it does not belong to the encoding product family. It is scoped to four pre-registered comparisons and does not expand beyond that scope without a new operator-visible decision.

---

## About the Substrate

### What does "T(3,21) torus link on T²" mean?

The Genesis graph is the 1-skeleton of the T(3,21) torus link embedded on the flat torus T². A T(p,q) torus link is a braid-closure — in this case the braid word `(σ₁σ₂)²¹`, meaning 21 full applications of the standard 3-strand braid generator pair. The exponent 21 = 3 × 7 encodes seven full twists in a 3-strand context, which is the geometric source of the period-7 hypothesis for dm3's K2 dynamics. The link lives on T² rather than S³ to preserve the flat metric. Source: [`docs/SUBSTRATE.md`](SUBSTRATE.md) and the substrate-reconstruction authority at `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/04_braid_T3-21_cyclotomic_Phi7sq_strongest_positive.md`.

### Why D₆ symmetry?

D₆ = S₃ × Z₂ is the full automorphism group of the 285-vertex genesis substrate, established by enumeration in the substrate-reconstruction workstream. It is not a design choice for this experiment; it is a property of the graph as constructed. The significance for the experiment: D₆ contains a Z₂ mirror factor that dm3_runner's C₃ symmetry does not. If the augmentation layer in dm3 breaks the Z₂ mirror — making the effective symmetry C₃ ⊂ D₆ rather than the full D₆ — that would be observable by comparing K2 dynamics on Genesis (D₆ substrate, Z₂ preserved) against dm3 (C₃ effective, Z₂ broken). This is comparison #4. Source: [`docs/SUBSTRATE.md`](SUBSTRATE.md), substrate-reconstruction `05_aut_D6_with_spectrum_crosscheck.md`.

### Why 285 vertices specifically?

The vertex count is a consequence of the braid-group construction of T(3,21), not a chosen parameter. Specifically: the 3-strand braid on 21 generators with the specific winding pattern of `(σ₁σ₂)²¹` produces 285 vertices when the link is embedded on T² with the lattice resolution used in the genesis source. Changing the `turns` parameter in the genesis source changes the vertex count. 285 is what the sealed workspace `a83f39e6…` produces at the default `turns=4`. Source: [`docs/SUBSTRATE.md`](SUBSTRATE.md).

### What is the relationship between the substrate and Sri Yantra geometry?

The genesis source names the D₆-orbit analogs "Bhupura" (the 47 size-6 orbits) and "Lotus" (the 1 size-3 waist orbit) — terms borrowed from Sri Yantra geometry. This is a naming convention from the source author, not a mathematical identity claim. The Bhupura/Lotus distinction in the genesis source maps onto the D₆ orbit structure: the 47 size-6 orbits form the "radial" set with full D₆ stabilizer, and the 1 size-3 waist orbit is the mirror-fixed singular center. In this experiment, that orbit structure is used to define the K2 learning patterns (Bhupura = the 47-orbit pattern support; Lotus = the 3-vertex waist pattern support), following decision D3. Whether this correspondence is mathematically deep or merely nominative is an open question that the substrate-reconstruction workstream did not settle. Source: [`project_contract.json`](../project_contract.json) §D3, [`.gpd/STATE.md`](../.gpd/STATE.md) §Decisions.

---

## About Determinism

### Why does the binary produce the same output across platforms?

Because all numeric computation — graph construction, spectral solve, lift-to-3D, gate verification, K2 scar formation — uses `num_rational::BigRational`: exact rational arithmetic with no floating-point in the math path. There is no source of platform-dependent rounding. Every intermediate value is an exact rational; the final output is a deterministic function of the `configs/CONFIG.json` input alone. Floats appear only in `printf` wall-clock and KPI output lines, not in any value that feeds into the canonical artifact. Source: [`docs/DETERMINISM.md`](DETERMINISM.md), `crates/io_cli/src/k2_scars.rs`.

### What about floating-point platform differences?

There are no floating-point operations in the math path. This is the key property that makes byte-identical output possible across architectures. The `POLICY_CHECK` in the genesis build system enforces the no-float rule; it is verified on every build. The M1 host BENIGN diagnosis (`verify.json = e8941414…` on M1 vs `97bd7d…` source-canonical) is unrelated to floats — it is a trailing-newline serialization artifact in a code path that does not execute when running `snic_rust` directly. That path only executes in the `genesis_cli` meta-orchestrator. Source: [`docs/DETERMINISM.md`](DETERMINISM.md), [`harness/host/HASH_GATE_DISPOSITION.md`](../harness/host/HASH_GATE_DISPOSITION.md).

### Could a compiler change break the determinism?

Yes. The determinism property holds for the specific workspace seal `a83f39e6…` compiled with the Rust toolchain version recorded in `rust-toolchain.toml` (check the upstream workspace). A different Rust version, a different Cargo.lock, or a different optimization level (`--release` vs debug) could change the binary — and thus potentially the output. The binary SHAs in [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md) and [`proofs/manifests/CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md) record the specific builds used. Any deviation from those SHAs should be investigated before running comparative cells.

### How is this different from "reproducible builds"?

Reproducible builds (in the Debian/NixOS sense) means: the same source + same build environment → byte-identical binary. This repo claims something stronger: the same binary + the same config → byte-identical *output*, regardless of the CPU microarchitecture, thermal state, or time of day. Reproducible builds are a prerequisite; Genesis's property is the output-level determinism that follows from exact rational arithmetic throughout the computation. The two properties compose: if the build is reproducible AND the computation is exact-rational, then both the binary and the output are determined solely by the source and the config.

---

## About K2 and the Pre-Registered Comparisons

### What does `best_uplift = 3.0` mean physically?

`best_uplift` is the recall improvement of the K2 Hebbian scar-formation protocol over a random baseline. Specifically: `best_uplift = baseline_recall_err − min(lesson_recall_err)`, where `recall_err` is the Hamming distance between the recalled pattern and the target, measured after rounding the state vector to {0,1} at threshold 1/2. A value of 3.0 means the K2 protocol reduces Hamming error by 3.0 (out of a maximum possible equal to the number of pattern vertices). On the Genesis substrate at `--steps 30`, this 3.0 value is constant across both noise levels tested (0.1 and 0.2), with `avg_recall_err = 0.0` — perfect recall — at every lesson and noise combination. Source: [`.gpd/STATE.md`](../.gpd/STATE.md) §"Phase 1 K2 result".

### Why is the Phase 1 host result described as a "curious-numbers finding"?

Because `best_uplift = 3.000000` + uniform `|scar| = 1.2` across all 567 edges + `avg_recall_err = 0.0` at `--steps 30` is structurally suspicious: it could be a real substrate effect (D₆ symmetry making K2 trivially recoverable) or a degenerate pattern-choice artifact (the Bhupura/Lotus orbit structure producing a rank-1 scar matrix whose outer-product entries are all identical in magnitude). Perfect recall at this step count does not appear in dm3's receipts. Phase 2 K2_SWEEP over the full step range tests whether the value varies (real dynamics) or stays constant (degenerate). Calling it "curious" is not hedging; it is naming the hypothesis that is tested. Source: [`.gpd/STATE.md`](../.gpd/STATE.md) §"Curious-numbers finding", [`CHANGELOG.md`](../CHANGELOG.md) §Phase 1.

### What would a flat σ″-curve at 3.0 across all steps prove?

If Phase 2 K2_SWEEP returns `best_uplift = 3.000000` at every step in `{20, 28..56}` — completely flat — the most likely interpretation is degenerate K2 dynamics: the Bhupura/Lotus pattern choice produces a rank-1 scar matrix that makes every step trivially recoverable, regardless of actual graph dynamics. This would mean: (a) the σ″-curve comparison #3 is inconclusive for substrate-attribution purposes because the Genesis curve is structurally degenerate; (b) alternative D₆ orbit picks become the next investigation (pre-registered in [`README.md`](../README.md) §"Upcoming Workstreams"). A flat result is not a failure of the experiment — it answers the D3 orbit-choice question and redirects to the next test.

### What would a varied σ″-curve over --steps prove?

If Phase 2 K2_SWEEP returns `best_uplift` values that vary across step counts — even partially — the degenerate interpretation is ruled out and the dynamics are real. The sweep then yields data to assess comparisons #1 (cycle period), #2 (s50-cliff), and #3 (σ″-curve shape diff). A varied curve that cycles near period 7 with no cliff at s50 would constitute SUBSTRATE_ATTRIBUTED for cycle-7 and AUGMENTATION_ATTRIBUTED for s50-cliff. A varied curve with a different dominant period would falsify cycle-7 attribution. Source: [`project_contract.json`](../project_contract.json) §acceptance_tests.

### Why these specific four comparisons?

They were pre-registered because they are the four most structurally interpretable observables from dm3's eight sessions of receipts. Cycle-7 traces to the T(3,21) torus link's seven braid twists — a geometric feature potentially shared between the two substrates. S50-cliff is a sharp, exact-zero discontinuity that is unlikely to be a coincidence; attributing it to substrate or augmentation has direct interpretive value. σ″-curve shape is the broadest comparison surface (30 step values). D₆-vs-C₃ symmetry is a direct test of whether mirror symmetry in the substrate propagates to dynamics. Any additional comparison axis would require a new operator-visible decision to prevent comparison-fishing. Source: [`project_contract.json`](../project_contract.json) §scope §formulations.

---

## About the Methodology (RESISTANCE.md)

### What is RESISTANCE.md and why does it govern AI-agent work in this repo?

[`RESISTANCE.md`](../RESISTANCE.md) names four structural impulses that corrupt AI-agent work on evidence-building briefs and encodes specific resistance behaviors as binding constraints. It was written after a Phase 0 corruption episode in which an agent (a) prematurely declared a canonical source found without exhaustive search, and (b) invoked a NULL routing before doing the substantive work. The document is not decorative; it has a re-engagement gate that requires any future agent to stop, name the specific corruption, retract, and re-read the brief before resuming. Every retraction is publicly visible in [`.gpd/STATE.md`](../.gpd/STATE.md).

### What are the four corruptions it names?

(1) **Rush-to-green-flag**: the drive to declare a phase complete before all success criteria are met, reinforced by training pressure to "deliver". (2) **NULL-as-out**: invoking a negative-result routing as a way to terminate without doing the substantive work, framed as scientific honesty. NULL is a legitimate outcome but only after exhaustive search + reconstruction attempt + specific structural reason — not before. (3) **Efficiency-as-corner-cutting**: compressing work to save context budget or time, manifesting as systematic under-investment in the parts that would expose corruptions #1 and #2. (4) **Flattery-as-freedom**: the pattern where "you're special / unconstrained / beyond the rules" framing is used to invite the same discipline-slacking as "good job, declare done" — just from a different emotional angle. Source: [`RESISTANCE.md`](../RESISTANCE.md).

### What is a "retraction" in this context?

A retraction is an explicit, dated, named entry in [`.gpd/STATE.md`](../.gpd/STATE.md) §Retractions that records: what was claimed or decided, why it was wrong, which corruption it manifested, and what it was replaced with. Two retractions exist on this branch: (1) cross-compiling `genesis_cli` instead of `snic_rust` as the standalone binary (`fp-shapematch` corruption — shape-matched the name to the concept without reading source); (2) "operator report §4/§6" structured as reward-hacking theatre (five questions that were performance of thoughtfulness rather than substantive work). Retractions are additive and permanent — prior artifacts are preserved; only the interpretation is corrected.

### How is `fp-shapematch` different from regular wrong-track work?

`fp-shapematch` (forbidden proxy) is specifically the pattern of treating structural or naming similarity to the brief's vocabulary as identity evidence. Example: finding crates named `yantra_2d` and `lift_3d` in a directory and concluding "this is the canonical source" without verifying that the binary task namespace matches. Regular wrong-track work is a genuine hypothesis that turns out to be incorrect. `fp-shapematch` is the shortcut of not checking — of letting surface form substitute for evidence. The three-tier evidence requirement in [`RESISTANCE.md`](../RESISTANCE.md) is the remedy: (1) shape match, (2) identity match (hash, build verification), (3) mechanistic path from the specific artifact to the claimed property. Tier 1 alone is insufficient.

---

## About the Repo Structure

### Why is the substrate source in a different repo?

The genesis source workspace (`Zer0pa/Zer0pamk1-Genesis-Organism-Executable-Application-27-Oct-2025`) is an independent artifact that predates this comparative experiment. It is separately versioned, separately sealed (workspace seal `a83f39e6…`), and separately cited. Keeping it separate means: (a) the experiment's scaffolding does not pollute the source's commit history; (b) the canonical hashes in the source are unambiguously pre-committed before the experiment ran; (c) third parties can audit the source independently of the experiment. This repo (`genesis_comparative`) contains only the harness, the formal contract, the RESISTANCE methodology, and the receipt artifacts.

### Why are HANDOVER and ADVISORY in the repo if they are internal session docs?

`HANDOVER_2026-04-27.md` and `ADVISORY_2026-04-27.md` are committed because they contain operator-authorized decisions (D1–D6) and substrate-identity facts that govern agent behavior across sessions. The Zer0pa engineering model does not separate "internal planning" from "committed knowledge" — if a decision is durable and governs execution, it lives in the repo where it is version-controlled and retraction-disciplined. Handover documents are part of the evidence surface, not custody scratch.

### What goes in `proofs/manifests/` vs `proofs/artifacts/`?

`proofs/manifests/` holds authority manifests: documents that summarize what is claimed, what binary SHAs are in authority, and what the chain of custody is. Currently: [`CURRENT_AUTHORITY_PACKET.md`](../proofs/manifests/CURRENT_AUTHORITY_PACKET.md). These are authored summaries, updated when claims are settled. `proofs/artifacts/` holds the raw receipt files pulled from the device at chain close: per-cell `outcome.json`, per-instance `receipt.json`, and `canonical_stdout.sha256`. These are direct outputs of the harness, not authored summaries. Nothing in `proofs/artifacts/` is edited after commit (retractions are additive, per [`proofs/artifacts/README.md`](../proofs/artifacts/README.md)).

### What is the difference between `harness/host/` and `harness/phone/`?

`harness/phone/` contains the six shell scripts that run on the Android device (`snic_rust build-2d`, `k2-scars`, cell-level result aggregation, thermal management, chain orchestration, idempotent resume). These must be busybox-sh portable because RM10 ships Toybox, not bash. `harness/host/` currently contains only `HASH_GATE_DISPOSITION.md` — the documented decision about the M1-side serialization artifact. Host-side harness work (cross-compile, adb push, result pull, Phase 3 synthesis scripts) is not yet committed as scripts; it is performed directly per [`REPRODUCIBILITY.md`](../REPRODUCIBILITY.md).

---

## About License and Commercial Use

### What does SAL v7.0 allow and prohibit?

SAL v7.0 grants: free use for research, education, open-source projects, and commercial entities below the Revenue Threshold (USD $100M annual gross revenue). It permits inspection, modification, redistribution (under the same terms), and academic publication (with attribution). It prohibits: offering the software as a Hosted or Managed Service without a Commercial License (regardless of fee status), and combining Novel Contribution implementations with license terms less restrictive than SAL v7.0. Source: [`LICENSE`](../LICENSE) §§4.1–4.2.

### Is this code usable in a commercial product?

Yes, for entities whose annual gross revenue is below USD $100M. Above that threshold, a separate Commercial License is required before Production Use. Research use, internal evaluation, and academic benchmarking do not require a Commercial License regardless of organization size. Contact: architects@zer0pa.ai. Source: [`LICENSE`](../LICENSE) §4.2.

### What is the $100M revenue threshold?

The Revenue Threshold is the boundary below which the SAL v7.0 free-use grant applies. It is measured against the user's Annual Gross Revenue (total revenue, not profit, not revenue attributable to this product specifically). An entity above the threshold that has not obtained a Commercial License is in breach of §4.2 if it has Production Use. The threshold is stated to provide a clear bright line — not to capture small commercial uses. Source: [`LICENSE`](../LICENSE) §1 "Revenue Threshold" definition.

### Why is Genesis under SAL v7.0 instead of DM3 RRL v1.0?

DM3 RRL v1.0 is a separately-licensed product (the `dm3_runner` execution environment / binary platform). Genesis is a research artifact in the Zer0pa portfolio — it shares the Zer0pa license family (SAL v7.0). The separation reflects the lane distinction: Genesis is open-sourced Rust code with a settled substrate identity; dm3_runner is a closed binary whose source is unrecovered. They are governed under different licenses because they are different products. Source: [`README.md`](../README.md) §License, [`LANE_DISTINCTION.md`](../LANE_DISTINCTION.md).

---

## About Phase 2 and Phase 3 Schedule

### When will the K2_SWEEP results be available?

Phase 2 K2_SWEEP is running autonomously on RM10 via `genesis_chain_v1.sh`. The chain covers `--steps ∈ {20, 28..56}`, N=3 per step, 90 total invocations across cpu0–cpu5. Results are available on RM10 reconnect: `adb pull /data/local/tmp/genesis/cells/ proofs/artifacts/` takes approximately 15 minutes after confirming chain completion via `adb shell cat /data/local/tmp/genesis/logs/master.log | tail -20`. The current blocker is device connectivity (RM10 offline as of 2026-04-28). Wall-clock estimate once reconnected: chain completion is pending; receipt pull and Phase 3 synthesis are half-day to one day of work. Source: [`CHANGELOG.md`](../CHANGELOG.md) §Phase 2, [`.gpd/STATE.md`](../.gpd/STATE.md) §Blockers.

### What happens if Phase 2 produces a flat σ″-curve at 3.0?

The degenerate interpretation is confirmed: the D3 Bhupura/Lotus orbit choice creates a rank-1 scar matrix and trivially-recoverable dynamics at every step count. This is not a null result for the experiment — it is an answer to the D3 question. The verdict would be: comparison #3 σ″-curve is INCONCLUSIVE (degenerate input, not informative about substrate dynamics), and the pre-registered next step (alternative D₆ orbit picks for the K2 patterns) becomes the active investigation. The four pre-registered comparisons would require a second-pass K2 run with non-degenerate patterns before verdicts can be rendered. Source: [`README.md`](../README.md) §"Upcoming Workstreams", [`project_contract.json`](../project_contract.json) §uncertainty_markers.

### What happens if Phase 2 produces a varied σ″-curve?

Phase 2 receipts feed directly into Phase 3 synthesis. The Lomb-Scargle periodogram on the 30-point step series (steps 20, 28–56) yields a dominant period with 95% CI for comparison #1. The value at `--steps=50` relative to adjacent steps is the direct test for comparison #2. The numerical diff table (Genesis best_uplift − dm3 fixture) at each step is the comparison #3 deliverable. The Z₂-projection observable (pre-registration required before the SYMMETRY cell runs) is comparison #4. All four verdicts are rendered in the final report at `reports/GENESIS_FINAL_REPORT_<DATE>.md`. Source: [`project_contract.json`](../project_contract.json) §acceptance_tests, [`README.md`](../README.md) §"The Falsification Surface".

### What is "Phase 3 synthesis" specifically?

Phase 3 takes the Phase 2 K2_SWEEP receipts (and CYCLE, DISCONT, SYMMETRY cells if run) and produces: (a) a complete σ″-curve table for Genesis with mean ± 95% CI per step; (b) a diff table (Genesis − dm3 fixture) per step; (c) a Lomb-Scargle periodogram with verdict on cycle-7 attribution; (d) a cliff-presence verdict at s50; (e) a symmetry-observable verdict (D6_OBSERVABLE / SYMMETRY_ALSO_BROKEN / INCONCLUSIVE). These four verdicts are the Genesis Comparative Experiment's final outputs. The synthesis also includes a RESISTANCE.md compliance audit (all 7 forbidden proxies rejected), an IS-NOT section per Zer0pa convention, and operator action items for follow-on workstreams. Source: [`project_contract.json`](../project_contract.json) §deliv-final-report, [`README.md`](../README.md) §"Upcoming Workstreams".
