# Genesis control surface (Mac side, lightweight)

**Date:** 2026-04-30
**Purpose:** Mac is now a lightweight control surface for the Genesis comparative experiment. Primary storage lives on the **RedMagic 10 Pro (`FY25013101C8`)** at `/sdcard/Genesis-Archive/` and `/data/local/tmp/genesis/`. Source authority lives on **GitHub at `Zer0pa/Genesis`**.

---

## Where things actually are

| Surface | Location | Size | Notes |
|---|---|---|---|
| Source code (authority) | https://github.com/Zer0pa/Genesis | — | Branches: `main`, `phase-3-prep-receipts-2026-04-29` |
| Chain workspace (active) | RM10 phone `/data/local/tmp/genesis/` | ~135 MB | `harness/`, `cells/`, `inputs/`, `logs/`, `snic_rust` binary |
| Receipt + lineage archive | RM10 phone `/sdcard/Genesis-Archive/` | ~5 GB | Sealed lineage (Z_P1_*), zer0pa_poc, genesis_comparative repo backup, 00_GENESIS_ORGANISM source |
| Genesis source repo (upstream) | https://github.com/Zer0pa/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025 | — | Re-clone when needed |
| Substrate identity authority | https://github.com/Zer0pa/Zer0pa/DM3/substrate-reconstruction-2026-04-26 (or local sibling) | — | Settled; not in scope here |

**Mac keeps**: only this `~/genesis-control/` directory (a few KB of scripts + this README).

**Mac does NOT keep**: source workspace, build artifacts, lineage archive, repo clones. All re-fetchable from GitHub or pullable from phone.

---

## Quick commands

### Verify chain is running
```bash
adb -s FY25013101C8 shell "kill -0 \$(cat /data/local/tmp/genesis/logs/master.pid 2>/dev/null) 2>&1 && echo MASTER_ALIVE || echo MASTER_DEAD"
adb -s FY25013101C8 shell "tail -5 /data/local/tmp/genesis/logs/chain.log"
```

### Quick health
```bash
~/genesis-control/health.sh
```

### Pull latest cell receipts from phone (to a temp dir)
```bash
~/genesis-control/pull-receipts.sh ~/genesis-receipts-pull/
```

### Re-clone repo when you need to do work
```bash
git clone git@github.com:Zer0pa/Genesis.git ~/genesis-comparative-clone
cd ~/genesis-comparative-clone
git checkout phase-3-prep-receipts-2026-04-29
# do work, push, then delete the clone
```

### Re-clone Genesis source workspace (for cross-compile)
```bash
git clone https://github.com/Zer0pa/Zer0paMk1-Genesis-Organism-Executable-Application-27-Oct-2025.git ~/genesis-source-clone
cd ~/genesis-source-clone/00_GENESIS_ORGANISM/snic_workspace_a83f
# cross-compile per REPRODUCIBILITY.md
```

### Restore lineage archive from phone (if needed for re-running --lineage-batch or audit)
```bash
adb -s FY25013101C8 pull /sdcard/Genesis-Archive/01_PROVEN_LINEAGE/ ~/01_PROVEN_LINEAGE/
# work, then re-archive + push back to phone, delete on Mac
```

### Restore genesis_comparative repo backup
```bash
adb -s FY25013101C8 pull /sdcard/Genesis-Archive/genesis_comparative.tar.gz /tmp/
mkdir -p ~/genesis-comparative-restore && cd ~/genesis-comparative-restore
tar xzf /tmp/genesis_comparative.tar.gz
```

---

## Active chain status (snapshot 2026-04-30)

- Master pid `23751` alive (Phase 3 prep parity-sweep extension)
- Cells in flight: `BITDET_K2_S40_PARITY` (current), `BITDET_K2_S50_PARITY` (queued)
- 72 cells already PASS in repo (pulled to host, committed, pushed via PR)
- ETA ~30-60 min for chain finish (fridge)

---

## Key SHAs to remember

- Genesis source workspace seal: `a83f39e6a52d95662504a1872f8a7f7f889fd676055f802a73a4f75a3a102741`
- Phase 1 snic_rust (5 subcommands incl. k2-scars): `e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1`
- Source-canonical `verify.json`: `97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89`
- Source-canonical `solve_h2.json`: `62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780`
- M1↔RM10 K2-task parity SHA at S30: `0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372`
- LICENSE (SAL v7.0 byte-identical to ZPE-Image): `40e6857a60550d87bd4fd9e0630f0696aa56f8ae5a94c2de08cfd5319e0b02aa`

(After the recent license change to `Zer0pa Genesis-DM3 Research and Receipt License v1.0` per commit `f0d89b1`, the LICENSE SHA on Github will differ. Check with `git show HEAD:LICENSE | shasum -a 256`.)

---

## What's NOT in scope here

- The geometry pack at `/Users/Zer0pa/DM3/DM3 v Genesis Geometry/Genesis Geometry/` (3.2 MB) — separate deliverable for the science + engineering team, kept on Mac for now.
- The substrate-reconstruction lane (`/Users/Zer0pa/DM3/substrate-reconstruction-2026-04-26/`) — separate workstream; not moved.
- dm3 lane (`/Users/Zer0pa/DM3/dm3_parallel/`, etc.) — sibling lane.

---

## Phone storage convention

```
/data/local/tmp/genesis/        ← active chain workspace (DO NOT TOUCH while chain runs)
  harness/           ← chain scripts (cells.txt, run_genesis_cell.sh, etc.)
  cells/             ← live + completed cell directories
  logs/              ← chain.log, thermal.log, watcher.log
  inputs/            ← substrate fixture + configs
  snic_rust          ← deployed binary

/sdcard/Genesis-Archive/        ← passive archive (re-pull when needed)
  01_PROVEN_LINEAGE/            ← sealed snic workspace progeny
  zer0pa_poc/                   ← prior PoC code
  genesis_comparative.tar.gz    ← repo backup (Github is also authority)
  00_GENESIS_ORGANISM_lite/     ← source workspace minus target/
```

`/sdcard/` is user-visible, survives reboots, browsable via Files app. `/data/local/tmp/` is the adb shell sandbox, also survives reboots, but more constrained.
