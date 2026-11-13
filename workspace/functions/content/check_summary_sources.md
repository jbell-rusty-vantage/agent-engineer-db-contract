---
id: "fn:content.check_summary_sources()"
kind: function
schema: content
name: check_summary_sources
domain: content
lens: machinery
overloads: ["fn:content.check_summary_sources()"]
security: invoker
volatility: volatile
executors: []
raises: [summary coverage ratio mismatch, summary hash/transformation mismatch, summary source node belongs to another representation, summary transformation does not consume faithful representation]
touches: { reads: [content.document_node, content.document_representation, content.document_summary, content.document_summary_source, content.transformation_input], writes: [] }
tokens: [content, check_summary_sources, content.check_summary_sources]
defined_in: ["20260912010600_km_06_content.sql"]
workspace_fingerprint: "sha256:4ca964568389f6bca66099cb3a109cf6e895892ead47d26c6c89b292b0e91e75"
---
# content.check_summary_sources

Domain `content`, lens `machinery`.

## check_summary_sources() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `summary coverage ratio mismatch`; `summary hash/transformation mismatch`; `summary source node belongs to another representation`; `summary transformation does not consume faithful representation`.

Touches (best effort): reads [`content.document_node`](../../relations/content/document_node.md), [`content.document_representation`](../../relations/content/document_representation.md), [`content.document_summary`](../../relations/content/document_summary.md), [`content.document_summary_source`](../../relations/content/document_summary_source.md), [`content.transformation_input`](../../relations/content/transformation_input.md); writes —; calls —.

Defined in: `20260912010600_km_06_content.sql`.
