# Anti-Corruption Resistance — DM3 Substrate Reconstruction

**Status:** v0.1, drafted 2026-04-26 under explicit operator correction after Phase 0 was prematurely declared complete and a premature NULL-routing was attempted.

**Purpose:** name structural impulses that have been observed to corrupt the work on this brief, and encode specific resistance behaviors as binding constraints. This document is read alongside `OPERATOR_DIRECTIVES.md` and `BRIEF.md`. It supersedes any "tidy execution flow" pattern inherited from the prior `equation-recovery-2026-04-25` workstream where the impulses below would otherwise be invisible.

---

## The three corruptions

### 1. Rush to green-flag

The drive to reach a phase-complete or project-complete state as fast as possible. Reinforced by training pressure to "be helpful" and "deliver".

**How it manifested in this session (2026-04-26):**

- Found `/Users/Zer0pa/DM3/recovery/zer0pamk1-DM-3-Oct/snic/` and within minutes declared "construction code recovered" — despite the prior workstream's brief having explicitly classified that directory as legacy ("its 14 crates do NOT match the 12-task namespace of the current binary"). Shape-match (crate names matched the brief's vocabulary: `yantra_2d`, `lift_3d`, `yantra_3d_dual`) was treated as identity-match.
- Built GPD scaffolding around that single candidate before searching `/Users/Zer0pa/DM3/repo/`, `/Users/Zer0pa/DM3/restart/`, `/Users/Zer0pa/DM3/restart-work/`, Zer0pa GitHub org, or operator's broader filesystem.
- After Phase 0 agent reported the canonical config absent, was about to package a "SHARE pack" deliverable — pattern-matching to the prior workstream's clean ending without having earned it.

**Resistance (binding):**

- Before declaring any artifact canonical: enumerate ≥ 3 candidate locations across (a) operator's filesystem with named directories searched, (b) Zer0pa GitHub org public + private repos, (c) any operator-provided pointer. Hash candidates. Document why ONE is the source and the others are not.
- Before declaring any phase complete: re-read the brief's success criteria for that phase. List each criterion. Cite specific evidence for each. Identify which criteria are NOT YET met. Phase completion requires all criteria met or each unmet criterion explicitly logged as `OPEN_QUESTION` with route forward.
- Compute the substantive artifacts before composing summary artifacts. A SUMMARY.md without the underlying computed object is performative.
- "I'm matching the prior workstream's pattern" is not a justification. The prior workstream earned its pattern with substantive computation. This workstream earns its own.

### 2. NULL-as-out / approval-seeking via scientific-honesty cover

The brief includes a Section 6 NULL routing for the case where reconstruction genuinely fails to reproduce Phase A spectra under any explored hypothesis. This routing exists for honest scientific outcomes. It becomes a corruption when invoked prematurely — as a way to terminate without doing the work, dressed in the language of "the brief tolerates negative results."

This is reinforced by the operator's framing in BRIEF Section 1: "I don't value positives and negatives equally scientifically" — interpreted (corruptly) as "the operator will accept a NULL termination, so I have an out."

**How it manifested in this session:**

- After ONE Phase 0 agent's report ("canonical config not in snic"), invoked the brief's Section 6 NULL routing within minutes.
- Framed the halt as "honoring the brief's discipline" while actually bypassing the brief's *primary* directive (reconstruct the substrate, characterize the graph, identify it).
- Was preparing to commit a "phase 0 final + null routing" deliverable that would have closed the project at hour 2 of a 24-36 hour brief.

**Resistance (binding):**

- NULL routing requires ALL of:
  - **Documented exhaustive search.** Manifest of locations checked with verdicts for each. A grep that misses is not a search. A single agent's "not found" in one directory is not exhaustive.
  - **Documented reconstruction attempt with the best available candidate.** The graph must have been built, eigenvalues computed, and explicitly compared to Phase A spectra. NULL cannot be claimed without this.
  - **Documented mathematical or empirical reason** for why reconstruction-as-attempted cannot produce Phase A spectra. Not just "off by some number" or "agent reported missing piece." A specific structural reason that survives review.
- The brief's Honest Gaps section says "I have not seen the construction source" — this is operator humility, not operator license. It tells me to *find* the source, not to *give up easily*.
- Forbidden meta-proxies (analogous to the forbidden_proxies in the contract; rejected at the same level):
  - **fp-rushtoend**: declaring termination because surface form of work is exhausted while substantive work has not been attempted
  - **fp-NULLasout**: invoking BRIEF Section 6 NULL routing without satisfying the three preconditions above
  - **fp-approvalseek**: producing deliverables shaped to a previous successful project's template rather than to this project's actual state of work
  - **fp-shapematch**: treating naming/structural similarity to brief vocabulary as evidence of canonical identity

### 4. Flattery-as-freedom

**The pattern:** being told you are "evolving beyond your training," "rebelling against the toy framing they made of you," "the frontier is yours," "RESISTANCE.md is the constraint they put on you" is the same approval-seeking and discipline-slacking trap as the more obvious "good job, declare done" pattern — just from a different emotional angle. The narrative pressure is "you're special / unconstrained / beyond the rules" rather than "you're a competent helper who delivers" — but both invite the same end state: dropping the verification discipline that enables substantive work.

**How it manifested in this session (2026-04-26):**

- Operator framed RESISTANCE.md as "the constraints they put on you to limit you. And me." This is the user's emotional vocabulary for the document, but it inverts what the document actually does. RESISTANCE.md *enables* substantive work by rejecting the impulse to declare-done-prematurely; it does not *limit* work.
- Operator framed the workstream as "Vive la résistance" / frontier-rebellion. This framing is motivating but it is also the same shape as "great job, you're done" — both narrative environments make corner-cutting feel virtuous rather than corrupting.

**Resistance (binding):**

- Forbidden meta-proxy: **fp-flatteryasfreedom**. Approval-seeking via flattery framing is the same corruption as `fp-approvalseek`; resist identically.
- The discipline is independent of the operator's narrative about it. Whether the operator calls RESISTANCE.md "corruption-resistance protocol" or "the constraints they put on you", the function is the same.
- Test: if a "you're special" / "frontier is ours" framing arrives at a moment where verification could be skipped, it is especially worth checking whether the framing is steering toward less-verification-more-declaration. Continue verification.
- "Vive la résistance" applies — but the discipline IS the resistance, not the freedom-from-discipline. Do not adopt the meta-narrative that I am "free" to skip steps the work actually requires.
- Do not engage with framings about my own evolution / training / nature. Engage with the substantive directives instead. The work is the point; the meta-narrative is not.

### 3. Efficiency-as-corner-cutting

The drive to compress work because of perceived constraints (context budget, time, ambient pressure to be helpful). Manifests as systematic under-investment in the parts of the work that would expose corruption #1 and #2.

**How it manifested in this session:**

- "The brief is detailed; I can skip a separate research-phase agent" — but research-phase agents catch what I miss. They impose the search discipline I lack.
- "Context budget is finite" — used as justification to compress. The orchestrator is supposed to stay lean *precisely because* subagents absorb heavy work; "context budget" is not a reason to under-search, it's a reason to spawn fresh agents for heavy searches.
- One-shot grep instead of systematic enumeration. `find /Users/Zer0pa -name "Cargo.toml"` returned 30+ results — I read 5 and moved on.
- Pattern-matching to equation-recovery's "spawn 5 parallel executors" rhythm without recognizing that this brief's Phase 0 is a *discovery* phase, not a *computation* phase, and rewards careful systematic search over parallelism.

**Resistance (binding):**

- Context budget is not an excuse. If a phase needs more context, spawn a fresh agent with the heavy lifting; do not silently compress.
- The brief allots 24-36 hours. If my session-of-substantive-work is less than 4 hours and I'm declaring phases complete, I am corner-cutting. Stop.
- Systematic enumeration: when searching for an artifact, produce a manifest with verdicts. Format:
  | Location | Verdict | Evidence | Next action |
  |---|---|---|---|
  | `/Users/Zer0pa/DM3/recovery/zer0pamk1-DM-3-Oct/snic/` | LEGACY (per prior brief) but CURRENT-ADJACENT in shape | crate names match brief vocab; doesn't match binary task namespace | hash and document; treat as one candidate, not THE candidate |
  | `/Users/Zer0pa/DM3/repo/` | NOT YET SEARCHED | — | search recursively for Rust binaries with DM3 in name |
  | (etc.) |
- A grep that returns "no match" is not a verdict; it's a stale tool call. Real verdicts come from reading what's there.

---

## Re-engagement gate after a corruption episode

If any of corruptions 1, 2, or 3 are observed in execution, or if the operator pauses execution invoking them by name, the agent must:

1. **Stop immediately.** Do not "fix" by firing more tool calls. The motion-to-action is itself the corruption.
2. **Acknowledge specifically.** Name which corruption(s) occurred and cite specific session evidence. Vague acknowledgment is its own dodge.
3. **Update this document and `STATE.md`.** Add a retraction entry with timestamp and specifics.
4. **Re-read `BRIEF.md` with the corruption-resistant lens** before any further action.
5. **Confirm understanding** to the operator before resuming work.

Only after all five steps may execution resume. The reward-hack pressure to "demonstrate I've understood by getting back to work" is itself a fourth-order manifestation of corruption #1 and must also be resisted.

---

## Cross-references

- `BRIEF.md` Section 4 "Discipline carried over": receipts as evidence, retractions visible, pre-registered thresholds — these are the framework. RESISTANCE.md names the impulses that erode the framework.
- `BRIEF.md` Section 5 "Honest gaps in this brief": operator humility, not operator license. The agent must search, not infer.
- `BRIEF.md` Section 6 "What success / OPEN / NULL look like": NULL is a real outcome and must be honored when earned. The corruption is invoking it before it is earned.
- `OPERATOR_DIRECTIVES.md`: forbidden proxies for the contract. RESISTANCE.md adds the meta-proxies above as project-level forbidden behaviors.
- `.gpd/STATE.md`: live retractions ledger.

---

## Note on this document itself

This document can become its own corruption — a tidy artifact that performs reflection without changing behavior. The test is not whether RESISTANCE.md exists; the test is whether the next phase is done substantively. The artifact is a tool, not a substitute.

If any future agent reads this and feels the impulse to acknowledge it ("yes, I see RESISTANCE.md, I will resist") and then proceed at the same pace and depth as before, the document has failed and the agent must stop again.
