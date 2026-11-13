---
id: "fn:evidence.derive_source_assessment(uuid,uuid,text,text)"
kind: function
schema: evidence
name: derive_source_assessment
domain: evidence
lens: evidence
overloads: ["fn:evidence.derive_source_assessment(uuid,uuid,text,text)"]
security: definer
volatility: volatile
executors: [anon, app_reader, authenticated, control_plane, executor_service, pipeline_agent, service_role, verifier_agent]
raises: []
touches: { reads: [acquisition.attention_policy, acquisition.attention_sweep, catalog.entity, content.source_role, evidence.attribution, evidence.claim, evidence.claim_subject, evidence.source, verification.probe_verdict], writes: [evidence.source_assessment] }
tokens: [evidence, derive_source_assessment, evidence.derive_source_assessment]
defined_in: ["20261113120000_build08_loop4_source_intelligence_experiments.sql", "20261113120200_build08_loop4_fixup_assessment.sql"]
workspace_fingerprint: "sha256:78aebf069f0925cf906c3997f4050a5a9e69eae7bcc29ce2060a813d8a02d4a9"
---
# evidence.derive_source_assessment

Domain `evidence`, lens `evidence`.

## derive_source_assessment(uuid, uuid, text, text) → uuid

function, volatile, security definer, language plpgsql, config `search_path=""`. Loop 4: appends a derived assessment of a source on a topic from the latest probe verdicts on the claims it stated (evidence.attribution by actor, channel or publisher). The base (role, conflict of interest, method disclosure) is the latest prior or reviewed row on the topic, else on all topics. Supported and contradicted verdicts are checked; not reproduced, unverifiable and insufficient evidence are observed only (D-59).

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_subject` | `uuid` | — | — |
| `p_topic` | `uuid` | `NULL::uuid` | — |
| `p_assessed_by` | `text` | `'agent:derive_source_assessment'::text` | — |
| `p_note` | `text` | `NULL::text` | — |

Execute: `anon`, `app_reader`, `authenticated`, `control_plane`, `executor_service`, `pipeline_agent`, `service_role`, `verifier_agent`.

Touches (best effort): reads [`acquisition.attention_policy`](../../relations/acquisition/attention_policy.md), [`acquisition.attention_sweep`](../../relations/acquisition/attention_sweep.md), [`catalog.entity`](../../relations/catalog/entity.md), [`content.source_role`](../../relations/content/source_role.md), [`evidence.attribution`](../../relations/evidence/attribution.md), [`evidence.claim`](../../relations/evidence/claim.md), [`evidence.claim_subject`](../../relations/evidence/claim_subject.md), [`evidence.source`](../../relations/evidence/source.md), [`verification.probe_verdict`](../../relations/verification/probe_verdict.md); writes [`evidence.source_assessment`](../../relations/evidence/source_assessment.md); calls —.

TypeScript: `Database["evidence"]["Functions"]["derive_source_assessment"]`.

Defined in: `20261113120000_build08_loop4_source_intelligence_experiments.sql`, `20261113120200_build08_loop4_fixup_assessment.sql`.
