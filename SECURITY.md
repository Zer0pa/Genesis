# Security Policy

## Supported Scope

This is a research repository with no authentication surface, no user-data handling, and no networked service. Security relevance is bounded to:

1. Deterministic-computation guarantees: the verified-substrate property (`unique_canonical_sha_count = 1` per cell) is a scientific integrity claim. Any reproducible deviation from the canonical SHAs in `REPRODUCIBILITY.md` — across the same binary version, same hardware class, and same config — is a reportable finding.
2. Proof and receipt artifacts (`proofs/`, `cells/`): tampering with committed receipts or canonical hashes undermines the falsification record. Evidence of artifact modification after commit is reportable.
3. The LICENSE (`LicenseRef-Zer0pa-SAL-7.0`): any redistribution or derivative work that obscures the license terms is a policy concern.

There is no runtime package, no pip-installable surface, and no CI secret exposure in scope for this repository.

## Reporting

Report privately to `architects@zer0pa.ai` with:

1. A clear impact summary.
2. Reproduction steps or proof-of-concept, including binary SHA, config, and observed hash deviations.
3. Affected commit range or version.
4. Suggested remediation when available.

## Response Targets

1. Initial acknowledgement: within 5 business days.
2. Triage and severity classification: within 10 business days.
3. Remediation timeline: shared after triage.

Public disclosure should be coordinated after a fix or falsification record is available.
