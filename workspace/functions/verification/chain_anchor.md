---
id: "fn:verification.chain_anchor(uuid,jsonb,text)"
kind: function
schema: verification
name: chain_anchor
domain: evidence
lens: evidence
overloads: ["fn:verification.chain_anchor(uuid,jsonb,text)"]
security: invoker
volatility: volatile
executors: []
raises: []
touches: { reads: [content.document_node, content.document_representation, content.document_version_source_capture, evidence.source_capture], writes: [evidence.locator] }
tokens: [verification, chain_anchor, verification.chain_anchor]
defined_in: ["20261116130000_build08_governed_chain_writes.sql", "20261116150000_build08_capture_receipt_unit_text.sql"]
workspace_fingerprint: "sha256:3cbce2e1f51948facb352a727c22966b1e5ceea4646ae43b07860ce6e83127b4"
---
# verification.chain_anchor

Domain `evidence`, lens `evidence`.

## chain_anchor(uuid, jsonb, text, uuid, uuid, uuid, boolean) → record

function, volatile, security invoker, language plpgsql, config `search_path=""`. One evidence anchor of a governed write (api.record_claim evidence, api.record_probe_run output): an existing locator of the tenant, or a new one on a capture naming a content unit of it. A new anchor needs a unit with text: a unit whose text is NULL, empty or only whitespace is QUOTE_NOT_IN_UNIT. A text_quote anchor needs a quote with text (QUOTE_REQUIRED) that is verbatim in the unit after verification.chain_norm (QUOTE_NOT_IN_UNIT); a json_pointer anchor may carry such a quote or anchor the unit's own text.

| Argument | Type | Default | Mode |
| --- | --- | --- | --- |
| `p_tenant` | `uuid` | — | — |
| `p_spec` | `jsonb` | — | — |
| `p_function` | `text` | — | — |
| `locator_id` | `uuid` | — | out |
| `capture_id` | `uuid` | — | out |
| `source_id` | `uuid` | — | out |
| `created` | `boolean` | — | out |

Execute: no configured role.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_version_source_capture`](../../relations/content/document_version_source_capture.md), [`evidence.source_capture`](../../relations/evidence/source_capture.md); writes [`evidence.locator`](../../relations/evidence/locator.md); calls [`util.uuidv7`](../util/uuidv7.md), [`verification.chain_fail`](chain_fail.md), [`verification.chain_norm`](chain_norm.md), [`verification.chain_sha`](chain_sha.md), [`verification.chain_uuid`](chain_uuid.md).

TypeScript: `Database["verification"]["Functions"]["chain_anchor"]`.

Defined in: `20261116130000_build08_governed_chain_writes.sql`, `20261116150000_build08_capture_receipt_unit_text.sql`.
