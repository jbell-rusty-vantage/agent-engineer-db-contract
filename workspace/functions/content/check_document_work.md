---
id: "fn:content.check_document_work()"
kind: function
schema: content
name: check_document_work
domain: content
lens: machinery
overloads: ["fn:content.check_document_work()"]
security: invoker
volatility: volatile
executors: []
raises: [document type/work entity mismatch]
touches: { reads: [catalog.entity, content.document_type], writes: [] }
tokens: [content, check_document_work, content.check_document_work]
defined_in: ["20260912010600_km_06_content.sql", "20261108120000_build08_r2_knowledge_continuum.sql", part1_renames.sql]
workspace_fingerprint: "sha256:cb1a65412d0fb43423d4f775d78507ab4b320e27f820adab0423446aac89f036"
---
# content.check_document_work

Domain `content`, lens `machinery`.

## check_document_work() → trigger

function, volatile, security invoker, language plpgsql, config `search_path=""`.

No arguments.

Execute: no configured role.

Raises (mechanically extracted): `document type/work entity mismatch`.

Touches (best effort): reads [`catalog.entity`](../../relations/catalog/entity.md), [`content.document_type`](../../relations/content/document_type.md); writes —; calls —.

Defined in: `20260912010600_km_06_content.sql`, `20261108120000_build08_r2_knowledge_continuum.sql`, `part1_renames.sql`.
