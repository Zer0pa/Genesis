# Genesis Comparative Experiment — Project

**Project ID:** `genesis_comparative`
**Lane:** Genesis (organism) — distinct from dm3_runner (see `LANE_DISTINCTION.md`)
**Repo destination:** `https://github.com/Zer0pa/Genesis` (operator pushes; agent does not push during execution)
**Source:** `https://github.com/Zer0pa/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025` (cloned at `/Users/Zer0pa/DM3/recovery/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025/`)
**Operator:** Zer0pa-Architect-Prime
**Engineering ethos (binding):** `RESISTANCE.md` (4 corruptions; new lane-specific addition `fp-shapematchRE`)
**Started:** 2026-04-27

---

## §1. Core research question

**What does Genesis do under the same task surface and the same governance that produced dm3_runner's signature observables?**

Genesis is a **distinct mathematical object** from dm3_runner: 285v vs 380v; D₆ vs C₃ symmetry; T(3,21) torus link on T² vs source-unrecovered; Q over Pythagorean rationals vs unknown. Substrate identity is **settled** in `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` and is not in scope here.

What is in scope: **rerun every characterization test that established dm3_runner's signature observables, but on Genesis,** and read the diffs. Two splits matter:

- **Cycle-7 attribution.** dm3 cycles at period ~7 (σ″ trimodal sawtooth peaks s33/s41/s49/s56). T(3,21)'s seven full twists in (σ₁σ₂)²¹ make Genesis a candidate to reproduce that period if cycle-7 is substrate-attributed.
- **s50-cliff attribution.** dm3 cliffs at exactly s50 = 0.000000 (geometry-independent across SriYantra and RandomAdj). Prediction: **Genesis does NOT cliff at s50** if cliff is augmentation-attributed.

Both predictions are pre-registered and falsifiable.

## §2. Objective

**Knowledge and scientific discovery** — what is Genesis, how does it work, how does it relate to the geometry. The PRD's deliverables are concrete (cross-compiled binary, deployed harness, receipts mirroring dm3 schema, final report), but the **goal is understanding Genesis as a dynamical system on its own substrate**, not just data collection.

## §3. Hard constraints

- **Use Rust.** Genesis source is open; leverage it for determinism tracking, speed, continuity. Do not reduce to shell-only scripting.
- **Use 6 cores on RM10** (cpu0–cpu5). cpu7 is dm3_runner's. cpu6 is thermal margin (may scale to cpu0–cpu6 = 7 if thermal under 75°C).
- **Do not collide with dm3_runner chain.** `pidof dm3_runner` discipline before any device probe. Phone is DM3-dedicated for the dm3 lane; Genesis lane runs in a separate `/data/local/tmp/genesis/` namespace.
- **Do not push to GitHub during execution.** Local commits only; operator pushes at chain close.
- **Do not modify Genesis source's graph data files** or override the sealed hashes silently.
- **Do not sync timing with dm3.** Genesis starts a few days behind; that's fine; both finish independently.
- **RESISTANCE.md is binding** for all subagents. Plus the new `fp-shapematchRE` pattern (spectral match ≠ identity) and the lane-specific corruption pattern: **`fp-counterfactual-prd-premise`** — the PRD said "you built a multithreaded Rust harness on top of `genesis_cli`"; verified-by-search this harness does NOT exist on disk; building from scratch is the actual scope, do not pretend otherwise.

## §4. Use Sonnet/Opus subagents only

No Haiku for this lane. All subagent spawns use Opus (default) or Sonnet for lighter tasks.

## §5. Deliverables (per PRD §Deliverables)

1. Cross-compiled `genesis_runner` on RM10, hash-verified against M1 canonical (with BENIGN-discrepancy disposition documented).
2. Deployed harness scripts on RM10 (`run_genesis_cell.sh`, master orchestrator, watcher, thermal coordinator). Resume-safe.
3. Receipts for every test in PRD §3, in dm3-mirror schema (`canonical_sha`, `receipt_sha`, `env_pre`, `env_post`, `task`, `--steps`, `best_uplift`, `timestamp_utc`, plus `genesis_meta` sub-object for build params like `turns`).
4. Final report at `/Users/Zer0pa/DM3/genesis_comparative/reports/GENESIS_FINAL_REPORT_<DATE>.md` mirroring dm3 final-report shape.
5. Genesis-side appendix: σ″-curve diff vs dm3, cycle-period verdict, cliff-presence verdict, symmetry-test verdict. Clean — no cross-lane editorial.

## §6. Out of scope (per PRD §Out of scope)

- Source recovery for dm3_runner (separate lane)
- Re-doing substrate identification (settled at `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`)
- Mac-only Genesis runs beyond cross-compile builds (RM10 is the comparative platform)
- Cartography of all 12 task analogs on Genesis (just the dm3-equivalent subset)
- Cross-stream coordination (independent from dm3 lane)
