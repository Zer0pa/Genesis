# Contributing

This is an internal research repository. External contributions are not open at this stage. The conventions below govern all Zer0pa-internal contributors and agents operating on this workstream.

---

## Ethos

Contributions follow the RESISTANCE.md discipline (`genesis_comparative/RESISTANCE.md`): no rush-to-green-flag, no NULL-as-out, no efficiency-as-corner-cutting, no flattery-as-freedom. Work earns its verdict. Receipts are the evidence; summaries are not a substitute for the underlying computed artifact.

---

## Commit discipline

- **Atomic commits.** One logical change per commit. Retractions and their corrections are separate commits — never squashed.
- **Named branches.** Branch off `main`. Use `<phase>-<short-descriptor>` naming (e.g. `phase1-k2-scars-port`, `phase2-sweep-receipts`). No anonymous work on `main` directly.
- **No self-merge.** Open a PR; at least one other named principal must approve before merging to `main`. During solo operator phases, operator merges only after explicitly reviewing the diff.
- **Drift-deletion mandate.** Stale planning files, stub receipts, and superseded manifests are deleted in the commit that supersedes them. Dead files must not accumulate.
- **No push during execution.** Per `PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md` §Boundaries: local commits stay local until operator chain-close. Push only when operator explicitly authorises.

---

## Extending the cell manifest

The chain manifest (`harness/phone/cells.txt` or equivalent) lists cell IDs with their task parameters. To add a new cell:

1. Choose a cell ID following the existing scheme (e.g. `K2_SWEEP_S28`, `BITDET_500K`).
2. Add a line in `cells.txt`: `<CELL_ID> [--task <subcommand>] [--steps N] [--instances M]`.
3. Pre-register the acceptance criterion in `.gpd/STATE.md` decisions section before the cell runs: state what `unique_canonical_sha_count` and any KPI bounds constitute a PASS.
4. Commit the manifest update and pre-registration in the same commit, before launching the cell.

---

## Adding a new task subcommand to `io_cli`

The `io_cli` crate lives at `crates/io_cli/` inside the genesis source workspace. To add a subcommand (e.g. a new associative-memory task):

1. Create `crates/io_cli/src/<subcommand_name>.rs`. All numeric work must use `num_rational::BigRational` (or equivalent exact type). No `f32`/`f64` in any math path — floats only for terminal printf output.
2. Register the enum variant and dispatch in `crates/io_cli/src/main.rs`.
3. Add workspace dependencies to `Cargo.toml` if needed; use workspace-level dep declarations (no per-crate version pins that diverge from workspace).
4. Build clean on M1 host with `#![deny(warnings)]` in scope.
5. Cross-compile with the NDK recipe in `REPRODUCIBILITY.md`; verify host SHA matches expectations before deploying to RM10.
6. Add the new subcommand to `REPRODUCIBILITY.md` smoke-test table and to `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` binary-SHAs section.
7. Pre-register BITDET acceptance criterion in STATE.md before running the first cell.

---

## Adding a new substrate variant

The canonical substrate is `inputs/substrate_285v.json` (285 vertices, 567 edges, 48 D₆ orbits, T(3,21) torus link). To introduce an alternative substrate:

1. Name the file `inputs/substrate_<Nv>v_<descriptor>.json` (e.g. `substrate_380v_dm3.json`).
2. Document the graph identity in `proofs/manifests/CURRENT_AUTHORITY_PACKET.md` under a new subsection — vertex count, edge count, symmetry group, topological identity, and which lane it belongs to.
3. Explicitly frame any cross-substrate comparison per `LANE_DISTINCTION.md`: state the lane of each substrate before drawing any conclusion. Cross-lane comparisons are only valid when explicitly labelled.
4. Sealed canonical hashes (`verify.json`, `solve_h2.json`) for the new substrate must be pre-registered before any chain run. Running the chain first and retrospectively choosing which hash to call "canonical" is forbidden.

---

## Filing a falsification claim against a recorded result

A falsification claim challenges a PASS receipt, a BITDET verdict, or a KPI value recorded in `cells/` or `proofs/`.

1. Open a GitHub issue with title `[FALSIFICATION] <CELL_ID> — <brief description>`.
2. Provide: the cell ID, the artifact path, the claimed deviation, and a minimal reproduction command.
3. The operator will attempt to reproduce the deviation using the exact binary SHA and config recorded in the cell's `receipt.json`.
4. If reproduction confirms the deviation: the cell outcome is retracted in `.gpd/STATE.md` with a timestamped retraction entry; the `outcome.json` is updated to FAIL; a correction commit is made referencing the issue.
5. If reproduction does not confirm: the issue is closed with the reproduction log attached.
6. Under no circumstances is a receipt modified to remove evidence of a failure. Retractions are additive, not destructive.
