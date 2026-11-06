---
id: "fn:content.check_summary_lineage()"
kind: function
schema: content
name: check_summary_lineage
domain: content
overloads: ["fn:content.check_summary_lineage()"]
security: invoker
volatility: volatile
executors: []
raises: [summary representation lineage mismatch, summary requires faithful source nodes, summary requires summarize transformation, summary source must be faithful]
touches: { reads: [content.document_node, content.document_representation, content.document_summary, content.document_summary_source, content.transformation_run], writes: [] }
tokens: [content, check_summary_lineage, content.check_summary_lineage]
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:7a48802958842799e147100aef5431e62d1d8bd786b3cb08c29eaa0e8a8ccf0e"
---
# content.check_summary_lineage

Domain `content`.

## check_summary_lineage() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `summary representation lineage mismatch`; `summary requires faithful source nodes`; `summary requires summarize transformation`; `summary source must be faithful`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_summary`](../../relations/content/document_summary.md), [`content.document_summary_source`](../../relations/content/document_summary_source.md), [`content.transformation_run`](../../relations/content/transformation_run.md); writes —; calls —.

Defined in: `20260912010600_km_06_content.sql`.
