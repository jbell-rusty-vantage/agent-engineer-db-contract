---
id: "fn:retrieval.evidence_signal(uuid,uuid,text)"
kind: function
schema: retrieval
name: evidence_signal
domain: retrieval
lens: corpus
overloads: ["fn:retrieval.evidence_signal(uuid,uuid,text)"]
security: definer
volatility: stable
executors: []
raises: []
touches: { reads: [content.document_version, content.document_version_source_capture, evidence.claim, verification.probe_claim, verification.probe_run, verification.probe_verdict], writes: [] }
tokens: [retrieval, evidence_signal, retrieval.evidence_signal]
defined_in: ["20261113160000_build08_loop5_followups.sql", "20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql"]
workspace_fingerprint: "sha256:94ffe6a458de74a3cfebdee4fb31f371d14c89d7eaa16cfe1ab1cae9dc94743b"
---
# retrieval.evidence_signal

Domain `retrieval`, lens `corpus`.

## evidence_signal(uuid, uuid, text) → jsonb

function, stable, security definer, language sql, config `search_path=""`. Loop 5 (D-62): the evidence behind a search candidate: its claim's current probe verdict and status, or for a probe observation the verdicts of the claims its probe judged. +1 supported or verified, +0.5 qualified, -1 contradicted or disputed, 0 otherwise (averaged). Not a relevance score; search reports it as its own channel.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_claim` | `uuid` | — | — |
| `p_document` | `uuid` | — | — |
| `p_unit_kind` | `text` | — | — |

Execute: no configured role.

Touches (best effort): reads [`content.document_version`](../../relations/content/document_version.md), [`content.document_version_source_capture`](../../relations/content/document_version_source_capture.md), [`evidence.claim`](../../relations/evidence/claim.md), [`verification.probe_claim`](../../relations/verification/probe_claim.md), [`verification.probe_run`](../../relations/verification/probe_run.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); writes —; calls —.

TypeScript: `Database["retrieval"]["Functions"]["evidence_signal"]`.

Defined in: `20261113160000_build08_loop5_followups.sql`, `20261113160000_build08_loop5_ranking_rules_revalidation_triage.sql`.
