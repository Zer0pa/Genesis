# Genesis Comparative — Roadmap

**Total phases:** 4
**Created:** 2026-04-27
**Last updated:** 2026-04-28

## Overview

Run Genesis (open-source Rust organism, 285v, D₆ symmetry, T(3,21) torus link, settled substrate identity) through the same characterization tests that established `dm3_runner`'s (closed Android binary) signature observables, on RM10. Read the diffs against four pre-registered comparisons. Cross-lane comparisons are explicitly framed; substrate identity is settled (per `substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`) and not in scope.

## Phases

- [ ] **Phase 0: Foundation, cross-compile, deploy, first cell** — host-side build + phone-side chain skeleton; vanilla `genesis_cli --test-battery` BITDET cell autonomous on RM10.
- [ ] **Phase 1: K2 + Bhupura/Lotus port** — port dm3 K2 protocol (`exp_k2_scars`) to Genesis substrate; D₆-orbit-derived Bhupura/Lotus pattern analogs; per-step internal-state checksum + BigRational receipt option.
- [ ] **Phase 2: Full PRD test program autonomous execution** — chain executes BITDET, PARITY, SYMMETRY, K2_SWEEP, CYCLE, CROSSBUILD, DISCONT end-to-end on RM10.
- [ ] **Phase 3: Synthesis and final report** — final report mirroring dm3 shape; appendix with the four pre-registered comparison verdicts.

## Phase Details

### Phase 0: Foundation, cross-compile, deploy, first cell

**Goal:** RM10 has `genesis_runner` deployed at `/data/local/tmp/genesis/`, the chain master is running, the first cell (BITDET — bit-determinism replicate using vanilla `genesis_cli --test-battery N`) has launched. Operator can unplug phone, put it in fridge, fan on, Game Zone on, and the chain runs autonomously.

**Why this scope (not the full PRD test program):** the full PRD test program requires K2 + Bhupura/Lotus task ports onto Genesis substrate (D₆ orbit analogs of Sri Yantra geometric structures). That is genuinely from-scratch new Rust work (Phase 1) — `genesis_cli` exposes only `--protocol`, `--test-battery`, `--validate`, `--progeny`, `--audit-report`, `--lineage-batch`, none of which are dm3-task analogs. Phase 0 validates the chain infrastructure with what `genesis_cli` can already do (deterministic protocol runs); Phase 1 adds the task surface the rest of the PRD needs.

**Depends on:** Nothing (foundational).
**Requirements:** TC-01 (toolchain), HG-01 (hash-gate disposition), DEP-01 (deploy), BD-01 (BITDET cell)

**Success Criteria:**
1. `genesis_runner` SHA on phone matches host SHA.
2. Chain master pid alive; watcher pid alive.
3. BITDET cell emits receipts in dm3 schema; all 10 receipts byte-identical canonical_sha.
4. Operator notified phone is autonomous (fridge, fan, Game Zone, unplug).

**Routing on FAIL:** Document specific failure (linker / hash-gate / device-collision / determinism breach) with retraction discipline; do not silently proceed. Determinism breach in BITDET is a substantive scientific finding to surface to operator.

**Wall-clock estimate:** 3–6 hours from chain-launch readiness.

Plans:

- [ ] 00-01: GPD project skeleton + RESISTANCE/LANE_DISTINCTION inheritance + decision-log seed
- [ ] 00-02: Hash-gate disposition (M1 canonical e894… with BENIGN diagnosis vs PRD-stated 97bd…) — documented decision, not silent
- [ ] 00-03: Verify cross-compile toolchain end-to-end (Android NDK linker locate/install; cargo-ndk if needed)
- [ ] 00-04: Cross-compile `genesis_runner` (= release build of `genesis_cli`) for `aarch64-linux-android`
- [ ] 00-05: Phone-side harness (run_genesis_cell.sh, launch_genesis_batch.sh, thermal_coordinator.sh, genesis_chain_v1.sh, master_watcher.sh, resume_chain.sh) — adapted from dm3_parallel pattern, paths under `/data/local/tmp/genesis/`, cpu0–5 pin
- [ ] 00-06: Deploy to RM10 with `pidof dm3_runner` collision check; verify-on-device hash gate
- [ ] 00-07: First chain cell BITDET (`genesis_cli --test-battery 10` taskset-pinned, receipts in dm3 schema) — chain validation
- [ ] 00-08: Confirm autonomous chain start, watcher operating, advise operator to unplug

### Phase 1: K2 + Bhupura/Lotus port

**Goal:** `genesis_runner` (or a sibling `genesis_harness` crate) implements the dm3 K2 protocol: two lesson levels (0, 3) × two patterns (Bhupura, Lotus) × two noise levels (0.1, 0.2), eta=0.2; emits `best_uplift` and `max_scar_weight` on `--task exp_k2_scars --steps N`. Bhupura/Lotus patterns derived from D₆ orbit structure (47 size-6 orbits + 1 size-3 waist orbit per substrate-reconstruction findings) — pick analogs that respect Z₂ × S₃ symmetry.

**Depends on:** Phase 0 (host-side toolchain + chain skeleton must be in place).
**Requirements:** K2-01..04 (port), BL-01 (Bhupura/Lotus derivation), DET-01 (per-step state checksum), BR-01 (BigRational option), REGR-01 (receipt-schema regression test)

**Success Criteria:**
1. `./genesis_runner --task exp_k2_scars --steps 30` emits a receipt with `best_uplift`, `max_scar_weight`, `canonical_sha`, `receipt_sha`, `env_pre`, `env_post`, `genesis_meta`.
2. Bit-determinism over N=10 invocations at `--steps 30`.
3. Schema matches dm3 sample receipt at `dm3_parallel/binaries/sample_full_run_s30.log`.
4. Bhupura/Lotus derivation documented with pre-registered cell in PLAN.md.

**Routing on FAIL:** If K2 cannot be unambiguously read from dm3 sample log + sources, document gap; consider alternative analogs from D₆ orbit structure with operator-visible decision.

**Wall-clock estimate:** 1–2 days (host-side Rust development).

Plans:

- [ ] 01-01: K2 protocol specification (read dm3 sample log + extract algorithm from receipts)
- [ ] 01-02: Bhupura/Lotus pattern derivation in D₆ (use 47 size-6 orbits as Bhupura analog; 1 size-3 waist as Lotus or vice versa; record the choice + justification)
- [ ] 01-03: Implement `--task exp_k2_scars` in `genesis_harness` crate; emit dm3-schema receipts; canonical-output SHA of best_uplift + max_scar_weight
- [ ] 01-04: Per-step receipt emission with internal-state checksum at each --steps boundary (this is the determinism enhancement Rust enables that dm3_runner's closed binary doesn't expose)
- [ ] 01-05: Higher-precision option (`--receipt-format=json-bigrat`) emits BigRational form bypassing the printf-6-decimal floor — solves OAI-2 (precision floor) on Genesis side natively
- [ ] 01-06: Cross-compile new genesis_runner with K2 surface; redeploy
- [ ] 01-07: Receipt schema regression test (against dm3 sample receipt format)

### Phase 2: Full PRD test program autonomous execution

**Goal:** chain executes the full PRD §3 test program end-to-end on RM10. Receipts pull to host. Verdicts emitted per cell.

**Depends on:** Phase 1 (K2 task surface needed for K2_SWEEP, CYCLE, CROSSBUILD, DISCONT).
**Requirements:** TP-BITDET, TP-PARITY, TP-SYM, TP-K2SW, TP-CYC, TP-CB, TP-DISC

**Success Criteria:**
1. All cells emit verdicts (PASS / KILL / PARTIAL / SKIP).
2. Receipts pulled to `/Users/Zer0pa/DM3/genesis_comparative/artifacts/genesis_<TS>/cells/<CELL>/`.
3. Cycle-7 verdict and s50-cliff verdict explicitly recorded.
4. σ″-curve over `--steps` ∈ {20, 28..56} computed and tabulated.

**Routing on FAIL:** Per-cell KILL with engineering reason; chain continues with downstream cells unless KILL is structural.

**Wall-clock estimate:** 1–2 days (autonomous on RM10; operator monitors at end-of-chain).

Plans:

- [ ] 02-01: BITDET (re-run with K2 task in addition to `--test-battery`)
- [ ] 02-02: PARITY (cross-platform M1 ↔ RM10 with K2 task)
- [ ] 02-03: SYMMETRY (D₆ Z₂-mirror probe; observable sensitive to mirror-asymmetric mode)
- [ ] 02-04: K2_SWEEP (`--steps` ∈ {20, 28..56} × N=3 = 90 invocations; 6-core fan-out; expect ~hours wall-clock)
- [ ] 02-05: CYCLE (multiples of 7, 6, 8 disambiguation; N=3 each)
- [ ] 02-06: CROSSBUILD (vary `turns` knob; K2 sweep on at least 1 variant)
- [ ] 02-07: DISCONT (only if K2_SWEEP shows a cliff or sharp drop; else record "no cliff observed")

### Phase 3: Synthesis and final report

**Goal:** Final report at `reports/GENESIS_FINAL_REPORT_<DATE>.md` mirroring dm3 final-report shape. Plus genesis-side appendix with the four pre-registered comparison verdicts.

**Depends on:** Phase 2 (all receipts in hand).
**Requirements:** SYN-01..08

**Success Criteria:**
1. Final report rendered, complete, self-contained.
2. All 4 pre-registered comparisons answered (cycle-7, s50, σ″-shape, symmetry).
3. All NULL outcomes have RESISTANCE.md exhaustion documentation.
4. All positive outcomes have Monte Carlo baselines + tier-of-evidence labels (per `fp-shapematchRE`).
5. Operator can push to `Zer0pa/Genesis` from this state.

**Wall-clock estimate:** half-day to 1 day (host-side synthesis).

Plans:

- [ ] 03-01: Per-cell evidence collation
- [ ] 03-02: σ″-curve diff vs dm3 (numerical comparison + visualization)
- [ ] 03-03: Cycle-period verdict (substrate-attribution vs augmentation-attribution)
- [ ] 03-04: s50-cliff verdict (substrate-attribution vs augmentation-attribution)
- [ ] 03-05: Symmetry-test verdict (D₆ vs C₃ structural reading)
- [ ] 03-06: IS-NOT findings (engineering + scientific) per dm3 final-report convention
- [ ] 03-07: Cumulative receipts SHA index for HF push (`Zer0pa/DM3-artifacts` dataset, `genesis/` subdir)
- [ ] 03-08: Final report draft + RESISTANCE.md compliance audit + sign-off

## Phase ordering rationale

Phase 0 deliberately scopes to "chain running with vanilla genesis_cli" so the operator can unplug. Phase 1's K2 port is genuine new Rust work that takes a day or two on host. Phase 2's chain is autonomous on RM10. Phase 3 is host-side synthesis.

This decoupling lets the phone run autonomously while host-side work continues. Resume-safe chain means Phase 1's binary refresh on phone doesn't restart Phase 2's work — it appends.

If at any phase a result invalidates the substrate identity finding (T(3,21), D₆, Q over Pythagorean rationals), document as RESISTANCE-disciplined retraction. The substrate identity is settled but not infallible.
