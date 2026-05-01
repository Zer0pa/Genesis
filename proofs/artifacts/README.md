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

**v1.0 closure (2026-05-01):** 74 cells in this directory, all PASS, all `unique_canonical_sha_count = 1`. Phase 0 BITDET (4 cells), Phase 2 K2_SWEEP + CYCLE-probe (39 cells), Phase 2.5 PRECONV + BITDET_K2 (17 cells), Phase 3 prep BIG (11 cells), Phase 3 parity-sweep extension (3 cells: S20 / S40 / S50). Backend chain closed; phone released for other experiments. Aggregated curve: [`sigma_curve_full.tsv`](sigma_curve_full.tsv) (1 header + 74 cell rows). Headline figure: [`figures/sigma_curve.png`](figures/sigma_curve.png). Final synthesis: [`../../reports/GENESIS_FINAL_REPORT_2026-05-01.md`](../../reports/GENESIS_FINAL_REPORT_2026-05-01.md).
