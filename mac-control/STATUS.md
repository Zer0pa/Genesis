# mac-control — status

**Added to repo:** 2026-05-13 (durability sweep, post-v1.0 closure)
**Origin:** previously local-only at `~/genesis-control/` on the operator Mac. Moved into the canonical repo so that, after a Mac wipe, the full Mac-side operator control surface is recoverable from this directory alone.

## What this is

The five files in this directory are the Mac-side operator helpers for the Genesis chain — they ssh/adb into the RM10 phone where the actual chain runs. They were never on the chain path; they are the operator's control desk.

## Chain status as of this commit

The Genesis v1.0 chain is **CLOSED**. See `CHANGELOG.md [1.0.0]` and `reports/HANDOVER_2026-05-01.md` at the repo root. The `README.md` in this directory is a historical snapshot dated 2026-04-30 (mid-chain) and is preserved as-is for fidelity; the current state of the chain is NOT what that README describes.

## Re-use after a Mac wipe

```bash
git clone https://github.com/Zer0pa/Genesis.git ~/genesis-comparative-clone
cp -r ~/genesis-comparative-clone/mac-control ~/genesis-control
chmod +x ~/genesis-control/*.sh
```

The scripts then operate as documented in `README.md`. Phone serial `FY25013101C8` is hard-coded as default; override with `DEV=<serial>` env var.
