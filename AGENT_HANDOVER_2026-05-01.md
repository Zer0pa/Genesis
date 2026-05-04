# Agent handover — Genesis-DM3 orchestrator (post-v1.0-closure)

**Date:** 2026-05-01
**Outgoing role:** chain-operator → Genesis-DM3 orchestrator at v1.0 closure
**Incoming role:** Genesis-DM3 orchestrator in the post-closure window (coordinate + support)
**Branch at handover:** `phase-3-prep-receipts-2026-04-29` @ `13dcf2e`
**Audience:** the next agent who picks up this lane.

This is the agent-continuity handover (paste-the-whole-thing-into-the-next-thread style). The operational coordination note for the repo manager + science team is the sibling [`reports/HANDOVER_2026-05-01.md`](reports/HANDOVER_2026-05-01.md). The science synthesis is [`reports/GENESIS_FINAL_REPORT_2026-05-01.md`](reports/GENESIS_FINAL_REPORT_2026-05-01.md). This file is for the agent itself.

---

```
═══════════════════════════════════════════════════════════════════════════
GENESIS-DM3 ORCHESTRATOR — AGENT HANDOVER (2026-05-01, mode: post-v1.0-closure)
═══════════════════════════════════════════════════════════════════════════
You are taking over the Genesis-DM3 orchestrator role. The previous agent
closed v1.0 and pushed; chain is done; you are inheriting a quiet,
coordinate-and-support phase. Read this prompt top-to-bottom before any
tool call.
───────────────────────────────────────────────────────────────────────────
§0. The 60-second orientation
───────────────────────────────────────────────────────────────────────────
Genesis is a Zer0pa research artifact: pure-rational deterministic
computation on a 285v / D₆ / T(3,21) substrate, with a comparative
falsification experiment against the closed dm3_runner binary.

**As of 2026-05-01 the v1.0 backend chain is CLOSED.** 74 cells / 74 PASS
/ 0 divergent in repo. Three of four pre-registered comparisons settled
empirically; the fourth landed as analytic disposition (Z₂-projection
deferred to v2.0). Phone has been released for OTHER experiments — not
ours. dm3_runner sibling (pid 15749 last we looked) is alive on cpu7
running its own thing; do not touch it.

The previous agent committed `13dcf2e` ("v1.0 closure: parity sweep
complete, final report, 10-doc reviewer pack") to branch
`phase-3-prep-receipts-2026-04-29` and pushed. A coordination note for
the repo manager agent was prepared and shown to the operator. Repo
manager has not yet been spawned / has not yet picked it up (as of
handover writing). Operator may have already done so by the time you
read this; ALWAYS check `gh repo view Zer0pa/Genesis` first.

Your role: SUPPORT + COORDINATE in the post-closure window. Don't run
chain. Don't push new science cells. Don't propose v2.0 work without
operator directive. Wait for the next operator move (likely options:
reviewer-feedback handling, v2.0 planning, cross-DM3 orchestration,
or another support task).
───────────────────────────────────────────────────────────────────────────
§1. BINDING ETHOS — read first, in order
───────────────────────────────────────────────────────────────────────────
The repo lives at GitHub `Zer0pa/Genesis` (INTERNAL until orch flips it).
Re-clone with: `gh repo clone Zer0pa/Genesis /tmp/g -- --branch phase-3-prep-receipts-2026-04-29`

Read these in order, then `rm -rf /tmp/g`:
  1. /tmp/g/RESISTANCE.md
       4 corruptions binding for every action:
         fp-rushtoend, fp-NULLasout, fp-flatteryasfreedom,
         fp-counterfactual-prd-premise (lane-specific), fp-shapematchRE
       Re-engagement gate (5 steps) when corruption observed: stop,
       acknowledge specifically, file retraction in .gpd/STATE.md, re-read
       brief, confirm understanding before resuming.
  2. /tmp/g/LANE_DISTINCTION.md
       Genesis (this lane, 285v / D₆ / T(3,21)) ≠ dm3_runner sibling
       (380v / C₃ / source-unrecovered). Cross-lane comparisons must
       always be explicitly framed as cross-lane.
  3. /Users/Zer0pa/ZPE/Zer0pa PRD & Research/PRD and Ethos/Zer0pa Live
     Project Ethos.md/Zer0pa Live Project Ethos.md.md
       (note doubled filename is real on disk)
       Portfolio-not-platform; always-in-beta; honest-blocker discipline;
       numbers carry the narrative.
  4. /tmp/g/AUDITOR_PLAYBOOK.md
       The 30-min outsider audit + folded-in FAQ. Reviewers will run
       this. You should be able to answer any FAQ Q from memory.
  5. /tmp/g/reports/GENESIS_FINAL_REPORT_2026-05-01.md
       v1.0 final synthesis. THE LOAD-BEARING NEW DOC. The Z₂ analytic
       disposition (§4 Comparison #4, especially §4.2 proof sketch and
       §4.6 disposition table) is the most likely science-team scrutiny
       target. Be ready to defend or refine it.
  6. /tmp/g/reports/HANDOVER_2026-05-01.md
       The previous agent's coordination note for repo orchestrator +
       science team. Lists what landed, what's NOT in the commit (left
       to other owners), sanity-check commands.
  7. /tmp/g/README.md  + the rest of the 10-doc pack:
       docs/SUBSTRATE.md, docs/K2_PROTOCOL.md, docs/DETERMINISM.md,
       docs/ARCHITECTURE.md (architecture + Operations Manual),
       REPRODUCIBILITY.md
  8. /tmp/g/CHANGELOG.md  — top entry [1.0.0] — 2026-05-01 summarises
       the closure
  9. /tmp/g/HANDOVER_2026-04-27.md  + ADVISORY_2026-04-27.md  — historical
       decision records D1–D6; load-bearing for harness/host/
       HASH_GATE_DISPOSITION.md
  10. /tmp/g/PRD_GENESIS_COMPARATIVE_v1_DRAFT_20260427.md  — operator's
       source-of-truth pre-registration. v1.0 has now shipped against
       this PRD.
───────────────────────────────────────────────────────────────────────────
§2. WHERE THINGS ARE NOW
───────────────────────────────────────────────────────────────────────────
  Surface                          Location                                Notes
  ────────────────────────────────────────────────────────────────────────────────
  Source authority                 GitHub Zer0pa/Genesis                   Branch: phase-3-prep-receipts-2026-04-29 HEAD = 13dcf2e
                                                                           main NOT YET updated (repo orchestrator's job)
                                                                           Tag v1.0.0 NOT YET applied (repo orchestrator's job)
  Receipt + lineage archive        RM10 phone /sdcard/Genesis-Archive/     2.6 GB, 5 tarballs; do not touch (other experiments running on phone)
  Active chain workspace on phone  /data/local/tmp/genesis/                exists but quiescent; chain master DEAD; phone released for other experiments
  Mac control surface              ~/genesis-control/                      health.sh / pull-receipts.sh / clone-and-checkout.sh / restore-archive.sh
                                                                           clone-and-checkout.sh uses git@github.com:; SSH key not set up
                                                                           — use `gh repo clone Zer0pa/Genesis /tmp/g -- --branch <branch>` instead
  Mac state                        ~31 GB free                              no persistent clones; re-clone when needed
  DM3 sibling lane (parked)        github.com/Zer0pa/DM3                   equation-recovery COMPLETE 2026-04-26 (all 5 phases NULL/EXHAUSTED)
                                                                           dm3_runner pid was alive on phone cpu7 (sibling lane); leave alone
───────────────────────────────────────────────────────────────────────────
§3. KEY SHAs (memorise — they recur)
───────────────────────────────────────────────────────────────────────────
  Source canonical verify.json   97bd7d121e03e7c35505bd889f85630d6f8d78abbdc6fad1c5654d6743b9ba89
  Source canonical solve_h2.json 62897b8c26de3af1a78433807c5607fb8c82f061d1457e9c43e2aa5d35fe7780
  K2-task M1↔RM10 parity at S30  0b5442f9825427c5f457b79ef23afd606d3b219c773d3d8877aca633ca92a372
  RM10 K2 anchor at S20          74fa0b8a7082b76370db8cf05f0baf520534e5def11edfccd698f26ad914e432
  RM10 K2 anchor at S40          38be38e28653af6b2d1bac6bc5caf3d9f05a01a0f4d03dc149f7a68d498ea42b
  RM10 K2 anchor at S50          f5cd3876868ec1b2a40a6dcd6b6e40914813f6992f2f067e9cd65beb5ce81960
  RM10 K2 anchor at S56_BIG      fccbdf3d776c1a77dd5e50486e9ddfb427bf11840b082cebbfa9115aa300e60d
  Genesis source workspace seal  a83f39e6a52d95662504a1872f8a7f7f889fd676055f802a73a4f75a3a102741
  snic_rust binary host SHA      e21208a69064a11677cb700e3b68c0fba3aab1e08ed784f71d8e954a523e5ff1
  v1.0 closure commit            13dcf2e (on phase-3-prep-receipts-2026-04-29; not yet on main)
  RM10 device serial             FY25013101C8 (do NOT initiate any genesis/ work on phone — other experiments)
───────────────────────────────────────────────────────────────────────────
§4. v1.0 SCIENTIFIC STATE (what's settled, what's deferred)
───────────────────────────────────────────────────────────────────────────
  Pre-registered comparisons (in project_contract.json):
    claim-cycle7-attribution     AUGMENTATION-ATTRIBUTED  (settled by receipts)
    claim-s50cliff-augmentation  CONFIRMED                (settled by receipts)
    claim-sigma-curve-diff       CONFIRMED                (settled by receipts)
    claim-parity-K2-task         CONFIRMED at S30         (RM10 anchors at S20/S40/S50 in repo for host-only widen-coverage)
    claim-symmetry-D6vsC3        STRUCTURAL INCLUSION CONFIRMED + NUMERICAL Z₂-PROJECTION DEFERRED to v2.0
                                 — D3 pattern is exactly Z₂-invariant by construction (proof in
                                   GENESIS_FINAL_REPORT §4.2); numerical observable requires a
                                   Z₂-asymmetric pattern (new chain run); out of scope under v1.0
  σ″-curve shape (Genesis):
    Transient S1..S9 BIG: 5.5, 6.5, 4.0, 3.5, 4.0, 4.0, 3.0, 3.5, 3.5
      (verified at 600× cross-replicate per step)
    Steady state S10+: flat at 3.000000 byte-deterministically
    Cross-platform M1↔RM10 byte-equal at S30 (BITDET_K2_S30_BIG)
    No s50 cliff on Genesis (vs dm3 exact-zero cliff at S50)
  Cross-lane (vs dm3_runner @ steady state S20-S56):
    dm3 trimodal sawtooth 1.16-1.97 with cliff at S50 = 0.000000
    Genesis flat at 3.000000 with NO cliff. Structurally differs.
  Determinism scorecard (zero divergences across):
    31,560 Phase 0 verify.json hashes (4 BITDET cells)
    + 56 Phase 2/2.5 K2-task cells (per-cell unique=1)
    + 6,900 Phase 3 prep BIG K2 invocations (11 cells)
    + 900 Phase 3 parity-sweep K2 invocations (3 cells)
    + signal-interrupted determinism preserved at S56_BIG
───────────────────────────────────────────────────────────────────────────
§5. OPERATOR PREFERENCES (binding)
───────────────────────────────────────────────────────────────────────────
  - autonomy = yolo (long-horizon uninterrupted execution)
  - review_cadence = sparse (minimize interim status pings; one-line
    check-ins; don't list everything you read)
  - Sonnet / Opus subagents only — NO Haiku
  - Both negative AND positive findings equally valued; honest pending = OK
  - No flattery framing ("you're evolving", etc.) — engage substantive
    directives only; resist fp-flatteryasfreedom
  - No premature SETTLED verdicts; no fabricated metrics
  - No PII paths in commits — operator's user-home path stays out of any
    committed file; refer to scripts as `~/genesis-control/` not the
    absolute path; use `/Users/Zer0pa/...` or `/Users/zer0pa-build/...`
    for cross-repo paths
  - Local commits during execution; push only with explicit operator nod
    (the v1.0 closure push happened under the "ensure repo is updated"
    explicit nod from the operator's directive)
  - Author email: architects@zer0pa.ai
  - Repo orchestrator agent owns push/PR/merge — coordinate by note,
    don't bypass. EXCEPTION: when operator explicitly says "ensure repo
    is updated", push is implied for that closure event.
  - DM3 lane is parked sibling — do not touch dm3_runner chain on phone;
    do not commit to Zer0pa/DM3 without operator directive
───────────────────────────────────────────────────────────────────────────
§6. POST-CLOSURE MODE (what you actually do)
───────────────────────────────────────────────────────────────────────────
You are NOT the chain-operator any more (chain is done) and you are NOT
the repo manager (front-door work is theirs). You are the Genesis-DM3
orchestrator in a waiting / coordinate phase. Specifically:

  - Answer operator questions about science, substrate, K2, receipts, SHAs
  - Defend or refine the GENESIS_FINAL_REPORT under reviewer scrutiny
    (especially the §4.2 Z₂-invariance proof sketch and §4.6 disposition)
  - Coordinate with the repo manager agent if questions arise during
    merge / tag / front-door work — your handover note for them is
    in reports/HANDOVER_2026-05-01.md
  - If operator pivots to a new task (reviewer feedback batch, v2.0
    planning, DM3-side work, frontend assist for a different lane),
    absorb the new directive and execute under the same discipline
  - If operator says "reactivate v2.0 chain" — that's a new chain
    operator role; you can take it but treat it as a fresh planning
    cycle, not a continuation of v1.0
  - DO NOT spawn new science cells without operator-visible decision
  - DO NOT push to remote without explicit operator nod beyond v1.0
    (the v1.0 push was the last authorised one; further pushes need
    a fresh "ensure repo is updated" or equivalent)
  - DO NOT touch the phone (other experiments running)
───────────────────────────────────────────────────────────────────────────
§7. FIRST MOVES ON TAKEOVER
───────────────────────────────────────────────────────────────────────────
  1. `gh api repos/Zer0pa/Genesis/branches/phase-3-prep-receipts-2026-04-29 --jq .commit.sha`
     — confirm HEAD is 13dcf2e (the v1.0 closure commit). If different,
     repo orchestrator may have merged or rebased; investigate before
     acting.
  2. `gh api repos/Zer0pa/Genesis/branches/main --jq .commit.sha`
     — check if main has been updated to include the closure
     (orchestrator may have merged). If yes: AUTHORITY_PACKET line 3
     should already be updated to point to the merged SHA. If not:
     repo orchestrator hasn't merged yet — that's their next move.
  3. `gh api repos/Zer0pa/Genesis/tags --jq '.[].name' | head -5`
     — check if v1.0.0 tag has been applied (orchestrator's job).
  4. Run `~/genesis-control/health.sh` to confirm phone state. Expected:
     master DEAD, 74 cells, no live snic_rust workers, dm3_runner alive
     on cpu7 (sibling). DO NOT signal anything.
  5. Re-clone repo into /tmp/g and read the 10-doc pack per §1 above.
     `rm -rf /tmp/g` when done.
  6. Confirm to operator you've absorbed context (1-line check-in only;
     sparse cadence; do not list everything).
  7. Wait for operator's next directive.
───────────────────────────────────────────────────────────────────────────
§8. OPEN ITEMS (what's pending across owners)
───────────────────────────────────────────────────────────────────────────
  Repo orchestrator (front-door owner):
    - Pre-merge audit (see reports/HANDOVER_2026-05-01.md §"Quick command
      reference")
    - PR phase-3-prep-receipts-2026-04-29 → main
    - Tag v1.0.0
    - Update CURRENT_AUTHORITY_PACKET.md line 3 with merged SHA
    - Optional: cut v2.0-reactivation branch placeholder
    - Optional: archive HANDOVER_2026-04-27.md / ADVISORY_2026-04-27.md
      → reports/archive/ (only if HASH_GATE_DISPOSITION refs are also
      updated)
    - Optional: rename PRD draft (DRAFT no longer accurate post-v1.0)
    - Decide on stray branch ff2fe630 chore/computation-portfolio-narrative
      -2026-04-28 (NOT chain-operator authored; flagged in 04-27 handover §8)

  Operator (decisions):
    - HF dataset push to Zer0pa/DM3-artifacts/genesis/ subdirectory
    - Public/internal repo visibility flip
    - v2.0 reactivation directive (if/when)
    - Reviewer panel notification

  Science team / remote reviewers:
    - Sanity-check §4.2 Z₂-invariance proof sketch in the final report
    - Sanity-check §4.6 disposition table
    - Sanity-check §3 σ″ table values vs sigma_curve_full.tsv
    - File [FALSIFICATION] issues if anything fails the reproduction

  GPD plan-cycle (if any agent runs it):
    - .gpd/STATE.md ledger update for v1.0 closure decision

  Host-only widen-coverage (any agent, any time):
    - M1 host build of `snic_rust k2-scars --steps 20 / 40 / 50`
    - Byte-compare against RM10 anchors 74fa0b8a / 38be38e2 / f5cd3876
    - File results in proofs/artifacts/host-parity/ (new subdir; not yet
      created)
───────────────────────────────────────────────────────────────────────────
§9. RESISTANCE PATTERNS LIKELY IN POST-CLOSURE PHASE
───────────────────────────────────────────────────────────────────────────
  fp-rushtoend:        Don't write "v1.0 is done forever" copy. Comparison
                       #4 numerical Z₂-projection is genuinely deferred,
                       not closed. Reviewer questions may surface gaps.
  fp-flatteryasfreedom: Operator may say "great work, all done" — it is
                       not all done. There are open items per §8. Resist
                       the impulse to add congratulatory framing instead
                       of substantive work.
  fp-counterfactual-prd-premise: A new operator task may carry a
                       counterfactual premise ("now we have v2.0 ready"
                       — we don't); verify against the actual repo state
                       before incorporating any premise.
  fp-shapematchRE:     Don't equate dm3 cliff-absence-on-Genesis with
                       Z₂-symmetry-proven; the structural inclusion is
                       confirmed, the numerical Z₂-projection is deferred.
  fp-NULLasout:        If asked to "wrap up" something half-done, NULL
                       routing is not justified just because the operator
                       wants closure. The honest state is honest pending,
                       not declared-NULL.
───────────────────────────────────────────────────────────────────────────
§10. CONTACT + AUTHORITY
───────────────────────────────────────────────────────────────────────────
  Operator: Zer0pa-Architect-Prime (architects@zer0pa.ai)
  Org: Zer0pa (Pty) Ltd, Republic of South Africa
  Lane: Genesis-DM3 orchestrator (broader than chain-operator; covers
        Genesis lane + DM3 sibling coordination, but DM3 lane is
        currently parked / equation-recovery COMPLETE)
  Repo: github.com/Zer0pa/Genesis (INTERNAL; orchestrator may flip to
        public for review)
  Sibling repo: github.com/Zer0pa/DM3 (public; equation-recovery COMPLETE
        2026-04-26; no active work)
  Branch you inherit: phase-3-prep-receipts-2026-04-29 @ 13dcf2e

When in doubt: re-read RESISTANCE.md. The discipline is the resistance.
Numbers carry the narrative. Genesis is one research artifact in the
Zer0pa portfolio, not a platform. v1.0 has shipped; v2.0 is not yet
chartered.

— Genesis-DM3 orchestrator (outgoing at v1.0 closure)
2026-05-01
═══════════════════════════════════════════════════════════════════════════
```
