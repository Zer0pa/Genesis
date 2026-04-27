# Hash-Gate Disposition (Genesis Comparative)

**Status:** D1 documented per HANDOVER §6, operator default-approved.
**Effective:** 2026-04-28
**Binding for:** all Phase 0+ deployments and all receipt emissions.

---

## §1. The discrepancy

Genesis source (`crates/genesis_cli/src/main.rs:11-14`) hard-codes:

```rust
const CANONICAL_VERIFY_HASH: &str = "97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89";
const CANONICAL_SOLVE_HASH:  &str = "62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780";
```

When built on M1 from the canonical workspace at `/Users/Zer0pa/DM3/recovery/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025/00_GENESIS_ORGANISM/snic_workspace_a83f/`, the produced `verify.json` hashes to **`e8941414...`** — *not* `97bd7d…`. `solve_h2.json` hashes to **`62897b…`** exactly, matching the source-hardcoded canonical.

Read literally, the PRD §Deployment says: *"If your local build doesn't match the sealed hashes, do not deploy. Stop and find why."* This is the gate.

## §2. The diagnosis (BENIGN)

Per `substrate-reconstruction-2026-04-26/.gpd/STATE.md` retraction record (2026-04-27):

- The discrepancy is **serialization-layer**, not computation-layer. It traces to a trailing-newline difference in `refresh_receipts` rewrite that wraps the JSON payload of `verify.json`.
- The actual scientific computation result, `VERIFY_SUMMARY.json`, hashes to `8ddb…` and is **byte-identically reproducible across all M1 runs** of the canonical workspace.
- All 7 internal verification gates (the source's own `--validate` self-check structure) pass on the M1 build.
- `solve_h2.json = 62897b…` matches the source-hardcoded canonical exactly. This is the load-bearing scientific hash; it is preserved.

The 97bd…→e894… delta is therefore in the wrapping/whitespace layer of `verify.json`, not in any number, eigenvalue, vertex label, adjacency entry, or solver output. Substrate identity (T(3,21), D₆, Q-Pythagorean, 285v) is independently verified at `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/` and is not affected.

## §3. Decision (D1, operator default-approved per HANDOVER §6)

**Accept M1 canonical (`e8941414…` for `verify.json`, `62897b…` for `solve_h2.json`) with documented BENIGN diagnosis. Do NOT modify Genesis source to "fix" the hard-coded `97bd7d…` constant.**

Rationale:
- Modifying Genesis source's hard-coded hash to match M1 would silently bury the discrepancy and corrupt the source's own provenance trail. Per RESISTANCE.md, silent fixes are forbidden.
- The diagnosis is recorded; the discrepancy is not load-bearing for science; the substrate-reconstruction lane already adopted this stance and ran 5 phases on it without consequence.
- D1 is reversible: if a future investigation finds the trailing-newline diff is *not* the cause and the discrepancy is computational, this disposition document is updated, the BENIGN tag is retracted, and execution halts loudly per RESISTANCE.md re-engagement gate.

## §4. Receipt-emission requirement (binding)

Every Genesis receipt (Phase 0 BITDET, Phase 1+ K2, Phase 2 PRD test program) **must** include in its `genesis_meta` sub-object:

```json
"genesis_meta": {
  "build_target": "aarch64-linux-android",
  "build_target_api": 24,
  "binary_sha256": "<sha256 of /data/local/tmp/genesis/genesis_runner>",
  "source_canonical_verify_hash":  "97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89",
  "m1_actual_verify_hash":         "e8941414...",
  "diagnosis_verify_summary_hash": "8ddb...",
  "source_canonical_solve_hash":   "62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780",
  "m1_actual_solve_hash":          "62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780",
  "hash_gate_disposition_ref": "harness/host/HASH_GATE_DISPOSITION.md (BENIGN, accepted per D1)",
  "turns": 4,
  "source_workspace_seal": "a83f39e6a52d95662504a1872f8a7f7f889fd676055f802a73a4f75a3a102741"
}
```

Both the M1 actual hash and the source canonical hash are emitted; consumers can verify either.

## §5. What this disposition does NOT cover

- It does not cover the case where the *binary* (cross-compiled `genesis_runner`) on RM10 produces different scientific output than the M1 host build of `genesis_cli`. That's the **PARITY** test (Phase 2 cell `02-02 PARITY`). If PARITY fails (RM10 ↔ M1 canonical SHAs disagree), this is the cross-platform claim τ analog and a substantive scientific finding to surface, NOT a hash-gate concern.
- It does not cover any future modification of Genesis source. The BENIGN diagnosis is anchored to the canonical workspace seal `a83f39e6…`; if the workspace is rebuilt from a different seal, this disposition is invalidated and must be re-evaluated.
- It does not cover Phase 1's new `genesis_harness` crate. That code is new; its receipts have their own `genesis_meta.harness_sha` field; the canonical-hash gate applies only to the upstream `genesis_cli` portion of the binary.

## §6. References

- HANDOVER §6 (decisions D1-D6) — `/Users/Zer0pa/DM3/genesis_comparative/HANDOVER_2026-04-27.md`
- ADVISORY §3 D1 — `/Users/Zer0pa/DM3/genesis_comparative/ADVISORY_2026-04-27.md`
- substrate-reconstruction retraction record — `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/.gpd/STATE.md`
- substrate-reconstruction settled-identity bundle — `/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/SHARE_2026-04-27/`
- PRD §Deployment hash gate — `/Users/Zer0pa/DM3/genesis_comparative/PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md`
- Genesis source hash constants — `crates/genesis_cli/src/main.rs:11-14` in `snic_workspace_a83f`
