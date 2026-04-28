# Proof Artifacts

Receipt files from completed chain cells land here after each RM10 reconnect pull.

Each cell contributes:

```
<CELL_ID>/
  <INSTANCE>/
    stdout.log
    receipt.json
    canonical_stdout.sha256
    artifact_hashes.json
  outcome.json
  _summary.json
```

Receipt pull procedure: `adb pull /data/local/tmp/genesis/cells/ proofs/artifacts/` after confirming chain status via `adb shell cat /data/local/tmp/genesis/logs/master.log | tail -20`.

**Nothing in this directory should be edited after commit.** Retractions are additive: a retracted cell gets an `outcome.json` update referencing the retraction entry in `.gpd/STATE.md`; the original receipt files are preserved.

Phase 2 K2 sweep receipts are pending as of 2026-04-28 (RM10 offline).
