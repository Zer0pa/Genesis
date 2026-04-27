# Lane Distinction — DM3 Workstreams

**Effective:** 2026-04-26 (operator pivot directive)
**Binding:** all subsequent agents on this brief

This document captures a substantive distinction the operator has now made explicit. It supersedes any text in `BRIEF.md` that conflated the two lanes (the brief's Layer 3 anchors are device-side measurements, not genesis-substrate predictions — see "Resolution" below).

---

## The two DM3 lanes

| Property | **Geometry-direct (THIS lane)** | **dm3_runner / Phase A (parked)** |
|---|---|---|
| Substrate | 285-vertex graph from genesis_cli | 380-vertex graph measured in Phase A |
| Source repo | `Zer0pa/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025` (private, accessible) | unknown / unrecovered |
| Source status | source-available; pure-geometry crates; deterministic build with sealed hashes | hybrid binary; runtime-only; classified `exploratory_compiled_residue` |
| Build target | aarch64-apple-darwin native (and aarch64-Linux for parity); source-rebuilt on Mac | aarch64-linux-android ELF; runs only on RM10 or under Android emulation |
| Verification anchors | canonical hashes `verify.json` = `97bd...`, `solve_h2.json` = `62897b...` (from VALIDATION.md inside genesis workspace) | Phase A spectral fixtures (λ_max ≈ 7.999, Fiedler ≈ 0.001093, 380 verts, etc.) |
| Symmetry signature | Z₂ mirror (95 singly + 95 doubly degenerate over 190 distinct levels) | C₃ ternary (95 of 127 distinct levels at 3-fold) |
| Active claims | substrate identification on the genesis substrate; cross-platform M1↔Intel parity; Phase 4 algebraic content readable directly from source | dynamics determinism (claim τ from prior workstream's AGD-H1 confirmed 5/5 bit-exact) |
| Status | **active — "continue"** | **flag-and-park** — out of scope for this workstream |

The geometry lane is what this brief is about. The dm3_runner lane is the prior workstream's territory; its source remains unfound and is a separate source-recovery effort.

---

## Why this matters for the brief's anchors

`BRIEF.md` Section 1 (Layer 3) lists Phase A spectral fixtures and uses them to drive Phase 1 verification. Read literally, that section assumes the genesis source is what produced the dm3_runner binary's graph. **It does not.** The genesis substrate produces a 285-vertex graph; dm3_runner produces a 380-vertex graph. They are different objects with different symmetry structures (Z₂ vs C₃) and different vertex counts.

This is captured honestly in the brief's own Section 5 ("Honest gaps"):

> "I have not seen the construction source. Where I describe what the construction 'must' encode, I'm reasoning from the geometric description plus the lexicon document plus the Phase A spectral data. The agent should treat my reasoning as predictions to be checked against the source, not as established facts."

The operator's pivot directive of 2026-04-26 confirms this: the predictions are not facts; the genesis substrate is its own object; the brief's Phase A "verification" was a check against the wrong target.

### Resolution

- Phase A spectral fixtures are **descriptive of dm3_runner**, not **prescriptive for genesis**.
- For the geometry lane, Phase 1's verification gate is replaced by:
  - **Genesis canonical hashes match** (`verify.json` = `97bd...`, `solve_h2.json` = `62897b...`)
  - **Genesis substrate fully characterized** as the graph it actually is (285 verts, Z₂ mirror, full spectrum, etc.)
  - **Cross-platform parity** between M1 and Intel builds of genesis_cli (the new claim-τ for this lane)
- For the dm3_runner lane, Phase A spectra remain the canonical anchors when source is recovered (separate workstream).

---

## What this means for the agent's prior work

The Phase 0/1 executor (commit `9bcb92ae` work) produced real artifacts that are PRESERVED under the new frame:

- ✓ Built `genesis_cli` (debug, Mach-O arm64) — preserved
- ✓ Ran `--protocol --runs 1` successfully; `solve_h2.json` hash matched canonical `62897b...` exactly — preserved
- ⚠ `verify.json` hash discrepancy (`e894...` observed vs `97bd...` documented) — diagnosed by agent as "canonicalization-fix documentation artifact, not a computation failure" — needs second look but not invalidating
- ✓ 285-vertex adjacency extracted to `phase_1_adjacency.npz` — PRESERVED, this is the genesis substrate
- ✓ Spectrum: 190 distinct levels, λ_max = 3.9989, Fiedler = 0.001071, Z₂ mirror (95 singly + 95 doubly) — PRESERVED, this is the substrate's spectral fingerprint

What is RETRACTED:

- ✗ "1 PASS / 7 MISMATCH" verification table interpreted as "Phase A reconstruction failed" — RETRACT. The table measured the genesis substrate against dm3_runner anchors. Wrong comparison. The table is RENAMED to `phase_1_genesis_substrate_characterization.tsv`; the columns are repurposed to "metric / computed value / dm3_runner Phase A reference (informational)".
- ✗ "NULL OUTCOME (BRIEF Section 6)" claim — RETRACT. NULL applies when reconstruction fails to reproduce the binary's graph; here we are not trying to reproduce dm3_runner's binary. The genesis substrate is its own object. There is no NULL; there is a substantive characterization in progress.

---

## Receipts location

Per operator directive, all geometry-lane receipts go into:

```
artifacts/phase_S8_geometry_lane_M1_<TS>/
```

with TS = ISO-8601 UTC timestamp at lane-creation. First lane dir for this work: `phase_S8_geometry_lane_M1_20260426T212413Z/`.

These are the canonical-output structure; the loose `artifacts/phase_0_*` and `artifacts/phase_1_*` files from the agent's run will be migrated into this tree.

Mirror to Hugging Face dataset `Zer0pa/DM3-artifacts` (or operator-specified dataset) on each substantive completion, following the prior workstream's AGD-H1 pattern.
